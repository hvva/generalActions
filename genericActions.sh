#!/bin/bash

# A small script to associate created digital artifacts with general
# user activities.
#
# Author: Joshua I. James (cybercrimetech.com)
# Licese: GNU GENERAL PUBLIC LICENSE v2
#
# Requires: Sleuthkit (fls and mactime): http://www.sleuthkit.org/
#
# Input: sleuthkit body file, date time, time range (minutes)
# Example: sessionUsage.sh -b body.txt -D "Apr 27 2015" -t "12:58" -d 5
# This example will search the body file for all entries on the 27th
# from 12:58 to 13:02.
#
# TODO:
# Seconds currently not supported.
# Deleted files
#

usage() {
	echo "Usage: $0 -b body.txt -D 'Apr 27 2015' -t '12:58' [-d 5][-w 10]" 1>&2
	echo "	-b - Mactime body format" 1>&2
	echo "	-D - start date to search" 1>&2
	echo "	-t - Start time to search" 1>&2
	echo "	-d - Duration in minutes for the session" 1>&2
	echo "	-w - Number of top words to show" 1>&2
	exit 1
}

while getopts ":b:D:t:d::w::" opt; do
  case $opt in
    b)
      BF=${OPTARG}
      ;;
    D)
      dateStart=${OPTARG}
      ;;
    t)
      timeStart=${OPTARG}
      ;;
    d)
      duration=${OPTARG}
      ;;
    w)
      words=${OPTARG}
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
	usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ ! -f "$BF" ] || [ -z "$timeStart" ] || [ -z "$dateStart" ]; then
	usage
fi

if [ -z $duration ]; then
	duration=1
fi
if [ -z $words ]; then
	words=10
fi

# Must pass the time to lookup
function getKeywords() {
	xBF=$1
	xDate=$2
	xTime=$3
	xOUT=$4
	mactime -d -b "$xBF" | grep -i "$xDate $xTime" | sed 's/ (deleted-realloc)//' | sed 's/ (deleted)//' \
	|  awk -F"," '{print $NF}' | tr -c '[:alnum:]' '[\n*]' | sed '/^$/d' >> $xOUT
}

OUT="$(mktemp)"
i="0"
mainDate=$dateStart
mainTime=$timeStart

while [ $i -lt $duration ]; do
	echo -en "\rSearching: $mainTime"
	getKeywords "$BF" "$mainDate" "$mainTime" "$OUT"
	mainTime=`date -d "$mainTime 1 minutes" +'%H:%M'`
	i=$[$i+1]
done
echo -en "\r"
echo "                                                   "
cat $OUT | sort | uniq -i -c | sort -nr | awk '{print $2}' | head -$words

rm -r $OUT
