#!/bin/bash
artifact=`awk -v FS="," 'NR==1{gsub(/^ +| +$/, "");print $2}' host_data2.csv`
if [[ "$artifact" == "1" ]]; then
echo "1 variant menu"
elif [[ "$artifact" == "2" ]]; then
echo "2 variant menu"
else echo "Хрен пойми что!$artifact"
fi
