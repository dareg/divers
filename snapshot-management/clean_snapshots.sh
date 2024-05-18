#!/bin/sh

list_snapshot() {
  zfs list -t snapshot zroot/usr/home | \
		awk '{if (NR > 1) print $1}' # remove header
}

remove_old_daily() {
	list_snapshot | sort -r | grep daily | sed '1,7d' | xargs zfs destroy -r
}

remove_old_monthly() {
	list_snapshot | sort -r | grep monthly | sed '1,13d' | xargs zfs destroy -r
}


remove_old_monthly
remove_old_daily
