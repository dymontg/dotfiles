#!/bin/sh
SCRIPTDIR=$(dirname "$(readlink -f '$0')")
files=".Xdefaults .zshrc .oh-my-zsh .fonts .config/sway .config/rofi .config/swaybar .config/mopidy .scripts .emacs.d .doom.d"

for file in $files; do
    printf "Creating symlink to %s in home directory.\n" "${file}"
    ln -sfn "${SCRIPTDIR}/${file}" "${HOME}/${file}"
done

# Handle mopidy configureation seperately
printf "Copying safe mopidy configuration file to mopidy.conf.\n"
cp "${SCRIPTDIR}"/.config/mopidy/mopidy.conf.safe "${SCRIPTDIR}"/.config/mopidy/mopidy.conf 

doom install
