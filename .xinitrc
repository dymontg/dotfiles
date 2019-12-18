# Source Xresources
xrdb ~/.Xresources

# Turn off BIOS bell
xset b off

# turn on stickykeys. don't let two keys pressed at the same time disable it.
# don't turn on "latch lock", ie pressing a modifier key twice "locks" it on.
xkbset accessx sticky -twokey -latchlock

# don't expire these settings. (run xkbset q exp for details.)
xkbset exp 1 =accessx =sticky =twokey =latchlock

# Startup daemons
pulseaudio &
urxvtd -q -f -o &

# Start i3
exec i3
