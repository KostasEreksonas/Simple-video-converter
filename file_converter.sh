#!/bin/sh

while true; do
	read -p "Enter the file format that you want to convert: " format

	# Add all found videos with selected format to videos array
	# Solution found at: https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
	readarray -d '' -O "${#videos[@]}" videos < <(find . -not -path "*/.*" -type f -name "*".$format -print0)
	read -p "Do you want to add another file format to convert? (Y/N) " choice
	if [[ $choice == "N" || $choice == "n" ]]; then break; fi
done

# Set arguments for ffmpeg video conversion
read -p "Choose audio settings (default: copy): " audio
if [ -z $audio ]; then audio="${1:-copy}"; fi
read -p "Choose video settings (default: libx264): " video
if [ -z $video ]; then video="${1:-libx264}"; fi
read -p "Choose ffmpeg preset (default: medium): " preset
if [ -z $preset ]; then preset="${1:-medium}"; fi
read -p "Choose CRF value (0-53, defult: 17): " crf
if [ -z $crf ]; then crf="${1:-17}"; fi

# Convert all found video files to mp4
len=${#videos[@]}
for (( i=0; i<$len; i++ )); do
	# Give a converted video file an extension of "_conv.mp4"
	extension="${videos[$i]##*.}"
	output=$(echo ${videos[$i]} | sed "s/.$extension/_conv.mp4/g")

	# Convert a given video file
	ffmpeg -i ${videos[$i]} -c:a $audio -c:v $video -preset $preset -crf $crf $output

	# Prompt user wether to delete an original video file
	read -p "Do you want to delete an original file? (Y/N) " choice
	if [ $choice == "Y" ]; then rm ${videos[$i]}; fi
done
