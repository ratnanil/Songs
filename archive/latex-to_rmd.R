library(magrittr)
library(stringr)
library(dplyr)
library(purrr)

## Takes "raw" Songs and wraps all chords with braces [ ]

songs <- list.files("songs_txt/",pattern = ".txt",full.names = TRUE)


# song <- songs[1]
# for (song in songs){
#   
#   song_bn <- basename(song)
#   
#   fileConn<-file(paste0("songs_cho/",song_bn))
#   
#   chords <- "Bm|Em|A7|D|G|G7|C|D7|F#m|E|Am|B7|A|F|H7"
#   
#   song %>%
#     readLines(warn = FALSE) %>%
#     # str_replace_all("((\\s)[A-H](\\s))|((\\s)[A-H](maj7|maj9|m|#)(\\s))","[\\1]") %>%
#     str_replace_all(paste0("(\\s(",chords,")\\s)"),"[\\2]") %>%
#     str_replace_all(paste0("(^(",chords,")\\s.)"),"[\\2]") %>%
#     str_replace_all(paste0("(\\s(",chords,")$)"),"[\\2]") %>%
#     str_replace_all(paste0("(^(",chords,")$)"),"[\\2]") %>%
#     writeLines(fileConn)
#   
#   close.connection(fileConn)
#   grep
# }



## Takes songs where the chords are wrapped in braces [] and format's 

addchord <- function(string,pos,chord){
  paste0(substr(string, 1, pos-1), chord, substr(string, pos, nchar(string)))
  
}


songs <- list.files("songs_cho/",pattern = ".txt",full.names = TRUE)

song <- songs[1]
for (song in songs){
  
  song_bn <- basename(song)
  
  fileConn<-file(paste0("songs_md2/",song_bn))
  
  song_rl <- song %>%
    readLines(warn = FALSE)
    
  chordlines_bool <- song_rl %>%
    str_detect("\\[") 
  
  # Take only lines where subsequent line is not a chord line
  chordlines_bool <- chordlines_bool & lead(!chordlines_bool,1)
  
  songlines_subsequent_bool <- lag(chordlines_bool,1,default = FALSE)
  
  chordlines <- song_rl[chordlines_bool]
  songlines_subsequent <- song_rl[songlines_subsequent_bool]
  
  songlines_new <- map2_chr(chordlines,songlines_subsequent,function(chordline,songline){
    locs <- str_locate_all(chordline,"\\[\\w+\\]")[[1]]

    delta_acc = 0
    for(idx in 1:nrow(locs)){
      start <- locs[idx,1]
      end <- locs[idx,2]
      chord <- str_sub(chordline,start,end)
      
      start_insert <- start + delta_acc
      if(idx>1){
      } else{
        songline_out <- songline
      }
      songline_out <- addchord(songline_out,start_insert,chord)
      
      delta_acc <- delta_acc+ (end-start+1)
      
    }
    songline_out
  })
  
  song_rl[songlines_subsequent_bool] <- songlines_new
  
  
  song_modified <- song_rl[!chordlines_bool]
  
  song_modified %>%
    str_replace_all("(\\[(\\w+)\\])","<span class='chord'>\\2</span>") %>%
    str_replace_all("\\{title:(.+?(?=\\}))","## \\1") %>%
    paste0("<p class='song show-chords'>",.,"</p>")%>%
    writeLines(fileConn) 
  
  close.connection(fileConn)
  
}
