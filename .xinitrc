# Source Xresources
xrdb ~/.Xresources

# Turn off BIOS bell
xset b off

# Startup daemons
pulseaudio &
urxvtd -q -f -o &

# Start i3
exec i3
