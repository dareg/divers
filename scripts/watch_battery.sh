#!/bin/bash

while :
do

	sleep 30

	IS_CHARGING=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep state | awk '{print $2}')
	if [[ $IS_CHARGING == "charging" ]]; then
		continue
	fi

	PERCENTAGE=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | sed 's/%//' | sed 's/,/./')

	CAPACITY=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep capacity | awk '{print $2}' | sed 's/%//' | sed 's/,/./')

	BAT=$(echo "scale=4;($PERCENTAGE) * ($CAPACITY/100)" | bc )
	BAT=$(echo "$BAT/1" | bc)
	echo $BAT
	if [ $BAT -lt 10 ]; then
		dunstify \
			-h string:x-dunst-stack-tag:low_battery \
			"🪫 Batterie faible:$BAT%"\
			-t 300000 \
			-h string:bgcolor:#FCE289 \
			-h string:fgcolor:#000000 \
			-h string:frcolor:#000000
	fi
done
