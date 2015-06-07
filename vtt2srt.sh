#!/bin/bash

vtt=101.webvtt
while getopts :s:d:h OPTION
do
	case ${OPTION} in
		s) vtt=${OPTARG};;
		h) echo "Usage: $(basename $0) -s [VTT_SUBTITLE_FILE] -h [HELP]"
		   exit;;
		:) echo "ERR: -${OPTARG} 缺少参数, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
		?) echo "ERR: 输入参数-${OPTARG}不支持, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
	esac
done

echo "Converting ${vtt} ..." 1>&2

let index=0
let found=0
while read line
do
	if [ ${found} -eq 0 ]
	then
		match=$(echo ${line} | grep '^[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9]\{3\}')
		if [ ! "${match}" = "" ]
		then
			let found=1
			let index=index+1
			
			echo 
			echo ${index}
			echo ${line}
		fi
	else
		if [ "${line}" = "" ]
		then
			let found=0
		else
			echo ${line}
		fi
	fi
	
done < <(cat ${vtt} | sed 's/A:middle//g' | sed '/WEBVTT/d' | sed '/X-TIMESTAMP-MAP.*/d' ) \
	> $(echo ${vtt} | sed 's/webvtt$/srt/')