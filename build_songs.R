# Transform all songs in songs_txt into markdown files

library(dplyr)
library(purrr)
library(ggplot2)
library(stringr)
library(gridExtra)
library(cowplot)
library(yaml)
library(tabr)
library(yaml)
library(stringr)

################################################################################
## Add chords to songs #########################################################
################################################################################

# A wrapper around tabr::plot_chord() which allows multiple chords and styles them in my specific way (4 columns, transparent background etc.)
plot_chords <- function(chords){
  # Get the maximum fret-delta of all chords
  delta_max <- map_int(chords,function(x){
    v <- suppressWarnings(as.integer(str_split(x,"",simplify = TRUE)))
    max(v,na.rm = TRUE)-min(v, na.rm = TRUE)
  }) %>%
    max()
  
  # Make a list of all chord plots
  plots <- imap(chords,function(x,y){
    v <- min(suppressWarnings(as.integer(str_split(x,"",simplify = TRUE))),na.rm = TRUE)
    
    plot_chord(x,
               labels = NULL,
               fret_range = c(v,v+delta_max), # so that all chords span the same nr of frets
               point_size = 4,
               label_size = 3) + 
      labs(tag = y) +
      theme(
        panel.background = element_rect(fill = "transparent"), # The theme 
        plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
      )
  })
  chordnames <- map(chords, ~.x[2])
  plot_grid(plotlist = plots,ncol = 4)
}

addchord <- function(string,pos,chord){
  paste0(substr(string, 1, pos-1), chord, substr(string, pos, nchar(string)))
}

chordpro_meta <- function(string,metatag){
  regexpression <- paste0("\\{",metatag,":\\s(.+)\\}")
  meta_bool <- str_detect(string,regexpression)
  str_replace(string[meta_bool],regexpression, "\\1")
}





chordpro_meta_all <- function(string, remove = FALSE){
  chordpro_tags <- c("title", "subtitle", "artist", "composer", "lyricist", "copyright", "album", "year", "key", "time", "tempo", "duration", "capo", "meta")  
  if(!remove){
    out2 <- map(chordpro_tags, ~chordpro_meta(string,.x))
    names(out2) <- chordpro_tags
    out2
  } else{
    remove <- str_detect(string,paste0("(",paste0("\\{",chordpro_tags,":",collapse = "|"),")"))
    string[!remove]
  }
}

chordpro_environment <- function(string,environment_name){
  start_bool <- str_detect(string,paste0("\\{start_of_",environment_name))
  end_bool <- str_detect(string,paste0("\\{end_of_",environment_name))
  c(which(start_bool),which(end_bool))
}

chordpro_environment_all <- function(string){
  envs <- c("chorus","verse","tab","grid")
  out2 <- map(envs, ~chordpro_environment(string,.x))
  names(out2) <- envs
  out2
}

################################################################################
## Songs to RMarkdown ##########################################################
################################################################################

dirs <- list.dirs("01_songs_input",full.names = TRUE)

for (folder in c("songs_md2","songs_md3")){
  for (file in list.files(folder,pattern = ".Rmd",full.names = TRUE)){file.remove(file)}
}


rmd_file_nr = 0
for (dir in dirs){
  yml <- list.files(dir,pattern = "(.yaml|.yml)",full.names = TRUE)
  
  
  
  
  if(length(yml) > 0){
    meta <- read_yaml(yml)
    rmd_file_nr <- rmd_file_nr+1
    rmd_file_nr_chr <- paste0(str_pad(rmd_file_nr,3,pad = "0"),"_")
    
    dir_bn <- basename(dir)
    
    usecss = FALSE
    
    fileConn<-file(paste0("02_songs_output/",rmd_file_nr_chr,dir_bn,".Rmd"))
    
    paste("#",meta$title) %>%
      writeLines(fileConn)
    
    close.connection(fileConn)
    
    songs <- list.files(dir, pattern = ".txt",full.names = TRUE)
    
    # gives each file an arbitary number 
    songs_numeric <- map_dbl(basename(songs),~mean(utf8ToInt(.x)))
    names(songs_numeric) <- songs
    songs_numeric <- sort(songs_numeric)
    songs <- names(songs_numeric)
    
    for (song in songs){
      print(song)
      
      song_bn <- basename(song)
      
      song_rl <- song %>%
        readLines(warn = FALSE)
      
      
      if(usecss){
        chordlines_bool <- song_rl %>%
          str_detect("\\[") 
        
        # Take only lines where subsequent line is not a chord line
        chordlines_bool <- chordlines_bool & lead(!chordlines_bool) & lead(str_length(song_rl)>0)
        
        songlines_subsequent_bool <- lag(chordlines_bool,1,default = FALSE)
        
        chordlines <- song_rl[chordlines_bool]
        songlines_subsequent <- song_rl[songlines_subsequent_bool]
        
        songlines_new <- map2_chr(chordlines,songlines_subsequent,function(chordline,songline){
          locs <- str_locate_all(chordline,"\\[\\w+\\]")[[1]]
          # print(locs)
          
          delta_acc = 0
          for(idx in 1:nrow(locs)){
            # print(idx)
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
        
        
        chordpro_meta_l <- chordpro_meta_all(song_modified)
        
        song_modified <- chordpro_meta_all(song_modified,remove = TRUE)
        
        chordpro_environment_l <- chordpro_environment_all(song_modified) 
        songtitle <- ifelse(length(chordpro_meta_l$artist)>0,paste(chordpro_meta_l$title,chordpro_meta_l$artist, sep = " - "),chordpro_meta_l$title)
        
        
        song_modified[chordpro_environment_l$chorus[1]] <- "**Chorus:**"
        song_modified[chordpro_environment_l$chorus[2]] <- ""
        
        song_modified[chordpro_environment_l$verse[1]] <- ""
        song_modified[chordpro_environment_l$verse[2]] <- ""
        
        song_modified[chordpro_environment_l$tab] <- "```" 
        
        song_modified[chordpro_environment_l$grid] <- "```"
        
        song_modified[chordpro_environment_l$bridge] <- "```"
        
        
        
        # Add the class "show-chords" to lines with chords
        haschords <- str_detect(song_modified,"\\[")
        song_modified[haschords] <- paste0("<p class='song show-chords'>",song_modified[haschords],"</p>")
        
        codechunk <- str_detect(song_modified,"```")
        
        # Add an extra backslash to lines with no chords to force linebreak
        song_modified[!haschords & !codechunk] <- paste0(song_modified[!haschords & !codechunk],"\\")
        
        rmd_file_nr <- rmd_file_nr+1
        rmd_file_nr_chr <- paste0(str_pad(rmd_file_nr,3,pad = "0"),"_")
        
        fileConn<-file(paste0("songs_md2/",paste0(rmd_file_nr_chr, str_replace(song_bn,".txt",".Rmd"))))
        
        song_modified %>%
          prepend(paste("##", songtitle)) %>% # TODO: add other metadata
          str_replace_all("(\\[(\\w+)\\])","<span class='chord'>\\2</span>") %>%
          writeLines(fileConn)
        
        close.connection(fileConn)
      } else{ # do this instead of the fancy css / html stuff
        
        
        start_and_ends <- c("chorus","verse","bridge","tab","grid")
        
        
        
        start_end_res <- str_match(song_rl,paste0("\\{(start|end)_of_(",paste(start_and_ends,collapse = "|"),"):?\\s?(.+)?\\}"))
    
        
        start_labels <-  ifelse(start_and_end_res[,2] == "start",str_to_title(paste0(str_replace(start_and_end_res[,3],"grid","chords"), ifelse(!is.na(start_and_end_res[,4]),paste0(" (",start_and_end_res[,4],")"),""))),NA)
        
        
        
        # Get all metadata which include tags
        # song_meta <- str_match(song_rl, "\\{(\\w+):\\s(.+)\\}")
        
        # Get all metadata without tags
        # song_meta2 <- str_match(song_rl, "\\{(\\w+)") # todo: add end of bracket
        
        # starts_or_ends <- which(apply(song_meta2, 1, function(x)str_detect(x[2],"start_of_|end_of_")))
        
        
        # stopifnot(length(starts_or_ends) %%2 == 0) # must be an even number
        
        # for now, just replace this information with code starts/ends
        # song_rl[starts_or_ends] <- "```"
        
        
        meta_data_tags <- c("title", "subtitle", "artist", "composer", "lyricist", "copyright", "album", "year", "key", "time", "tempo", "duration", "capo", "meta")
        
        meta_data_directives <- str_match(song_rl, paste0("\\{(",paste(meta_data_tags,collapse = "|"),"):\\s(.+)\\}"))
        
        meta_data_lines <- !is.na(meta_data_directives[,1])
        
        meta_data_directives <- meta_data_directives[meta_data_lines,]
        
        meta_data_directives <- map(meta_data_directives[,3],~.x) %>%
          magrittr::set_names(meta_data_directives[,2])
        
        # song_meta_dfr <- map_dfr(c("title","artist","year"), function(x){
        #   row <- which(song_meta[,2] == x)
        #   value = song_meta[row,3]
        #   tibble(tag = x, row = row,value = value)
        # })
        
        
        song_rl <- song_rl[-c(which(meta_data_lines))]
        
        song_header <- paste0(
          "## ",
          meta_data_directives["title"],
          ifelse("artist" %in% names(meta_data_directives),
                 paste0(" - ",meta_data_directives["artist"]),
                 ""
          ),
          ifelse("year" %in% names(meta_data_directives),
                 paste0(
                   " (",
                   meta_data_directives["year"],
                   ")"
                 )
                 ,"")
        )
        
        data.frame(meta_data_directives)
        
        song_rl <- c(song_header,"", "```",song_rl,"```")
        
        rmd_file_nr <- rmd_file_nr+1
        rmd_file_nr_chr <- paste0(str_pad(rmd_file_nr,3,pad = "0"),"_")
        
        fileConn<-file(paste0("02_songs_output//",paste0(rmd_file_nr_chr, str_replace(song_bn,".txt",".Rmd"))))
        
        writeLines(song_rl,fileConn)
        close(fileConn)
      }
      
    }
    
  }
}



