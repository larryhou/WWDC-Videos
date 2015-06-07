#!/bin/bash

function download()
{
	cat ${1}.txt | grep -i '\.pdf' | while read url
	do
		wget ${url} -O ${1}/$(echo ${url} | awk -F/ '{print $NF}' | awk -F? '{print $1}')
		break
	done
}

download 2014
# download 2013
# download 2012