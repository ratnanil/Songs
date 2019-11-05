
# About

This is a song book containing chords and lyrics of selected songs. 

# Adding new songs

The default way of adding new songs is adding the plain text file (\*.txt) into the songs_txt folder. When building the book, this file will be converted to an markdown file of the same name (with an \*.md extension). This file can then be included in the index.Rmd via a code junk and the `child = "songs_md/songname.md"` option.

The conversion txt -> md escapes the \* and \_ characters, replaces spaces with `&nbsp;`and adds a trailling `\\` to each line. This makes the file pretty ugly to look at in a plain text editor, but helps to display the chords in the correct places. Important: This document *must* be rendered in a mono-spaced font.

If the automatic translation from txt -> md does not work, the song can be added manually. Maybe the file should *not* be added to `songs_md`, so that this folder is reserved for automatically generated songs and can be disposed of without concern.

# Adding chords to songs

The project includes the library `tabr`, which generates beautiful chord diagrams from vectors with the `plot_chord` function. I've written a rapper around this function named `plot_chords` (note the `s`) which takes a named list `list(chordname = chordspec)` and draws a grid with ca. 4 columns (empty columns when less than 4 chords). 

