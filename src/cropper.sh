#!/bin/bash
rm -f *crop.pdf
for FILE in `ls *.pdf`
do
  pdfcrop $FILE
done
