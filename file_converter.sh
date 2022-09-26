#!/bin/sh

while true; do
	read -p "Enter the file format that you want to convert: " format

	# Add all found videos with selected format to videos array
	# Solution found at: https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
	readarray -d '' -O "${#videos[@]}" videos < <(find . -type f -name "*.$format" -print0)
	read -p "Do you want to add another file format to convert? (Y/N) " choice
	if [ $choice == "N" ]; then
		break
	fi
done

# Set arguments for ffmpeg video conversion
read -p "Choose audio settings: " audio
read -p "Choose video settings: " video
read -p "Choose ffmpeg preset: " preset
read -p "Choose CRF value (0-53): " crf

# Iterate trough array and convert all video files to mp4
len=${#videos[@]}
for (( i=0; i<$len; i++ )); do
	# Update file extension of converted file
	output=$(echo ${videos[$i]} | sed "s/.$format/_conv.mp4/g")

	# Convert given video file
	ffmpeg -i ${videos[$i]} -c:a $audio -c:v $video -preset $preset -crf $crf $output
done
