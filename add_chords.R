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