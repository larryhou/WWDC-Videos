#!/bin/bash

function download_1()
{
	url=https://developer.apple.com/videos/wwdc/${1}/
	echo "Processing ${url} ..." 1>&2
	curl -s ${url}   \
		| sed 's/\(http[s]*:\/\/developer.apple.com\/devcenter\/download.action[^\"]*\)/<<\1>>/g' \
		| sed $'s/\(<<\)/\\\n/g' | grep '>>' | awk -F'>>' '{print $1}'
}

function download_2()
{	
	url=https://developer.apple.com/${1}
	echo "Processing ${url} ..." 1>&2
	curl -s ${url}  \
		| sed 's/\(http[s]*:\/\/devstreaming.apple.com\/videos\/[^\"]*\)/<<\1>>/g' \
		| sed $'s/\(<<\)/\\\n/g' | grep '>>' | awk -F'>>' '{print $1}'
}

download_1 2010 > 2010.txt
download_1 2011 > 2011.txt
download_1 2012 > 2012.txt
download_2 videos/wwdc/2013/ > 2013.txt
download_2 videos/wwdc/2014/ > 2014.txt
download_2 videos/enterprise/ > enterprise.txt
download_2 videos/ios/ > ios.txt
download_2 tech-talks/videos/ > tech-talks.txt
