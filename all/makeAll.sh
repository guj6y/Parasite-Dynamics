#!/bin/bash
echo "Reorganizing ..."

cp Intro/*.texIn ./
cp Methods/*.texIn ./
cp Results/*.texIn ./
cp Discussion/*.texIn ./
cp Conclusion/*.texIn ./

echo "Making figures ..."
cd ../floats

for dir in *; do
    echo "for $dir..." 
    cd dir
    latexmk -interaction=batchmode -pdf -silent > log

    echo "Cleaning ..."
    latexmk -silent -c
    
    echo "Converting to .png ..."

    for pdffile in *.pdf; do 
        convert -density 500 "${pdffile}" "{pdffile%.*}".png
    done
    
    cd ..
done
cd ../all
echo "Typsetting Dcoument as pdf ..."
latexmk -interaction=batchmode -pdf -silent >log

echo "Converting pdf to docx ..."
for texfile in $.tex; do
    pandoc -f latex -t docx -o "${texfile%.*}".docx --bibliography=Bib_green.bib -M link-citations=true "${texfile}"
done

echo "Cleaning up ..."
latexmk -silent -c
rm *.texIn
