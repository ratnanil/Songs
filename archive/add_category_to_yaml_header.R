list.files("01_songs_input",".txt",recursive = TRUE,full.names = TRUE)[1] %>%
  map(function(x){
    cat <- str_remove(str_extract(str_split_fixed(x,"/",3)[,2],"\\d{2}"),"0")
    cat
    line <- readLines(x)
    start_stop <- yaml_headerpos(line)
    yamlheader <- read_yamlheader(line,FALSE)
    line <- line[-(start_stop[1]:start_stop[2])]
    
    yamlheader["category"] <- cat
    yamlheader
    c("---",yaml::as.yaml(yamlheader),"---",line) %>%
      writeLines(x)
  })
