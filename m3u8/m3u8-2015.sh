#!/bin/bash

OUTPUT_DIR=~/Documents/Github/WWDC-Videos/m3u8/2015
if [ ! -d "${OUTPUT_DIR}" ]
then
	mkdir -pv ${OUTPUT_DIR}
fi

curl -s https://developer.apple.com/videos/wwdc2015/ \
	| grep '/videos/play/wwdc[0-9]\{4\}-' \
	| awk -F'href="' '{print $2}' | awk -F'"' '{print $1}' \
	| sort | uniq | while read path
do
	id=$(echo ${path} | awk -F'-' '{print $2}' | awk -F'/' '{print $1}')
	url="https://developer.apple.com${path}"
	curl -s ${url} -o data.txt
	m3u8=$(cat data.txt | grep '\.m3u8' | awk -F'"' '{print $2}' | awk -F'"' '{print $1}')
	name=$(cat data.txt | grep '</h3>' | awk -F'>' '{print $2}' | awk -F'<' '{print $1}')
	file=${OUTPUT_DIR}/${id}.m3u8
	curl -s ${m3u8} -o ${file}
	echo -e "\n#VIDEO-INFO:M3U8=${m3u8},NAME=\"${name}\"" >> ${file}
	echo -e "[${id}-${name}]\n  ${m3u8} -> ${file}"
done

rm -f data.txt