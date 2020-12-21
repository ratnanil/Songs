
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

Add a plain text file (mysong.txt) into one of the subfolders of `01_songs_input`. Add song meta data in a yaml-header similar to RMarkdown yaml headers in the following form:

```
---
title: Here Comes the Sun
artist: the Beatles
year: 1969
---

Here comes the sun
Doo doo doo doo
Here comes the sun and I say
It's alright
...
```

A `title` is requied, `artist` and `source` are recommended. Here is a list of typical metadata added to the header:

- `title:`
- `subtitle:`
- `artist:`
- `composer:`
- `lyricist:`
- `copyright:`
- `album:`
- `year:`
- `key:`
- `time:`
- `tempo:`
- `duration:`
- `capo:`
- `source:`

## What about the rest of the song? 

Add the rest of the song in plain text. It will be rendered into a monospaced font where lines are not broken. The reasoning behind this is that you can copy and paste plain text songs from sources like ultimate-guitar.com where monospacing helps keep chords and text aligned. 

You add further structure to the song in a [chordpro](https://www.chordpro.org) type manner. From the chord pro syntax, the following [environment directives](https://www.chordpro.org/chordpro/directives-env/) are implemented<sup>1</sup>

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

<sup>1</sup>(only the "long forms" are implemented, not the short forms)


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



## How do I add chords to songs?

This feature is currently not active. 

~The project includes the library `tabr`, which generates beautiful chord diagrams from vectors with the `plot_chord` function. I've written a rapper around this function named `plot_chords` (note the `s`) which takes a named list `list(chordname = chordspec)` and draws a grid with ca. 4 columns (empty columns when less than 4 chords).~


## I added songs, how can I compile the html / pdf output?

The outputs are compiled in an R Sesseion, which is automated with a [github action](https://github.com/ratnanil/Songs/actions). Outputs (html and pdf) are recomplied at every push.


## I am a maintainer: How do I merge pull requests?


To merge branch `branch1` from remote `origin`:

```
git diff ...origin/branch1 # to check the differences between the master and the branch
git fetch origin branch1
git checkout master # if you aren't on master branch yet
git merge origin/branch1

```

