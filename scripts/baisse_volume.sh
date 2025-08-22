#!/usr/bin/env bash

safe_volume_down() {
    local increment=${1:-5}
    local current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
    local new_vol=$((current_vol - increment))
    
    if [ $new_vol -le 100 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ ${new_vol}%
    else
        pactl set-sink-volume @DEFAULT_SINK@ 100%
    fi
}

safe_volume_down 5

