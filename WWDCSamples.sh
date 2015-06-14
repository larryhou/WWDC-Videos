#!/bin/bash

dir=/Users/$(whoami)/Downloads/Samples
if [ ! -d "${dir}" ]
then
	mkdir -pv ${dir}
fi

url=https://developer.apple.com/sample-code/wwdc/2015/
curl -s ${url} | grep 'class="library"' | awk -F'href=' '{print $2}' | awk -F\" '{print $2}' | while read link
do
	base="https://developer.apple.com${link}"
	name=$(curl -s ${base}/book.json | jq '.sampleCode' | sed 's/"//g')
	if [ ! $? -eq 0 ]
	then
		continue
	fi
	wget -O "${dir}/${name}" ${base}/${name}
done

curl -s ${url} | grep 'class="download"' | awk -F'href=' '{print $2}' | awk -F\" '{print $2}' | while read link
do
	name=$(echo ${link} | awk -F/ '{print $NF}')
	wget -O "${dir}/${name}" "https://developer.apple.com${link}"
done
