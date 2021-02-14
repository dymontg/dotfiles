#!/bin/sh
SCRIPTDIR=$(dirname "$(readlink -f '$0')")
files=".Xresources .xinitrc .zshrc .oh-my-zsh .fonts .config/i3 .config/rofi .config/lemonbar .config/mopidy .scripts .emacs.d .doom.d"

for file in $files; do
    printf "Creating symlink to %s in home directory.\n" "${file}"
    ln -sfn "${SCRIPTDIR}/${file}" "${HOME}/${file}"
done

# Handle mopidy configureation seperately
cp "${SCRIPTDIR}"/.config/mopidy/mopidy.conf.safe "${SCRIPTDIR}"/.config/mopidy/mopidy.conf 

doom install
