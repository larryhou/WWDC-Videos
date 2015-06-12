#!/bin/bash

dir=./2015
while getopts :d:h OPTION
do
	case ${OPTION} in
		d) dir=${OPTARG};;
		h) echo "Usage: $(basename $0) -d [VTT_OUTPUT_DIR] -h [HELP]"
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

function getvtt()
{
	url=${1}
	path=$(echo ${url} | sed 's/\/[^\/]*$//')
	
	echo ${url}
	if [ -f "${dir}/${2}.webvtt" ]
	then
		echo "--> ${dir}/${2}.webvtt"
		return
	fi
	
	vtt=${dir}/${2}.vtt
	rm -f ${vtt}
	
	curl -s ${url} | grep -i 'vtt$' | while read name
	do
		let num=num+1
		curl -s ${path}/${name} >> ${vtt}
		printf ".${num}"
		
		if [ ${num} -lt 10 ]
		then
			printf "\b"
		elif [ ${num} -lt 100 ]
		then
			printf "\b\b"
		else
			printf "\b\b\b"
		fi
	done
	printf '\n'
	mv ${vtt} ${dir}/${2}.webvtt
	./vtt2srt.sh -s ${dir}/${2}.webvtt
	./decode.sh ${dir}/${2}.srt
}

base=https://developer.apple.com/videos/wwdc/2015/
curl -s ${base} | grep 'href=\"?id=[0-9]*\"'     \
| awk -F'href' '{print $2}' | awk -F\" '{print $2}' | sort | uniq | while read id
do
	echo "${base}${id}"
	curl -s ${base}${id} | sed 's/\(http:\/\/[^\"]*\)/<<\1>>/g' | sed $'s/<</\\\n/g' \
	| grep 'http://devstreaming.apple.com' | awk -F'>>' '{print $1}'                 \
	| grep '\.m3u8$' | while read url
	do
		path=$(echo ${url} | sed 's/\/[^\/]*$//')
		name=$(curl -s ${url} | grep 'TYPE=SUBTITLES' | awk -F'URI' '{print $2}' | awk -F\" '{print $2}')
		if [ "${name}" = "" ]
		then
			echo "NOT FOUND SUBTITLE" 2>&1
			echo
			continue
		fi
		getvtt ${path}/${name} $(echo ${id} | awk -F= '{print $2}')
		echo
	done
done