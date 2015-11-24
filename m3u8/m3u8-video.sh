#!/bin/bash

M3U8=2014/716.m3u8
KEYWORD=1152
OUTPUT_DIR=~/Downloads/2014
while getopts :m:k:o:y:h OPTION
do
	case ${OPTION} in
		m) M3U8=${OPTARG};;
		k) KEYWORD=${OPTARG};;
		o) OUTPUT_DIR=${OPTARG};;
		h) echo "Usage: $(basename $0) -o [OUTPUT_DIR] -k [KEYWORD] -m [M3U8_FILE] -h [HELP]"
		   exit;;
		:) echo "ERR: -${OPTARG} 缺少参数, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
		?) echo "ERR: 输入参数-${OPTARG}不支持, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
	esac
done

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
	file=${OUTPUT_DIR}/$(echo ${seg} | awk -F'/' '{print $NF}')
	if [[ ! -f "${file}" ]] || [[ -f "${file}.st" ]]
	then
		axel -o "${file}" ${url}
	else
		echo "[DONE] ${url}"
	fi
done

find ${OUTPUT_DIR} -iname 'fileSequence*.*' | while read file
do
	id=$(echo ${file} | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}' | sed 's/fileSequence//')
	echo "${id} ${file}"
done | sort -k 1 -n | awk '{print $2}' | while read file
do
	echo "file '${file}'"
done > ${OUTPUT_DIR}/concat.txt

ffmpeg -f concat -i ${OUTPUT_DIR}/concat.txt -c copy ${OUTPUT_DIR}/${id}.ts -y

# exit
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
