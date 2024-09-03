#!/bin/bash

#Check for ffmpeg running process.
SERVICE="ffmpeg"
if pgrep -x "$SERVICE" >/dev/null
  then
    notify-send 'ffmpeg Already Recording!' --icon=dialog-information --expire-time=2000
  else
    slop=$(slop -f "%x %y %w %h")
    read -r X Y W H < <(echo $slop)
    time=$(date +%F%T)
    # only start recording if we give a width (e.g we press escape to get out of slop - don't record)
    width=${#W}
    if [ $width -gt 0 ];
      then
        notify-send 'Started Capturing!' --icon=dialog-information --expire-time=2000
        # records without audio input
        ffmpeg -f x11grab -s "$W"x"$H" -framerate 60  -thread_queue_size 512  -i $DISPLAY+$X,$Y -vcodec libx264 -qp 18 -preset ultrafast -f matroska ~/Videos/capturing-$time.mkv
    fi
fi