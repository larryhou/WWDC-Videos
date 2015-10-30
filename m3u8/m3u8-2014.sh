#!/bin/bash

# export HTTPS_PROXY=http://web-proxy.oa.com:8080

OUTPUT_DIR=~/Downloads/2014
if [ ! -d "${OUTPUT_DIR}" ]
then
	mkdir -pv ${OUTPUT_DIR}
fi

curl -s https://developer.apple.com/videos/wwdc2014/ | grep 'Session [0-9]\{3,\}' \
	| awk -F'Session ' '{print $2}' | awk -F'<' '{print $1}' | sort | uniq | while read id
do
	url="https://developer.apple.com/videos/play/wwdc2014-${id}"
	ref=$(curl -s ${url} | grep 'ref.mov' | awk -F'"' '{print $2}')
	m3u8=$(echo ${ref} | sed 's/ref.mov/sl2.m3u8/')
	file=${OUTPUT_DIR}/${id}.m3u8
	curl -s ${m3u8} -o ${file}
	echo -e "\n#M3U8-SRC:${m3u8}" >> ${file}
	echo "${m3u8} -> ${file}"
done