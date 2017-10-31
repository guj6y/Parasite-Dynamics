#!/bin/bash

redraw=
convert=
verbose=
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
     -v | --verbose)
         verbose=true
         ;;
    esac
    shift
done
#Option for remaking figures

if [ "$redraw" = true ]; then
    cd ../floats/results
    if [ "$verbose" = true ]; then 
        echo "Making Figures ... "
        latexmk -interaction=batchmode -pdf >> log
        echo "Cleaning up ..."
        latexmk -c
    else
        echo "Making Figures ... "
        latexmk -interaction=batchmode -pdf -silent >> log
        echo "Cleaning up ..."
        latexmk -silent -c
    fi
fi

if [ "$convert" = true ]; then
    echo "Converting to .png ..."
    if [ "$verbose" = true  ]; then
        for pdffile in *.pdf; do
            convert -v -density 500 "${pdffile}" "${pdffile%.*}.$graphicsExtension"
        done
    else
        for pdffile in *.pdf; do
        convert -density 500 "${pdffile}" "${pdffile%.*}.$graphicsExtension"
        done
    fi 
    cd ../../Results
    echo "Done with figures."
fi
echo "Typesetting Document as pdf ... "
if [ "$verbose" = true ]; then
    latexmk -interaction=batchmode -pdf -silent >> log
else
    latexmk -interaction=batchmode -pdf >> log
fi

echo "Converting document to .docx ..."

if [ "$verbose" = true ]; then
    for texfile in *.tex; do
        pandoc -v -f latex -t docx -o "${texfile%.*}".docx --bibliography=Bib_green.bib -M link-citations=true "${texfile}"
    done
else
    for texfile in *.tex; do
        pandoc -f latex -t docx -o "${texfile%.*}".docx --bibliography=Bib_green.bib -M link-citations=true "${texfile}"
    done
fi
echo "Cleaning up ..."
#latexmk -silent -c
