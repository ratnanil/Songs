

## How do I add a new song?

1. Create a \*.qmd file in one of the available subfolders. 
2. Add a yaml header to the file.
  - Mandatory field(s): `title`
  - Optional field(s): `capo`, `year`, `artist`, `time`, `source` and `tempo`(bpm) (see [chordpro](https://www.chordpro.org/chordpro/chordpro-directives/))
3. Wrap chorus between 
   ```
   :::{.chorus}
   California dreamin  (California dreamin')
   ...
   :::
   ```
4. Add the path to the \*.qmd file to `_quarto.yml`
5. *Play the song*


## How does this book work?

(*For future me, what are the components that make this book work?*)

I've had many iterations of this book. Initially in 2011, I stared out using Latex with the [songbook package](https://songs.sourceforge.net/index.html). I switched to Lynx at some point and just copy and pasted songs and displayed them in vertabim / monospaced fonts. This was all pdf based, so after a couple of years I switched to [bookdown ](https://bookdown.org/) which could create both html and pdf outputs. I even created an R Package based on bookdown (`songbookdown`), but found it too much work to maintain. I then quickly switched to the newly released software [quarto](https://quarto.org/) and am very happy with the current status. I try to keep work on my side minimal and leverage pandoc extensions and lua filters to do the heavy lifting. I also try to keep the source files as simple as possible, so I can continue to copy and paste songs from popular websites without having to manually adjust them to my schema.

I use the following tricks to generate the book:


### Monospaced fonts

Since chords and text appear on seperate lines, the font needs to be monospaced so that they are aligned correctly. See `_quarto.yml`
- pdf: `mainfont: FreeMono` 
- html: `font-family: 'Roboto Mono', monospace;`

### Respect soft line breaks

Since chords and text area only seperated by single linebreaks, i needed to activate the extension `hard_line_breaks` (see `_quarto.yml` `from`)

### Ignore multiple dashes 

Since tabs sometimes rely on multiple dashes (-), and the extension `smart` interprets two dashes (--) as an emdash, I needed to deactivate this extension (see `_quarto.yml` `from`)

### Ignore multiple spaces

Since chords have multiple spaces to align them to the right place in the text, i need spaces to be respected. To enable this, I created a preprocessor to replace all double spaces with no break spaces (see `preprocessor.sh`)

### Start on left / right depending if the pages are even / odd

For pdf, I want to make sure that even-paged-songs start on the left page, and odd-paged-songs appear on any page. 

- I therefore switched to document class `memoir`, which has the options `openright` AND `openleft` (other latex classes seem only to have `openright` and `openany`). 
- I additionally implemented [an SO solution](https://tex.stackexchange.com/questions/66278/chapters-that-openleft-unless-the-chapter-is-only-one-page-long?rq=1) where the number of pages per chapter is counted, and if this number is odd, the chapter is started on an odd page and vise versa.

### Prevent page breaks within verses / choruses etc. 

For pdf output, I added `\widowpenalties` 1 10000 and `\raggedbottom` to the preamble to prevent page breaks within paragraphs, i.e. verses.

### Highlight the chorus

I want to easily highlight the chorus using markdown. 

- To do so, I installed the extension `latex-environment` with
```sh
quarto install extension quarto-ext/latex-environment`
```

- I then added the following to _quarto.yml
```
filters:
  - latex-environment
environments: [chorus]
```

- Now, using the following syntax, I can easily add specify a chorus using the following syntax:
```
:::{.chorus}
California dreamin  (California dreamin')
:::
```

- This will create a latex environment named chorus (it will also create a div (?) with the class "chorus"):
```
\begin{chorus}
California dreamin  (California dreamin')
\end{chorus}
```

- This is not a valid latex environment *yet*. To make it so, I use the package `tcolorbox`. With the following three lines, I add create an evironment named chorus
```
\usepackage{tcolorbox}
\tcbuselibrary{skins} % optional I think
\newtcolorbox{chorus}[1][Chorus]{left*=0mm,grow to left by=2mm,fonttitle=\small,title=#1}
% [1] means 1 optional argument (the title, where the default is "Chorus")
```
- With a clever interplay of the lua filter, html, css and latex, I can do the following: Pass an option writing `:::{.chorus options="option"}`.
  - The `tcolorbox` based environment `chorus` will interprete this as a custom title (e.g. `bridge`). 
  - In html, this option will be stored as an attribute to the div (`data-options="bridge"`). The appropriate html selecters will use this attribute as `content`. If no such attribute is present, it will default to `chorus` as content.



## (further) notes to self

I dont want this book to become more complex that it already is. However, it's hard not to leverage *even more* of the power behind pandoc. For example, somebody built a lua filter that I could simply integrate into this book to generate chord diagrams for selected songs. More on this below.


### lua filter `lilypond`

Lilypond is a huge software for music notation. It does far more that I will *ever* need, but some subsets of the program might be interesting. What makes lilypond great is the fact that it is a text based command line program [for which someone built a lua filter](https://github.com/pandoc/lua-filters/tree/master/lilypond) that can be included in pandoc. For example, assume the following lines are stored in a file named `fretboard.md` (taken from [here](https://lilypond.org/doc/v2.22/Documentation/snippets-big-page#fretted-strings-barres-in-automatic-fretboards)):


``` 
---
lilypond:
  relativize: yes
---

```{.lilypond .ly-fragment ly-caption="A nice caption" ly-name="fretboard"}
\new FretBoards {
  <f, c f a c' f'>1
}
```

With the command `pandoc --lua-filter=lilypond.lua --extract-media=. --output=fretboard.html fretboard.md`, this file can be translated to html. For the sake of brevity, I will show here the output when converting it to a different markdown. Converting the file above with the following command `pandoc --lua-filter=lilypond.lua --output=fretboard2.md fretboard.md` will produce the following output:


```
![A nice
caption](./fretboard.png "\new FretBoards { <f, c f a c' f'>1 }"){.lilypond-image-standalone}
```

where as fretboard.png is the following image:

![image](https://user-images.githubusercontent.com/12532091/212983581-9e58003a-c443-4f61-9f19-0eaa16b7d340.png)

(the fretboard is very pixallated since its only a tiny portion of a large image, I would need to debug this first).

