#!/bin/bash

while :
do

OKAY=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | \
	awk '/percentage/{sub(/%/,"",$2);
	if ($2 < 10) {
		print 1;
	}else{
	  print 0;
	}
  }'\
)

if [ "$OKAY" -eq 1 ];then
	dunstify \
		-h string:x-dunst-stack-tag:low_battery \
		"🪫 Batterie faible"\
		-t 300000 \
		-h string:bgcolor:#FCE289 \
		-h string:fgcolor:#000000 \
		-h string:frcolor:#000000
fi

sleep 10

done
