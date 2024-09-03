#!/bin/bash

if pidof ffmpeg
  then
    notify-send 'Stopped Recording!' --icon=dialog-information --expire-time=2000
    killall ffmpeg
fi