

I've implemented following tricks to make this book work:

- Since chords and text appear on seperate lines, the font needs to be monospaced so that they are aligned correctly (see `mainfont: FreeMono` in `_quarto.yml` for pdf and `font-family: 'Roboto Mono', monospace;` for html)
- Since chords and text area only seperted by single linebreaks, i needed to activate the extension `hard_line_breaks` (see `_quarto.yml` `from`)
- Since chords have multiple spaces to align them to the right place in the text, i need spaces to be respected. To enable this, I created a preprocessor to replace all double spaces with no break spaces (see `preprocessor.sh`)
- For pdf, I want to make sure that even-paged-songs start on the left page, and odd-paged-songs appear on any page. To do this, I need to do the following:
  - start every part with the command `\csname @openrighttrue\endcsname` (see [this answer](https://tex.stackexchange.com/questions/208712/how-to-force-only-one-chapter-to-start-on-even-page))
  - list all the even-paged-songs first in `_quarto.yml`
  - end the last two-page-song with `\csname @openrightfalse\endcsname` 
  - then list all the odd-paged-songs
