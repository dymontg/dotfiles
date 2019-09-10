#!/bin/sh
SCRIPTDIR=$(dirname "$(readlink -f '$0')")
files=".Xresources .xinitrc .zshrc .spacemacs .oh-my-zsh .fonts .config/i3 .config/rofi .config/lemonbar .scripts .emacs.d"

for file in $files; do
    printf "Creating symlink to %s in home directory.\n" "${file}"
    ln -s "${SCRIPTDIR}/${file}" "${HOME}/${file}"
done
