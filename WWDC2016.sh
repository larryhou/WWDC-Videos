#!/bin/bash

dir=~/Documents/Developer/WWDC/2016
while getopts :d:h OPTION
do
	case ${OPTION} in
		d) dir=${OPTARG};;
		h) echo "Usage: $(basename $0) -d [VIDEO_OUTPUT_DIR] -h [HELP]"
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

# https://developer.apple.com/videos/wwdc2016/
base=https://developer.apple.com
wwdc=/videos/wwdc2016/

curl -s ${base}${wwdc} | grep 'href=\".*wwdc2016/[0-9]*'     \
| awk -F'href' '{print $2}' | awk -F\" '{print $2}' | sort | uniq | while read session
do
	echo "${base}${session}"
	curl -s ${base}${session} | sed 's/\(http:\/\/[^\"]*\)/<<\1>>/g' | sed $'s/<</\\\n/g' \
	| grep 'http://devstreaming.apple.com' | awk -F'>>' '{print $1}'                 \
	| grep '_hd_' | while read url
	do
		name=$(echo ${url} | awk -F/ '{print $NF}' | awk -F? '{print $1}')
		if [ -f "${dir}/${name}" ] && [ ! -f "${dir}/${name}.st" ]
		then
			continue
		fi
		
		axel -a -o ${dir}/${name} ${url}
	done
done
