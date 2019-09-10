#!/bin/zsh

source ~/.config/lemonbar/config

~/.scripts/lemonbar_fifo.zsh | lemonbar -b -B "${background}" \
                                        -F "${foreground}" \
                                        -f "${bar_font}" -f "${glyph_font}" \
                                        -f "${workspaces_font}" -g 1920x24+0+0

