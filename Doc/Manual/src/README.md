# Markdown-to-SWIG documentation conversion

This directory includes the Markdown source used to generate the Fortran
manual page. There are three steps to convert the Markdown to the properly
formatted `html` file:
1. Run [Pandoc](https://pandoc.org) to generate a generic standalone HTML file.
2. Run the `pandoc2swigman.py` script to add spacing between paragraphs,
   translate `id` to independent `a` anchors, and wrap `pre` with a `div`
   class.
3. Run the `maketoc.py` script to generate the index and update the SWIG manual
   table of contents.
