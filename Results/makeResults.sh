#!/bin/bash

#Option for remaking figures
echo "Making Figures ... "


cd ../floats/methods 

latexmk -interaction=batchmode -pdf -silent > log

echo "Cleaning up ..."

latexmk -silent -c

echo "Converting to .png ..."

for pdffile in *.pdf; do
    convert -density 500 "${pdffile}" "${pdffile%.*}".png
done

cd ../../Methods
echo "Done with figures."
echo "Typesetting Document as pdf ... "

latexmk -interaction=batchmode -pdf -silent > log

echo "Converting document to .docx ..."

for texfile in *.tex; do
    pandoc -f latex -t docx -o "${texfile%.*}".docx --bibliography=Bib_green.bib -M link-citations=true "${texfile}"
done

echo "Cleaning up ..."
latexmk -silent -c
