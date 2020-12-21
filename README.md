
# About

This is a song book containing chords and lyrics of selected songs, generated using R, RMarkdown and Bookdown.

# FAQ

## How do I request new songs?

### Option 1 (if you are not familiar with git):

Submit a request via [an issue](https://github.com/ratnanil/Songs/issues). If you add multiple songs to in request, you can use the tickbox list (see below):

```
- [ ] Song1
- [ ] Song2
``` 

### Option 2 (you *are* familiar with git):

Fork the repo and make a pull request with your additions


## How do I add a new song?

Add a plain text file (mysong.txt) into one of the subfolders of `01_songs_input`. Generating the (html- / pdf-) outputs is an custom implementation of the [chordpro](https://www.chordpro.org/)-markup syntax. For example, each song *needs* a title element (`{title: XY}`), artist information (`{artist: XY}`) and source (`{source: XY}`) are recommended.


## How do I add a new chapter into the book?

Create a subfolder in the `01_songs_input` folder. Add the name of the folder to `subfolders:` in `_songbookdown.yml` and add a title.

```
subfolders: 
  mynewfolder:
    title: The title of the new chapter (required) 
    description: |
      An optional description
      that can span over muliple lines
      (currently this description is not used anywhere,
      but will be implemented in the near future)
```


## What are the basics of the [chordpro](https://www.chordpro.org/)-markup syntax?

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

In addition, there are a number of so called "directives" that can be added to a song. These are described here: https://www.chordpro.org/chordpro/chordpro-directives/, not all are currently implemented.

## Which directives are implemented?

Most [Meta-data and Environment directives](https://www.chordpro.org/chordpro/chordpro-directives/) as listed below. 

- [x] `{title: ...}`
- [x] `{subtitle: ...}`
- [x] `{artist: ...}`
- [x] `{composer: ...}`
- [x] `{lyricist: ...}`
- [x] `{copyright: ...}`
- [x] `{album: ...}`
- [x] `{year: ...}`
- [x] `{key: ...}`
- [x] `{time: ...}`
- [x] `{tempo: ...}`
- [x] `{duration: ...}`
- [x] `{capo: ...}`
- [ ] ~`{meta: name value}`~
- [x] *custom directive*: `{source: ...}` (usually a URL)


[Environment directives](https://www.chordpro.org/chordpro/directives-env/) (only the "long forms" are implemented, not the short forms)

- [x] `{start_of_chorus}`
- [x] `{end_of_chorus}`
- [ ] ~`{chorus}`~
- [x] `{start_of_verse}`
- [x] `{end_of_verse}`
- [x] `{start_of_bridge}`
- [x] `{end_of_bridge}`
- [x] `{start_of_tab}`
- [x] `{end_of_tab}`
- [x] `{start_of_grid}`
- [x] `{end_of_grid}`

As in the chordpro specification, all environment directives may include an optional label to identify the section. For example: `{start_of_verse: Verse 1}` The label should not include special characters and must be seperated from the `:` with a space.

## How do I add chords to songs?

This feature is currently not active. 

~The project includes the library `tabr`, which generates beautiful chord diagrams from vectors with the `plot_chord` function. I've written a rapper around this function named `plot_chords` (note the `s`) which takes a named list `list(chordname = chordspec)` and draws a grid with ca. 4 columns (empty columns when less than 4 chords).~


## I added songs, how can I compile the html / pdf output?

The outputs are compiled in an R Sesseion, which is automated with a [github action](https://github.com/ratnanil/Songs/actions). Outputs (html and pdf) are recomplied at every push.


## I am a maintainer: How do I merge pull requests?


To merge branch `branch1` from remote `origin`:

```

git fetch origin branch1
git checkout master # if you aren't on master branch yet
git merge origin/branch1

```

