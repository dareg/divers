#!/bin/sh

calc(){
	{ awk "BEGIN{print $*}"; }
}

if [ "$1" = "inc" ]; then
	ICON=🌞
	brightnessctl set +1% --quiet
else
	ICON=⛅
	brightnessctl set 1%- --quiet
fi

current=$(brightnessctl get)
max=$(brightnessctl max)
p=$(printf "%.0f\n" "$( calc "100*($current/$max)" )")

dunstify \
	-h string:x-dunst-stack-tag:brightness \
	"$ICON  $p%"\
	-t 3000 \
	-h int:value:"$p" 


