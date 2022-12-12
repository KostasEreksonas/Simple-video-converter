#!/bin/sh

while true; do
	format=$(dialog --stdout --title "Choose File Format" --inputbox "Enter format of a file you want to convert" 0 0)

	# Add all found videos with selected format to videos array
	# Solution found at: https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
	readarray -d '' -O "${#videos[@]}" videos < <(find . -not -path "*/.*" -type f -name "*".$format -print0)
	dialog --title "Choose File Format" --yesno "Do you want to add another file format to convert? (Y/N)" 0 0
	if [ $? == 1 ]; then break; fi
done

# Set ffmpeg video conversion arguments and their defaults
audio=$(dialog --stdout --title "Choose Audio Settings" --inputbox "Enter settings for audio (default: copy)" 0 0)
if [ -z $audio ]; then audio="${1:-copy}"; fi

video=$(dialog --stdout --title "Choose Video Settings" --inputbox "Enter settings for video (default: libx264)" 0 0)
if [ -z $video ]; then video="${1:-libx264}"; fi

preset=$(dialog --stdout --title "Choose Preset" --inputbox "Choose preset (default: medium)" 0 0)
if [ -z $preset ]; then preset="${1:-medium}"; fi

# CRF must be between 0 - 53
while ! [[ $crf =~ ^[0-9]*$ && $crf -ge 0 && $crf -le 53 ]]; do
	crf=$(dialog --stdout --title "Choose CRF Value" --inputbox "Choose CRF value (must be between 0 - 53, default: 17)" 0 0)
	if [ -z $crf ]; then crf="${1:-17}"; fi
done

# Convert all given video files to mp4
len=${#videos[@]}
for (( i=0; i<$len; i++ )); do
	# Give converted file an extension of "_conv.mp4"
	extension="${videos[$i]##*.}" && output=$(echo ${videos[$i]} | sed "s/.$extension/_conv.mp4/g")

	# Convert a given video file
	ffmpeg -i ${videos[$i]} -c:a $audio -c:v $video -preset $preset -crf $crf $output

#	dialog --title "Keeping original video file" --yesno "Do you want to keep original file?" 0 0
	if [ $? == 1 ]; then rm ${videos[$i]}; fi
done
