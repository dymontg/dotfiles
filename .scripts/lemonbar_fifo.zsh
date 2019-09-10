
#!/bin/zsh
set -euo pipefail
IFS=$'\n\t'

# Include configuration
source ${HOME}/.config/lemonbar/config

# Kill all subprocesses and remove the FIFO file.
trap "pkill -P $$; rm ${workspaces_fifo}" SIGINT SIGQUIT SIGTERM EXIT

if [[ ! -p "${workspaces_fifo}" ]]; then
    mkfifo "${workspaces_fifo}"
fi

# Start script
python ${HOME}/.scripts/i3_workspaces.py > "${workspaces_fifo}" &

clock() {
    date "${date_format}"
}

battery_glyph() {
    bat_cap_path="/sys/class/power_supply/BAT0/capacity"
    bat_status_path="/sys/class/power_supply/BAT0/status"
    bat_glyphs=( "${battery_empty_glyph}" "${battery_quarter_full_glyph}" \
                                         "${battery_half_full_glyph}" \
                                         "${battery_three_quarters_full_glyph}" \
                                         "${battery_full_glyph}" )
    if [[ -r "${bat_status_path}" ]] && [[ "$(<${bat_status_path})" = "Charging" ]] || \
           [[ "$(<${bat_status_path})" = "Full" ]]; then
        printf "%s" "${charging_glyph}"
    elif [[ -r "${bat_cap_path}" ]]; then
        bat_cap="$(<${bat_cap_path})"
        glyph=${bat_glyphs[$(( $(( bat_cap - 1 )) / 20 ))]}
        if [[ "${bat_cap}" -le 10 ]]; then
            printf "%%{F%s}%s%%{F-}" "${urgent_color}" "${glyph}"
        else
            printf "%s" "${glyph}"
        fi
    fi
}

has_battery() {
    test -r "/sys/class/power_supply/BAT0/capacity"
    return "$?"
}

volume() {
    dft_sink_name=$(LC_ALL=C pacmd stat | \
                        awk -F": " '/^Default sink name: /{print $2}')
    vol=$(LC_ALL=C pacmd list-sinks | \
              awk '/^\s+name: /{indefault = $2 == "<'${dft_sink_name}'>"}
              /^\s+volume: / && indefault {print substr($5, 1, length($5)-1); exit}')
    printf "%s" "${vol}"
}

is_muted() {
    dft_sink_name=$(LC_ALL=C pacmd stat | \
                        awk -F": " '/^Default sink name: /{print $2}')
    muted=$(LC_ALL=C pacmd list-sinks | \
                awk '/^\s+name: /{indefault = $2 == "<'${dft_sink_name}'>"}
                /^\s+muted: / && indefault {print $2; exit}')
    if [[ "${muted}" == "yes" ]]; then
        return 0
    fi
    return 1
}

volume_glyph() {
    vol="$(volume)"
    if is_muted; then
        glyph="${sink_muted_glyph}";
    elif [[ "${vol}" -lt 1 ]]; then
        glyph="${sink_volume_off_glyph}";
    elif [[ "${vol}" -gt 50 ]]; then
        glyph="${sink_volume_high_glyph}";
    else
        glyph="${sink_volume_low_glyph}";
    fi
    printf "%s" "${glyph}"
}

cpuload() {
    load=$(ps -eo pcpu |grep -vE '^\s*(0.0|%CPU)' |sed -n '1h;$!H;$g;s/\n/ +/gp')
    bc <<< "${load}"
}

wlan_connection() {
    while IFS="" read -r iface || [ -n "$iface" ]; do
        if [[ -n "${iface}" ]] && ip link show "${iface}" | grep 'state UP' \
                                                                 >/dev/null; then
            if ping -I "${iface}" -c 1 8.8.8.8 >/dev/null 2>&1; then
                printf "%s" "${wireless_connection_glyph}"
                return 0
            fi
        fi
   done <<< $(tail -n+3 /proc/net/wireless | awk -F: '{print $1}')
}

eth_connection() {
    wlan_ifaces=$(tail -n+3 /proc/net/wireless | awk -F: '{print $1}')
    wired_ifaces=$(ip link show | sed -n 's/^[0-9]: \(.*\):.*$/\1/p' | \
                       awk -v wi="${wlan_ifaces}" \
                           '{split(wi, tmp, "\n"); for (i in tmp) ifs[tmp[i]]="";
                           if ($0 in ifs);else{print $0}}')
    while IFS="" read -r iface || [ -n "$iface" ]; do
        if [[ -n "${iface}" ]] && ip link show "${iface}" | \
                   grep 'state UP' >/dev/null; then
            if ping -I "${iface}" -c 1 8.8.8.8 >/dev/null 2>&1; then
                printf "%s" "${wired_connection_glyph}"
                return 0
            fi
        fi
    done <<< "${wired_ifaces}"
    return 1
}

while read -r line; do
    bar="%{l}"

    while IFS=" " read -r state workspace; do
        state=$(printf "%s" "${state}" | sed "s/INT/${workspace_inactive_color}/g" | \
                    sed "s/URG/${urgent_color}/g" | \
                    sed "s/ACT/${workspace_active_color}/g" | \
                    sed "s/FOC/${workspace_focused_color}/g")
        bar="${bar}%{O${workspace_spacer_size}}%{T3}%{F${state}}${workspace}%{F-}%{T-}"
    done <<< $(printf "%s" "${line}" | awk -F "\t" \
                                           '{for(i=2;i<=NF;i+=2) print $i, $(i-1)}')

    bar="${bar}%{r}%{A:conky:}%{T2}%{F${statusbar_glyph_color}}${cpu_glyph}%{F-}%{T-} %{F${statusbar_value_color}}$(cpuload)%{F-}%{A}"
    bar="${bar}%{O${spacer_size}}%{T2}%{F${statusbar_glyph_color}}${clock_glyph}%{F-}%{T-} %{F${statusbar_value_color}}$(clock)%{F-}"
    bar="${bar}%{O${spacer_size}}%{T2}%{A:ls:}%{F${statusbar_glyph_color}}$(eth_connection)$(wlan_connection)%{F-}%{A}%{T-}"
    bar="${bar}%{O${spacer_size}}%{A:pavucontrol:}%{T2}%{F${statusbar_glyph_color}}$(volume_glyph)%{F-}%{T-} %{F${statusbar_value_color}}$(volume)%%{F-}%{A}"
    if has_battery; then
        bar="${bar}%{O${spacer_size}}%{T2}%{F${statusbar_glyph_color}}$(battery_glyph)%{F-}%{T-}  "
    fi
    # TODO remove this one echo call.
    echo -e "${bar}"
    sleep 1
done <"${workspaces_fifo}"
