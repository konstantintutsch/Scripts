#!/bin/bash

if [ -z $1 ] || [ -z $2 ]
then
  echo "$0 source.img destdir"
  exit 1
fi

headrel=""

sizes=(48 96 144 192)
for s in ${sizes[@]}
do
    ffmpeg -y -i "$1" -s "${s}x${s}" "${2}/assets/images/favicon-${s}.png"
    headrel+="<link rel=\"icon\" href=\"/assets/images/favicon-${s}.png\" type=\"image/png\" sizes=\"${s}x${s}\">"
    headrel+=$'\n'
done

echo "

<!-- Icons -->
${headrel}<link rel=\"apple-touch-icon\" href=\"/assets/images/favicon-${sizes[-1]}.png\" type=\"image/png\" sizes=\"${sizes[-1]}x${sizes[-1]}\">"
