#!/bin/env bash

imagefile="/tmp/sloppy.$RANDOM.png"
text="/tmp/translation"
echo "$imagefile"
slop=$(slop -f "%g") || exit 1
read -r G <<< $slop
import -window root -crop $G $imagefile
tesseract $imagefile $text 2>/dev/null 
cat $text.txt | xsel -bi  ##### xclip -selection c
