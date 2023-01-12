

I've implemented following tricks to make this book work:

- Since chords and text appear on seperate lines, the font needs to be monospaced so that they are aligned correctly (see `mainfont: FreeMono` in `_quarto.yml` for pdf and `font-family: 'Roboto Mono', monospace;` for html)
- Since chords and text area only seperted by single linebreaks, i needed to activate the extension `hard_line_breaks` (see `_quarto.yml` `from`)
- Since tabs sometimes rely on multiple dashes (-), and the extension `smart` interprets two dashes (--) as an emdash, I needed to deactivate this extension (see `_quarto.yml` `from`)
- Since chords have multiple spaces to align them to the right place in the text, i need spaces to be respected. To enable this, I created a preprocessor to replace all double spaces with no break spaces (see `preprocessor.sh`)
- For pdf, I want to make sure that even-paged-songs start on the left page, and odd-paged-songs appear on any page. I therefore switched to document class `memoir`, which has the options `openright` AND `openleft` (other latex classes seem only to have `openright` and `openany`). Not only that, but I found [an SO solution](https://tex.stackexchange.com/questions/66278/chapters-that-openleft-unless-the-chapter-is-only-one-page-long?rq=1) where the number of pages per chapter is counted, and if this number is odd, the chapter is started on an odd page and vise versa. This goes a long way towards what I need.

Todo: 
- `:::{.song-chorus}` is seems to be inserterd literaly into the pdf output. It would be much more elegant if paragraphs wrapped in this markdown thingy would be wrapped with `tcolorbox`'s `\begin{tcolorbox}` and `\end{tcolorbox}`. 







An old solution, for the even-page odd-page issue, now depricated, was the following idea:

To do this, I need to do the following:
  - start every part with the command `\csname @openrighttrue\endcsname` (see [this answer](https://tex.stackexchange.com/questions/208712/how-to-force-only-one-chapter-to-start-on-even-page))
  - list all the even-paged-songs first in `_quarto.yml`
  - end the last two-page-song with `\csname @openrightfalse\endcsname` 
  - then list all the odd-paged-songs
