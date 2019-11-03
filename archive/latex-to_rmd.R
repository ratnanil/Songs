library(magrittr)
library(stringr)
songs <- list.files("songs/",full.names = F)

for (song in songs){
  print(song)
  
  fileConn<-file(paste0("songs_new/",song))
  
  so <- paste0("songs/",song) %>%
    readLines() %>%
    # head() %>%
    str_replace(pattern = "\\\\section\\{","## ") %>%
    str_remove("\\\\begin\\{verbatim\\}") %>%
    str_remove("\\\\end\\{verbatim\\}") %>%
    str_remove("\\}") %>%
    str_remove("\\\\.+\\{") %>% 
    writeLines(fileConn)
}


songs <- list.files("songs_new/",pattern = ".Rmd",full.names = F)

for (song in songs){
  print(song)
  
  fileConn<-file(paste0("songs_new3/",song))
  
  orig <- paste0("songs_new/",song) %>%
    readLines()
  
  titleline <- orig %>%
    str_detect(pattern = "##") %>%
    which.max()
  

  append(orig,"```{}",after = titleline) %>%
    append("```",after = length(.)) %>%
    writeLines(fileConn)
    }



songs <- list.files("songs_new/",pattern = ".Rmd",full.names = F)

for (song in songs){
  print(song)
  
  fileConn<-file(paste0("songs_new2/",song))
  
  paste0("songs_new/",song) %>%
    readLines() %>%
    str_replace(pattern = "$","\\\\") %>%
    writeLines(fileConn)
}