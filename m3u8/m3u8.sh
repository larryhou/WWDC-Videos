#!/bin/bash

# export HTTPS_PROXY=http://web-proxy.oa.com:8080

YEAR=2014
OUTPUT_DIR=~/Documents/Github/WWDC-Videos/m3u8
while getopts :o:y:h OPTION
do
	case ${OPTION} in
		o) OUTPUT_DIR=${OPTARG};;
		y) YEAR=${OPTARG};;
		h) echo "Usage: $(basename $0) -o [OUTPUT_DIR] -y [WWDC_YEAR] -h [HELP]"
		   exit;;
		:) echo "ERR: -${OPTARG} 缺少参数, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
		?) echo "ERR: 输入参数-${OPTARG}不支持, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
	esac
done

OUTPUT_DIR=${OUTPUT_DIR}/${YEAR}
if [ ! -d "${OUTPUT_DIR}" ]
then
	mkdir -pv ${OUTPUT_DIR}
fi

curl -s https://developer.apple.com/videos/wwdc${YEAR}/ | grep 'Session [0-9]\{3,\}' \
	| awk -F'Session ' '{print $2}' | awk -F'<' '{print $1}' | sort | uniq | while read id
do
	url="https://developer.apple.com/videos/play/wwdc${YEAR}-${id}"
	curl -s ${url} -o data.txt 
	ref=$(cat data.txt | grep 'ref.mov' | awk -F'"' '{print $2}')
	m3u8=$(echo ${ref} | sed 's/ref.mov/sl2.m3u8/')
	name=$(cat data.txt | grep '</h3>' | awk -F'>' '{print $2}' | awk -F'<' '{print $1}')
	file=${OUTPUT_DIR}/${id}.m3u8
	curl -s ${m3u8} -o ${file}
	echo -e "\n#VIDEO-INFO:M3U8=${m3u8},NAME=\"${name}\"" >> ${file}
	echo -e "[${id}-${name}]\n  ${m3u8} -> ${file}"
done

rm -f data.txt
