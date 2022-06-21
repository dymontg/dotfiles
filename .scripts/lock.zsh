#!/bin/bash
# Script copied from https://www.reddit.com/r/unixporn/comments/3358vu/i3lock_unixpornworthy_lock_screen/
# and https://pastebin.com/ViRWBH90
# Depends on: imagemagick, i3lock, scrot

IMAGE=/tmp/lockscreen.png
ICON=~/dotfiles/.config/sway/lock

grim $IMAGE
convert $IMAGE -scale 10% -scale 1000% -fill black -colorize 25% $IMAGE
convert $IMAGE $TEXT -gravity center -geometry +0+200 -composite $IMAGE
convert $IMAGE $ICON -gravity center -composite -matte $IMAGE
swaylock -u -i $IMAGE
