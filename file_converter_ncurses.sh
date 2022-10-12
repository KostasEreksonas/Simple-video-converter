#!/bin/sh

while true; do
	format=$(dialog --stdout --title "Choose File Format" --inputbox "Enter format of a file you want to convert" 0 0)

	# Add all found videos with selected format to videos array
	# Solution found at: https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
	readarray -d '' -O "${#videos[@]}" videos < <(find . -not -path "*/.*" -type f -name "*".$format -print0)
	dialog --title "Choose File Format" --yesno "Do you want to add another file format to convert? (Y/N)" 0 0
	if [ $? == 1 ]; then
		break
	fi
done

# Set arguments for ffmpeg video conversion
audio=$(dialog --stdout --title "Choose Audio Settings" --inputbox "Enter settings for audio" 0 0)
video=$(dialog --stdout --title "Choose Video Settings" --inputbox "Enter settings for video" 0 0)
preset=$(dialog --stdout --title "Choose Preset" --inputbox "Choose preset" 0 0)
crf=$(dialog --stdout --title "Choose CRF Value" --inputbox "Choose CRF value" 0 0)

# Iterate trough an array and convert all video files to mp4
len=${#videos[@]}
for (( i=0; i<$len; i++ )); do
	# Save converted file with "_conv.mp4" extension instead of original one
	extension="${videos[$i]##*.}"
	output=$(echo ${videos[$i]} | sed "s/.$extension/_conv.mp4/g")

	# Convert the given video file
	ffmpeg -i ${videos[$i]} -c:a $audio -c:v $video -preset $preset -crf $crf $output
done