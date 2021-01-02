# Transform all songs in songs_txt into markdown files

library(dplyr)
library(purrr)
library(yaml)
library(magrittr)
library(knitr)
library(glue)
library(stringr)
library(tidyr)



################################################################################
## Songs to RMarkdown ##########################################################
################################################################################


## Functions ###################################################################


# Gets the position of the yaml inline header by searching for the first 
# two occurences of "---" (three or more dashes accepted)
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
remove_yamlheader <- function(input,isfile = TRUE){
  if(isfile) input <- readLines(input)
  start_stop <- yaml_headerpos(input)
  input[-(start_stop[1]:start_stop[2])]
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


create_glossary <- function(df, output_type){
  if(output_type == "html"){
    df %>%
      transmute(value = glue::glue("[{value}]({song_tag})")) %>%
      kableExtra::kable(format = "html",escape = FALSE,col.names = c(""))
  } else if (output_type == "latex") {
    df %>%
      mutate(
        value = str_replace(value,"\\*(.+)\\*","\\\\emph\\{\\1\\}"),
        song_tag = str_remove(song_tag,"#"),
      ) %>%
      pmap_chr(function(song_tag,value){
        
        pagenumber <- paste0("\\pageref{",song_tag,"}")
        hypervalue <- paste0("\\hyperref[",song_tag,"]{",value,"\\dotfill}")
        paste0(hypervalue,pagenumber,"\n")
      })
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

glossary_chunk_full <- function(df, output_type){
  glossary <- create_glossary(df, output_type)
  glossary_chunk(output_type,glossary)
}


## Get settings from yaml ######################################################

songbookdownyaml <- read_yaml("_songbookdown.yml")
bookdownyaml <- read_yaml("_bookdown.yml")

rmd_subdir <- bookdownyaml$rmd_subdir
output_dir <- bookdownyaml$output_dir


inputdir <- songbookdownyaml$inputdir
subfolders <- songbookdownyaml$subfolders
filetypes <- ifelse(is.null(songbookdownyaml$filetypes),"txt",songbookdownyaml$filetypes)


## Create Folders ##############################################################


if(!dir.exists(rmd_subdir)){dir.create(rmd_subdir)}

for (file in list.files(rmd_subdir,full.names = TRUE)){file.remove(file)}

subfolders_dfr <- imap_dfr(subfolders,function(chapter,folder){
  tibble(chapter = chapter[[1]],
         folder = folder)
}) %>%
  mutate(i = row_number())


## Loop ########################################################################


allfiles <- pmap_dfr(subfolders_dfr, function(chapter,folder,i){
  fullpath <- file.path(inputdir,folder) %>%
    list.files(pattern = paste(filetypes,collapse = "|"),full.names = TRUE)
  
  mylines <- map(fullpath, ~readLines(.x,warn = FALSE))
  
  tibble(fullpath = fullpath, 
         folder = folder, chapter = chapter, chapter_i = i, lines = mylines) 
}) 


metadata_dfr <- map_dfr(allfiles$lines, function(x){
  x %>%
    read_yamlheader(FALSE) %>%
    as_tibble() %>%
    mutate_all(~as.character(.))
})

allfiles <- cbind(allfiles,metadata_dfr)

npad1 <- (length(subfolders)+1) %>% log10() %>% ceiling()
npad2 <- allfiles %>% split(.$folder) %>% map_int(nrow) %>% max() %>% log10() %>% ceiling()


allfiles <- allfiles %>%
  mutate(sortval = map_dbl(fullpath,~mean(utf8ToInt(basename(.x))))) %>%
  arrange(folder,sortval) %>%
  group_by(folder) %>%
  mutate(
    i_file = row_number(),
    rmd_file_prefix = paste0(mypad(chapter_i,npad1),mypad(i_file,npad2))
  ) %>%
  select(-c(i_file,chapter_i,sortval))


allfiles$lines <- map(allfiles$lines,function(song_rl){
  remove_yamlheader(song_rl,FALSE)
})
# Make sure that the first verse / chorus etc starts with an empty line
# and the last ends with an empty line
allfiles$lines <- map(allfiles$lines,function(song_rl){
  c("",trim_lines(song_rl, ""))
})

# wraps each verse/chorus etc with a chunk. 
allfiles$lines <- map(allfiles$lines,function(song_rl){
  split(song_rl, cumsum(song_rl == "")) %>%
    map(function(song_part){
      print(song_part)
      song_part <- trim_lines(song_part)
      directives_regex <- "\\{(start|end)_of_(\\w+)\\}" # todo: implement {start_of_verse: verse 1}
      directivepos <- str_detect(song_part,directives_regex)
      part_class <- unique(str_match(song_part[directivepos],directives_regex)[,3])
      part_class <- ifelse(is.na(part_class),"",paste0(", class = '",part_class,"'"))
      part_class = "" # todo: remove this line and maby test engines?
      song_part <- song_part[!directivepos]
      if(length(song_part)>0){
        c(
          paste0("```{",part_class,"}"),
          song_part,
          "```",
          ""
        )
      }
    }) %>%
    unlist() %>%
    set_names(NULL)
})


# Builds the song chapter name
allfiles <- allfiles %>%
  ungroup() %>%
  mutate(
    song_i = row_number(),
    song_tag = paste0("#song",song_i),
  ) %>%
  rowwise() %>%
  mutate(
    song_header = create_songtitle(title,song_tag,artist)
  )

# Includes the chapter name in the lines
allfiles$lines <- map2(allfiles$lines,allfiles$song_header,function(song_rl,song_header){
  c(song_header,
    "",
    song_rl
  )
})



metadata_other_dfr <- allfiles[,colnames(metadata_dfr)[!colnames(metadata_dfr) %in% c("title","artist")]]


# This is quite an ugly hack, at least give some better names
metadata_other_dfr2 <- metadata_other_dfr %>%
  split(1:nrow(metadata_other_dfr)) %>%
  map(function(x){
    x <- as.list(x)
    any_nonempty <- any(map_lgl(x,function(y){!is.na(y)}))
    list(any_nonempty, x)
  })

allfiles$lines <- map2(allfiles$lines,metadata_other_dfr2, function(song_rl,any_nonempty){
  if(any_nonempty[[1]]){
    meta_pander <- any_nonempty[[2]] %>%
      imap_dfr(~data.frame(key = .y,val = .x) %>% filter(!is.na(.x))) %>%
      knitr::kable(col.names = c("",""),format = "pandoc")
    c(song_rl,"",meta_pander)
  } else{
    song_rl
  }
})


allfiles <- allfiles %>%
  mutate(
    rmd_file_name = file.path(rmd_subdir,paste0(rmd_file_prefix, str_replace(basename(fullpath),".txt",".Rmd")))
  ) 


map2(allfiles$lines,allfiles$rmd_file_name,function(song_rl,rmd_file_name){
  writeLines(song_rl,rmd_file_name)
})


allfiles %>%
  select(-lines) %>%
  write.csv(file.path(rmd_subdir,"meta_data.csv"))


subfolders_dfr %>%
  mutate(filename = paste0(mypad(i,npad1),mypad(0,npad2),folder,".Rmd")) %>%
  select(chapter,filename) %>%
  pmap(function(chapter,filename){
    writeLines(paste("#",chapter),
               file.path(rmd_subdir,filename))
  })


glossary_filename <- paste0(mypad(max(subfolders_dfr$i) + 1,npad1),mypad(0,npad2),"glossary.Rmd")


glossary_keywords <- c("title", "subtitle", "artist", "composer", "lyricist", "album")
glossary_keywords <- glossary_keywords[glossary_keywords %in% colnames(allfiles)]
glossary_df <- allfiles[,c(glossary_keywords,"song_tag")] %>%
  pivot_longer(-c(song_tag,title)) %>%
  filter(!is.na(value)) %>%
  mutate(
    title = paste0("*",title,"*"),
    value = paste0(value, " - ",title)
    ) %>%
  select(-name) %>%
  pivot_longer(c(title,value)) %>%
  select(-name) %>%
  arrange(str_remove(value,"\\*"))

c("# Glossary",
  "",
  "```{r, echo = FALSE}",
  "output_type <- knitr::opts_knit$get('rmarkdown.pandoc.to')",
  "```",
  "",
  glossary_chunk_full(glossary_df, "html"),
  glossary_chunk_full(glossary_df, "latex")
) %>%
  writeLines(file.path(rmd_subdir,glossary_filename))
