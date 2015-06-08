#!/bin/bash

num=2014
dir=/Volumes/Elements1TB/Developer/WWDC/${num}
find ${dir} -iname '*.mov' | while read file
do
	id=$(echo ${file} | awk -F/ '{print $NF}' | awk -F_ '{print $1}')
	pdf=$(find ${num} -iname '*.pdf' | awk -F/ '{print $NF}' | grep "^${id}")
	if [ "${pdf}" = "" ]
	then
		continue
	fi
	
	cp -fv ${num}/${pdf} "$(echo ${file} | sed 's/[^\.]*$/pdf/')"
done