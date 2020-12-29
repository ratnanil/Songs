
library(dplyr)
library(yaml)
library(stringr)
library(purrr)
bookdownyaml <- read_yaml("_bookdown.yml")
rmd_subdir <- bookdownyaml$rmd_subdir

songs_meta_data_df <- read.csv(file.path(rmd_subdir,"meta_data.csv"))

songbookdownyaml <- read_yaml("_songbookdown.yml")

edit <- bookdownyaml$edit
output_dir <- bookdownyaml$output_dir

if(!is.null(edit)){
  edit2 <- str_remove(edit, "%s")
  
  list.files(output_dir,".html",full.names = TRUE)
  
  songs_meta_data_df %>%
    mutate(html_file = file.path(output_dir,str_replace(basename(rmd_file_name),"\\.Rmd","\\.html"))) %>%
    select(html_file,rmd_file_name,fullpath) %>%
    # slice(1) %->% c(html_file,rmd_file,source)
    pmap(function(html_file,rmd_file_name,fullpath){
      file_exists = file.exists(html_file)
      
      if(file_exists){
        
        
        html_rl <- html_file %>%
          readLines()
        
        html_rl <- str_replace(html_rl, paste0(edit2,rmd_file_name), paste0(edit2,fullpath))
        
        writeLines(html_rl,html_file)
      } else{
        print(paste(html_file,"not found"))
      }
      
    })
}
