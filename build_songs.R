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
library(magrittr)
library(knitr)
library(yaml)

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
  chordpro_tags <- c("title", "subtitle", "artist", "composer", "lyricist", "copyright", "album", "year", "key", "time", "tempo", "duration", "capo")  
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

# Takes a vector of characters strings and a directives tags and returns a named 
# list of directive-values as well as a vector of indices of positions where these
# where detected.

match_directives <- function(lines,
                             tags = c("title", "subtitle", "artist", "composer", "lyricist", "copyright", "album", "year", "key", "time", "tempo", "duration", "capo", "meta","source","pdf","image"),
                             include_indices = TRUE
                             ){
  require(stringr)
  require(purrr)
  mat <- str_match(lines, paste0("\\{(",paste(tags,collapse = "|"),"):\\s(.+)\\}"))
  rows <- !is.na(mat[,1])
  
  mat <- mat[rows,,drop=FALSE]
  
  lis <- map(mat[,3],~.x) %>%
    magrittr::set_names(mat[,2])
  
  if(include_indices) lis[["row_indices"]] <- which(rows)
  
  lis
}

# Gets the position of the yaml inline header by searching for the first 
# two occurences of "---"
yaml_headerpos <- function(input){
  which(str_detect(input, "---"))[1:2]
}

# reads the inline / header yaml
read_yamlheader <- function(input,isfile = TRUE){
  if(isfile) input <- readLines(input)
  start_stop <- yaml_headerpos(input)
  yamldata <- yaml.load(input[(start_stop[1]+1):(start_stop[2]-1)])
  yamldata
}

songbookdownyaml <- read_yaml("_songbookdown.yml")
bookdownyaml <- read_yaml("_bookdown.yml")

rmd_subdir <- bookdownyaml$rmd_subdir
inputdir <- songbookdownyaml$inputdir
subfolders <- songbookdownyaml$subfolders
output_dir <- bookdownyaml$output_dir


if(!dir.exists(rmd_subdir)){dir.create(rmd_subdir)}

for (file in list.files(rmd_subdir,full.names = TRUE)){file.remove(file)}


npad <- ceiling(log10(length(list.files(inputdir,recursive = TRUE))))


rmd_file_nr = 0
footer_i = 0

songs_meta_data = list()
song_i = 0
for (dir_i in seq_along(subfolders)){
  
  meta <- subfolders[[dir_i]]
  dir <- names(subfolders)[dir_i]
  
  rmd_file_nr <- rmd_file_nr+1
  rmd_file_nr_chr <- paste0(str_pad(rmd_file_nr,npad,pad = "0"),"_")
  
  
  fileConn<-file(paste0(rmd_subdir,"/",rmd_file_nr_chr, dir,".Rmd"))
  
  paste("#",meta$title) %>%
    writeLines(fileConn)
  
  close.connection(fileConn)
  
  songs <- list.files(file.path(inputdir,dir), pattern = ".txt",full.names = TRUE)
  
  # gives each file an arbitary number 
  songs_numeric <- map_dbl(basename(songs),~mean(utf8ToInt(.x)))
  names(songs_numeric) <- songs
  songs_numeric <- sort(songs_numeric)
  songs <- names(songs_numeric)
  
  
  for (song in songs){
    song_i = song_i + 1
    print(song)
    
    song_bn <- basename(song)
    
    song_rl <- song %>%
      readLines(warn = FALSE)
    
    start_and_ends <- c("chorus","verse","bridge","tab","grid")
    
    
    
    start_end_res <- str_match(song_rl,paste0("\\{(start|end)_of_(",paste(start_and_ends,collapse = "|"),"):?\\s?(.+)?\\}"))
    
    start_end_idx <- list(start = which(start_end_res[,2] == "start"),
                          end = which(start_end_res[,2] == "end"))
    
    if(length(start_end_idx$start)>0){
      pmap(start_end_idx, function(start,end){
        song_rl[start:end] <<- paste0("  ",song_rl[start:end])
        song_rl
      })
      
      start_labels <-  ifelse(start_end_res[,2] == "start",
                              str_to_title(paste0(str_replace(start_end_res[,3],"grid","chords"), ifelse(!is.na(F),paste0(" (",start_end_res[,4],")"),""))),NA)
      
      song_rl[start_end_idx$start] <- str_to_title(paste0(
        str_replace(start_end_res[start_end_idx$start,3],"grid","chords"),
        ifelse(!is.na(start_end_res[start_end_idx$start,4]),
               paste0(" (",start_end_res[start_end_idx$start,4],")"),
               ""
        ),
        ":"
      )) 
      
      song_rl <- song_rl[-start_end_idx$end]
    }
    
    meta_data_directives <- read_yamlheader(song_rl,FALSE)
    # meta_data_directives <- match_directives(song_rl)
    
    # song_rl <- song_rl[-c(meta_data_directives$row_indices)]
    start_stop <- yaml_headerpos(song_rl)
    song_rl <- song_rl[-(start_stop[1]:start_stop[2])]
    
    # meta_data_directives[["row_indices"]] <- NULL
    
    
    if("source" %in% names(meta_data_directives)){
      footer_i = footer_i+1
      
      footer_tag <- paste0("[^",footer_i,"]")
    }
    
    
    song_tag <- paste0("#song", song_i)
    
    
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
             ,""),
      ifelse("source" %in% names(meta_data_directives),footer_tag,""),
      paste0(" {",song_tag,"}")
    )
    
    
    pdf_chunk <- if ("pdf" %in% names(meta_data_directives)) {
      
      pdf_path <- file.path(output_dir,meta_data_directives$pdf)
      c("```{r, eval = TRUE,results='asis'}",paste0("cat('<embed src=\"",meta_data_directives$pdf,"\" width=\"100%\" height=\"800\" type=\"application/pdf\">')"), "```")
    } else{""}
    
    
    song_rl <- c(song_header,
                 "",
                 ifelse("source" %in% names(meta_data_directives),paste0(footer_tag,": ",meta_data_directives$source),""), 
                 "",
                 "```", 
                 song_rl,
                 "```",
                 pdf_chunk
                 )
    
    
    meta_data_directives_other <- meta_data_directives[!names(meta_data_directives) %in% c("title","artist","year","source","pdf","image")]
    
    if(length(meta_data_directives_other)>0){
      meta_pander <- meta_data_directives_other %>%
        imap_dfr(~data.frame(key = .y,val = .x)) %>%
        knitr::kable(col.names = c("",""),format = "pandoc") 
      
      
      song_rl <- c(song_rl[1:2],meta_pander,song_rl[3:length(song_rl)])
    }
    
    rmd_file_nr <- rmd_file_nr+1
    rmd_file_nr_chr <- paste0(str_pad(rmd_file_nr,npad,pad = "0"),"_")
    
    rmd_file_name <- file.path(rmd_subdir,paste0(rmd_file_nr_chr, str_replace(song_bn,".txt",".Rmd")))
    fileConn<-file(rmd_file_name)
    
    writeLines(song_rl,fileConn)
    close(fileConn)
    
    song_meta_data <- meta_data_directives
    song_meta_data["label"] <- song_tag
    song_meta_data["source"] <- song
    song_meta_data["rmd_file"] <- rmd_file_name
    
    songs_meta_data[[song_i]] <- song_meta_data
  }
  
  
  
}




songs_meta_data_df <- map_dfr(songs_meta_data,~as.data.frame(.x))

write.csv(songs_meta_data_df, file.path(rmd_subdir,"meta_data.csv"))

rmd_file_nr <- rmd_file_nr+1
rmd_file_nr_chr <- paste0(str_pad(rmd_file_nr,npad,pad = "0"),"_")

glossary1_html <- paste0(rmd_subdir,"/",rmd_file_nr_chr,"glossary1.html")
glossary1_pdf <- paste0(rmd_subdir,"/",rmd_file_nr_chr,"glossary1.tex")

songs_meta_data_df %>%
  arrange(title) %>%
  transmute(Title = paste0("[",title,"](",label,")"),Artist = artist) %>% 
  kable(format = "html", escape = FALSE) %>%
  writeLines(glossary1_html)


songs_meta_data_df %>%
  arrange(title) %>%
  transmute(Title = title, Artist = artist, Page = paste0("\\pageref{",str_remove(label,"#"),"}")) %>%
  kable(format = "latex",escape = FALSE,align = c("l","l","r"),longtable = TRUE,booktabs  = TRUE) %>%
  writeLines(glossary1_pdf)


glossary2_html <- paste0(rmd_subdir,"/",rmd_file_nr_chr,"glossary2.html")
glossary2_pdf <- paste0(rmd_subdir,"/",rmd_file_nr_chr,"glossary2.tex")

songs_meta_data_df %>%
  arrange(artist) %>%
  filter(!is.na(artist)) %>%
  transmute(Artist = artist, Title = paste0("[",title,"](",label,")")) %>% 
  kable(format = "html", escape = FALSE) %>%
  writeLines(glossary2_html)


songs_meta_data_df %>%
  arrange(artist) %>%
  filter(!is.na(artist)) %>%
  mutate(label = str_remove(label,"#")) %>%
  transmute(Artist = artist, Title = paste0("\\hyperref[",label,"]{",title,"}"), Page = paste0("\\pageref{",label,"}")) %>%
  kable(format = "latex",escape = FALSE,align = c("l","l","r"),longtable = TRUE,booktabs  = TRUE) %>%
  writeLines(glossary2_pdf)

# \hyperref[sec:intro]{Appendix~\ref*{sec:intro}}

c("# Glossary",
  "```{r, echo = FALSE}",
  "library(knitr)",
  "output_type <- knitr::opts_knit$get('rmarkdown.pandoc.to')",
  "```",
  "",
  "## By Title",
  "",
  paste0("```{r, eval= (output_type == 'html'),results='asis',child = '",glossary1_html,"'}"),
  "```",
  "",
  paste0("```{r, eval= (output_type == 'latex'),results='asis',child = '",glossary1_pdf,"'}"),
  "```",
  "",
  "## By Artist",
  "",
  paste0("```{r, eval= (output_type == 'html'),results='asis',child = '",glossary2_html,"'}"),
  "```",
  "",
  paste0("```{r, eval= (output_type == 'latex'),results='asis',child = '",glossary2_pdf,"'}"),
  "```"
  ) %>%
  writeLines(paste0(rmd_subdir,"/",rmd_file_nr_chr,"glossary.Rmd"))







