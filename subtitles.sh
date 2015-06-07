#!/bin/bash

src=2013.txt
dir=2013

while getopts :s:d:h OPTION
do
	case ${OPTION} in
		s) src=${OPTARG};;
		d) dir=${OPTARG};;
		h) echo "Usage: $(basename $0) -s [VIDEO_URL_FILE] -d [SUBTITLE_OUTPUT_DIR] -h [HELP]"
		   exit;;
		:) echo "ERR: -${OPTARG} 缺少参数, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
		?) echo "ERR: 输入参数-${OPTARG}不支持, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
	esac
done

if [ ! -d "${dir}" ]
then
	mkdir -pv ${dir}
fi

cat ${src} | grep -i 'hd' | sed 's/\/[^\/]*$//' | while read line
do
	prefix="${line}/subtitles/eng"
	echo "${prefix}/prog_index.m3u8"
	
	id=$(echo ${line} | awk -F/ '{print $NF}')
	
	file=${dir}/${id}.webvtt
	rm -f ${file}
	touch ${file}
	echo  ${file}
	
	curl -s "${prefix}/prog_index.m3u8" | grep '\.webvtt$' | while read name
	do
		let num=num+1
		curl -s "${prefix}/${name}" | sed $'s/\\\r//g' >> ${dir}/${id}.webvtt
		printf ".${num}"
		
		if [ ${num} -lt 10 ]
		then
			printf "\b"
		else
			printf "\b\b"
		fi
	done
	echo
done