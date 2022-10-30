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
read -p "Choose audio settings: " audio
read -p "Choose video settings: " video
read -p "Choose ffmpeg preset: " preset
read -p "Choose CRF value (0-53): " crf

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
