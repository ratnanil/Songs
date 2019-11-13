
# About

This is a song book containing chords and lyrics of selected songs. 

# Adding new songs

The default way of adding new songs is adding the plain text file (\*.txt) into a subfolder of the songs_cho folder. The subfolder needs to contain a \*.yml file with the title of the chapter (without this yaml file, the data within the subfolder is ignored). The title will be used to generate a level 1 header of the same name.

You'll have to add some markup syntax in the [chordpro](chordpro.org) style.

- Title (`{title: XY}`, obligatory)
- Wrap all overline chords with brackets (e.g. `[G]`) *but keep the chords on a seperate line (not inline)*
- Wrap grids with the appropriate directive (`{start_of_grid}` / `{end_of_grid}`)
- Remove all unintended markup syntax: 
  - \* 
  - \_ (allowed within `*_grid` and `*_tab`)
  - brackets \[ \] are only allowed for chords outside of `*_grid` and `*_tab`

When building the book, these file will be converted to Rmd files. 

# Adding chords to songs

The project includes the library `tabr`, which generates beautiful chord diagrams from vectors with the `plot_chord` function. I've written a rapper around this function named `plot_chords` (note the `s`) which takes a named list `list(chordname = chordspec)` and draws a grid with ca. 4 columns (empty columns when less than 4 chords). 

