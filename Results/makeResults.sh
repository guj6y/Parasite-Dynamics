#!/bin/bash

redraw=
convert=
graphicsExtension=png
while [ "$1" != "" ]; do
    case $1 in
     -r | --redraw)
         redraw=true
         convert=true
         ;;
     -jpg)
         convert=true
         graphicsExtension=jpg
         ;;
     -bmp)
         convert=true
         graphicsExtension=bmp
         ;;
     -g | --graphics-type)
         convert=true
         shift
         graphicsExtension=$1
         ;;
     -c | --forceReConversion)
         convert=true
         ;;
    esac
    shift
done
#Option for remaking figures

if [ "$redraw" = true ]; then
    cd ../floats/results
    echo "Making Figures ... "
    latexmk -interaction=batchmode -pdf -silent > log
    echo "Cleaning up ..."
    latexmk -silent -c
fi

if [ "$convert" = true ]; then
    echo "Converting to .png ..."
    for pdffile in *.pdf; do
        convert -density 500 "${pdffile}" "${pdffile%.*}.$graphicsExtension"
    done
    cd ../../Results
    echo "Done with figures."
fi
echo "Typesetting Document as pdf ... "

latexmk -interaction=batchmode -pdf -silent > log

echo "Converting document to .docx ..."

for texfile in *.tex; do
    pandoc -f latex -t docx -o "${texfile%.*}".docx --bibliography=Bib_green.bib -M link-citations=true "${texfile}"
done

echo "Cleaning up ..."
latexmk -silent -c
