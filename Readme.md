

I've implemented following tricks to make this book work:

- Since chords and text appear on seperate lines, the font needs to be monospaced so that they are aligned correctly (see `mainfont: FreeMono` in `_quarto.yml` for pdf and `font-family: 'Roboto Mono', monospace;` for html)
- Since chords and text area only seperated by single linebreaks, i needed to activate the extension `hard_line_breaks` (see `_quarto.yml` `from`)
- Since tabs sometimes rely on multiple dashes (-), and the extension `smart` interprets two dashes (--) as an emdash, I needed to deactivate this extension (see `_quarto.yml` `from`)
- Since chords have multiple spaces to align them to the right place in the text, i need spaces to be respected. To enable this, I created a preprocessor to replace all double spaces with no break spaces (see `preprocessor.sh`)
- For pdf, I want to make sure that even-paged-songs start on the left page, and odd-paged-songs appear on any page. 
  - I therefore switched to document class `memoir`, which has the options `openright` AND `openleft` (other latex classes seem only to have `openright` and `openany`). 
  - I additionally implemented [an SO solution](https://tex.stackexchange.com/questions/66278/chapters-that-openleft-unless-the-chapter-is-only-one-page-long?rq=1) where the number of pages per chapter is counted, and if this number is odd, the chapter is started on an odd page and vise versa.
- For pdf output, I added `\widowpenalties` 1 10000 and `\raggedbottom` to the preamble to prevent page braks within paragraphs, i.e. verses.


Syntax:

- To add a song, i need to create a \*.qmd file in one of the available subfolders. 
- The song needs a title and can have other meta data (which one day I want to display in the book) such as `capo`, `year`, `artist`, `time`, and `source`
- If the Song has a chorus (or something else to be highlighted), place it in between `:::{.callout appearance="minimal"}` and `:::`
- add the path to the \*.qmd file to `_quarto.yml`
- Play the song
