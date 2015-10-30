#!/bin/bash

M3U8=2014/716.m3u8
KEYWORD=1152
OUTPUT_DIR=~/Downloads/2014

id=$(echo ${M3U8} | awk -F'/' '{print $NF}' | sed 's/\.m3u8//')
OUTPUT_DIR=${OUTPUT_DIR}/${id}
if [ ! -d "${OUTPUT_DIR}" ]
then
	mkdir -pv ${OUTPUT_DIR}
fi

base=$(cat ${M3U8} | grep 'VIDEO-INFO' | awk -F'=' '{print $2}' | awk -F',' '{print $1}' | sed 's/[^\/]*$//')
name=$(cat ${M3U8} | grep 'VIDEO-INFO' | awk -F'=' '{print $NF}' | awk -F'"' '{print $2}')

num=$(cat -n ${M3U8} | grep ${KEYWORD} | awk '{print $1}')
let num=num+1

# video
fmt=$(sed "${num}!d" ${M3U8})
curl -s ${base}${fmt} | sed '/^#/d' | while read seg
do
	url=${base}$(echo ${fmt} | sed 's/[^\/]*$//')${seg}
	echo ${url}
done

# subtitle
sub=$(cat ${M3U8} | grep 'TYPE=SUBTITLES' | awk -F'URI=\"' '{print $2}' | awk -F'\"' '{print $1}' | tail -n 1)
if [ "${sub}" = "" ];then exit 2;fi;

vtt=${OUTPUT_DIR}/${id}.webvtt
srt=${OUTPUT_DIR}/${id}.srt

rm -f ${vtt}
curl -s ${base}${sub} | sed '/^#/d' | while read seg
do
	url=${base}$(echo ${sub} | sed 's/[^\/]*$//')${seg}
	curl -s ${url} >> ${vtt}
	printf .
done
printf '\n'

let flag=1
let indx=0
pattern='^[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]\{3\}'
while read line
do
	if [ "${line}" = "" ]
	then
		flag=1
		prev=${stamp}
	else
		match=$(echo ${line} | grep ${pattern})
		if [ ! "${match}" = "" ]
		then
			stamp=${line}
			if [ "${stamp}" = "${prev}" ]
			then
				flag=1
			else
				let indx=indx+1
				echo -e "\n${indx}"
				echo ${line}
				flag=0
			fi
		elif [ ${flag} -eq 0 ]
		then
			echo ${line}
		fi
	fi
done < ${vtt} \
| sed 's/&gt;/>/g'  \
| sed 's/&lt;/</g'  \
| sed 's/A:middle//' > ${srt}
