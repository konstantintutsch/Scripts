#!/bin/sh

exiftool \
    -all:all= -tagsfromfile @ \
    -exif:Orientation \
    -Artist \
    -Copyright \
    -Title \
    -Description \
    -r -overwrite_original \
    "${1}"
