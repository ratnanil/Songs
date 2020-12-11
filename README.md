
# About

This is a song book containing chords and lyrics of selected songs, generated using R, RMarkdown and Bookdown.

# FAQ

## How do I request new songs?

Submit a request via [an issue](https://github.com/ratnanil/Songs/issues). If you add multiple songs to in request, you can use the tickbox list (see below):

```
- [ ] Song1
- [ ] Song2
``` 

## How do I add a new song?

Add a plain text file (mysong.txt) into one of the subfolders of `songs_cho`. Generating the (html- / pdf-) outputs is an custom implementation of the [chordpro](https://www.chordpro.org/)-markup syntax. For example, each song *needs* a title element (`{title: XY}`), a artist information is recommended.


## How do I add a new chapter into the book?

Create a subfolder in the `songs_cho` folder. Create a file named `meta.yml` containing the title of the chapter. E.g.

```
title: Selected Songs
```


## What are the basiscs of the [chordpro](https://www.chordpro.org/)-markup syntax?

A *normal* chordpro song looks something like this. HOWEVER: In my implementation, the chords are placed *over* the song text, *not* inline! And, they do not necessarly need to be wrapped in brackets (\[ and \])

```
# A simple ChordPro song.

{title: Swing Low Sweet Chariot}

{start_of_chorus}
Swing [D]low, sweet [G]chari[D]ot,
Comin’ for to carry me [A7]home.
Swing [D7]low, sweet [G]chari[D]ot,
Comin’ for to [A7]carry me [D]home.
{end_of_chorus}

I [D]looked over Jordan, and [G]what did I [D]see,
Comin’ for to carry me [A7]home.
A [D]band of angels [G]comin’ after [D]me,
Comin’ for to [A7]carry me [D]home.

{comment: Chorus}
```

In addition, there are a number of so called "directives" that can be added to a song. These are described here: https://www.chordpro.org/chordpro/chordpro-directives/, but only a small portion are currently implemented.

## Which directives are implemented?

- [x] Title
- [x] Artist

I had implemented other directives in the past, which is why you might find them in some of the older additions. Currently, these directives are simply ignored.


## Are there any special character that are not allowed?

No, currently not.

~Yes, and I'm glad you asked! Following characters are not allowed:~

~- \* ~
~- \_ [^1]~
~- \[ and \]~

These character is of course allowed within chordpro directives

## How do I add chords to songs?

This feature is currently not active. 

~The project includes the library `tabr`, which generates beautiful chord diagrams from vectors with the `plot_chord` function. I've written a rapper around this function named `plot_chords` (note the `s`) which takes a named list `list(chordname = chordspec)` and draws a grid with ca. 4 columns (empty columns when less than 4 chords).~


## I added songs, how can I compile the html / pdf output?

Basically, the book is complied in an R Session. This is now automated with a github action, so that the book (html and pdf) is recomplied at every push.

