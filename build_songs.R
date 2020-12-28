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
library(glue)

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


################################################################################
## Songs to RMarkdown ##########################################################
################################################################################


## Functions ###################################################################


# Gets the position of the yaml inline header by searching for the first 
# two occurences of "---"
yaml_headerpos <- function(input){
  which(str_detect(input, "---+"))[1:2]
}

# reads the inline / header yaml
read_yamlheader <- function(input,isfile = TRUE){
  if(isfile) input <- readLines(input)
  start_stop <- yaml_headerpos(input)
  yamldata <- yaml.load(input[(start_stop[1]+1):(start_stop[2]-1)])
  yamldata
}

# Creates the song's chapter name
create_songtitle <- function(title,song_tag,artist = NULL,level = 2){
  paste0(
    paste(rep("#",level),collapse = ""),
    " ",
    title,
    ifelse(is.null(artist),"",paste0(" - ",artist)),
    paste0(" {",song_tag,"}")
  )
}

# trims leading and/or trailing elements that are equal to "compare"
trim_lines <- function(char_vec, compare = ""){
  leading <- cumsum(char_vec != compare) == 0
  trailing <- rev(cumsum(rev(char_vec) != compare)) == 0
  char_vec[!(leading | trailing)]
}

mypad <- function(input, by){
  paste0(str_pad(input,by,pad = "0"),"_")
}


create_glossary <- function(df, sortcol, output_type){
  df <- df[order(df[,sortcol]),]
  if(output_type == "html"){
    df <- transmute(df, Title = glue::glue("[{title}]({label})"), Artist = artist)
    kableExtra::kable(df, format = "html",escape = FALSE)
  } else if (output_type == "latex") {
    df <- transmute(df, Title = title, Artist = artist, Page = glue::glue("\\pageref{{{str_remove(label,'#')}}}"))
    kable(df, format = "latex",escape = FALSE,align = c("l","l","r"),longtable = TRUE,booktabs  = TRUE)
  }
}

glossary_chunk <- function(output_type,glossary){
  c(
    "",
    glue::glue("```{{asis, echo = (output_type == '{output_type}')}}"),
    glossary,
    "```",
    ""
  )
}

glossary_chunk_full <- function(df, sortcol, output_type){
  glossary <- create_glossary(df, sortcol, output_type)
  glossary_chunk(output_type,glossary)
}

## Loop ########################################################################


songbookdownyaml <- read_yaml("_songbookdown.yml")
bookdownyaml <- read_yaml("_bookdown.yml")

rmd_subdir <- bookdownyaml$rmd_subdir
inputdir <- songbookdownyaml$inputdir
subfolders <- songbookdownyaml$subfolders
output_dir <- bookdownyaml$output_dir


if(!dir.exists(rmd_subdir)){dir.create(rmd_subdir)}

for (file in list.files(rmd_subdir,full.names = TRUE)){file.remove(file)}


npad <- ceiling(log10(length(list.files(inputdir,recursive = TRUE))+1))

rmd_file_nr = 0
footer_i = 0

songs_meta_data = list()
song_i = 0
for (dir_i in seq_along(subfolders)){
  
  meta <- subfolders[[dir_i]]
  dir <- names(subfolders)[dir_i]
  
  rmd_file_nr <- rmd_file_nr+1
  
  writeLines(paste("#",meta$title),
             file.path(rmd_subdir,glue::glue("{mypad(rmd_file_nr, npad)}{dir}.Rmd")))
  
  songs <- list.files(file.path(inputdir,dir), pattern = ".txt",full.names = TRUE)
  
  # gives each file an arbitary number 
  songs_numeric <- map_dbl(basename(songs),~mean(utf8ToInt(.x)))
  names(songs_numeric) <- songs
  songs_numeric <- sort(songs_numeric)
  songs <- names(songs_numeric)
  
  
  for (song in songs){
    song_i = song_i + 1
    print(song)
    
    
    song_rl <- song %>%
      readLines(warn = FALSE)
    
    meta_data_directives <- map(read_yamlheader(song_rl,FALSE),as.character)
    
    start_stop <- yaml_headerpos(song_rl)
    song_rl <- song_rl[-(start_stop[1]:start_stop[2])]
    
    
    song_rl <- c("",trim_lines(song_rl, ""))
    
    split(song_rl, cumsum(song_rl == "")) %>%
      map(function(song_part){
        song_part <- trim_lines(song_part)
        part_class <- str_match(song_part[1],"\\{start_of_(\\w+)\\}")[,2]
        out <- if(all(song_part ==  "{bridge}")){
          "play bridge"
        } else if(all(song_part ==  "{chorus}")){
          "play chorus"
        } else if(is.na(part_class)){
          c(
            "```",
            song_part,
            "```"
          )
        } else{
          c(
            paste0("```{class='",part_class,"'}"),
            song_part[2:(length(song_part)-1)],
            "```"
          )
        }
        c(out,"")
      }) %>%
      unlist() %>%
      set_names(NULL) -> song_rl
    
    song_tag <- paste0("#song", song_i)

    song_header <- create_songtitle(meta_data_directives$title,song_tag,meta_data_directives$artist)
  
    song_rl <- c(song_header,
                 "",
                 song_rl
                 )
    
  
    meta_data_directives_other <- meta_data_directives[!names(meta_data_directives) %in% c("title","artist","pdf","image")]
    
    if(length(meta_data_directives_other)>0){
      meta_pander <- meta_data_directives_other %>%
        imap_dfr(~data.frame(key = .y,val = as.character(.x))) %>%
        knitr::kable(col.names = c("",""),format = "pandoc") 
      
      
      song_rl <- c(song_rl,"",meta_pander)
    }
    
    rmd_file_nr <- rmd_file_nr+1
    
    song_bn <- basename(song)
    
    rmd_file_name <- file.path(rmd_subdir,paste0(mypad(rmd_file_nr,npad), str_replace(song_bn,".txt",".Rmd")))
    
    writeLines(song_rl,rmd_file_name)

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

c("# Glossary",
  "",
  "```{r, echo = FALSE}",
  "output_type <- knitr::opts_knit$get('rmarkdown.pandoc.to')",
  "```",
  "",
  "## By Title",
  glossary_chunk_full(songs_meta_data_df, "title", "html"),
  glossary_chunk_full(songs_meta_data_df, "title", "latex"),
  "## By Artist",
  glossary_chunk_full(songs_meta_data_df, "artist", "html"),
  glossary_chunk_full(songs_meta_data_df, "artist", "latex")
) %>%
  writeLines(paste0(rmd_subdir,"/",mypad(rmd_file_nr,npad),"glossary.Rmd"))
