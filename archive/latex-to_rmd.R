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





songs <- c("01_Selected_Songs.Rmd",
           "songs/wagon_wheel.Rmd",
           "songs/viva_la_vida.Rmd",
           "songs/suzanne.Rmd",
           "songs/new_slang.Rmd",
           "songs/jar_of_hearts2.Rmd",
           "songs/i_will_follow_you_into_the_dark.Rmd",
           "songs/build_me_up_buttercup.Rmd",
           "songs/hallelujah.Rmd",
           "songs/mad_world.Rmd",
           "songs/dance_me_to_the_end_of_love.Rmd",
           "songs/windows_in_paradise.Rmd",
           "songs/all_the_world_is_green.Rmd", # braucht noch akkorde
           # everything michael buble
           
           "02_Classics.Rmd",
           "songs/lemon_tree.Rmd",
           "songs/boulevard_of_broken_dreams.Rmd",
           "songs/wind_of_change.Rmd", # hat noch tabs?
           "songs/calafornia_dreaming.Rmd",
           "songs/house_of_the_rising_sun.Rmd",
           "songs/blowing_in_the_wind.Rmd",
           "songs/streets_of_london.Rmd",
           "songs/where_have_all_the_flowers_gone.Rmd",
           "songs/sound_of_silence.Rmd",
           "songs/dust_in_the_wind.Rmd",
           "songs/sweet_home_alabama.Rmd",
           # leaving on a jet plane
           # bad moon rising?
           # hotel California
           # let it be? / 
           # Layla?
           # your song
           # yesterday
           # take me home country roads
           # crocodile rock
           # breakfast in America
           # California dreaming
           # morning has broken
           # father and son
           # lady in black
           # San Francisco
           # stand by me
           # candle in the wind
           # how deep is your love
           # what a wonderful world
           # killing me softly
           # knocking on heavens door
           # nights in white satin
           # i'm gonna be 500 miles
           # tears in heaven / eternal flame
           
           #"03_Kinderlieder.Rmd",
           # hey pipi langstrumpf
           # Schlaf anne
           # Sunnestrahl
           
           "04_Deutsch.Rmd",
           "songs/so_kleine_haende.Rmd",
           "songs/s_zundhoelzli.Rmd",
           "songs/heidi.Rmd",
           "songs/dr_alpeflug.Rmd",
           "songs/alls_wo_mir_id_finger_chunnt.Rmd",
           "songs/bim_coiffeur.Rmd",
           "songs/hemmige.Rmd",
           "songs/dr_wecker.Rmd",
           "songs/arabisch.Rmd",
           "songs/eskimo.Rmd",
           "songs/nueni_tramm.Rmd",
           "songs/bergvagabunden.Rmd",
           "songs/ein_bett_im_kornfeld.Rmd",
           "songs/der_traum_vom_fliegen.Rmd",
           "songs/das_testament.Rmd",
           "songs/sie_hoert_musik_nur_wenn_sie_laut_ist.Rmd",
           "songs/kaspar.Rmd",
           "songs/heute_hier_morgen_dort.Rmd",
           
           #\chapter{Tabs}
           #"songs/mad_world_tabs.Rmd",
           #"songs/godfather.Rmd",
           #"songs/all_my_loving.Rmd",
           #"songs/blackbird_tabs.Rmd",
           
           
           
           
           "05_Weihnachtslieder.Rmd",  
           # in der weihnachtsb?ckereki
           #\input{eine_muh_eine_maeh}
           "songs/silent_night.Rmd",
           # go tell it on the mountain
           "songs/oh_holy_night.Rmd",
           "songs/marys_bornchild.Rmd",
           "songs/oh_come_all_ye_faithful.Rmd",
           "songs/the_first_noel.Rmd",
           "songs/leise_rieselt_der_schnee.Rmd",
           "songs/ihr_kinderleit_kommet.Rmd",
           "songs/suesser_die_glocken_nie_klingen.Rmd",
           "songs/am_weihnachtsbaume_die_lichter_brennen.Rmd",
           "songs/oh_du_froehliche.Rmd",
           "songs/oh_tannenbaum.Rmd",
           "songs/kommet_ihr_hirten.Rmd"
)
vec <- character()
for (song in songs){
  song_rl <- readLines(song)
  song_bn <- basename(song)
  if(dirname(song) == "songs"){
   
    print("song")
    song_txt <- str_replace(song_bn,".Rmd",".txt")
    song_md <- str_replace(song_bn,".Rmd",".md")
    
    
    
    
    fileConn<-file(paste0("songs_txt/",song_txt))
    
    title_bool <- song_rl %>%
      str_detect("##") 
    
    title <- song_rl[title_bool]
    
    chunk <- c(title,"",paste0("```{r child = '","songs_md/",song_md,"'}"),"```","")
    
    vec <- append(vec,chunk)
    chunk_bool <- song_rl %>%
      str_detect("```")
    
    song_clean <- song_rl[!chunk_bool & !title_bool]
    
    writeLines(song_clean,fileConn)
    
    close.connection(fileConn)
  } else{
    print("maintitle")
    maintitle <- str_detect(song_rl,"#")%>%
      song_rl[.]
    
    chunk <- c("",maintitle,"","")
    vec <- append(vec,chunk)
  }
  
}


fileConn<-file("all.Rmd")

writeLines(vec,fileConn)



