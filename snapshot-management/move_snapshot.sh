#!/bin/sh

list_snapshot() {
  zfs list -t snapshot zroot/usr/home | \
		awk '{if (NR > 1) print $1}' # remove header
}

FILENAME=$(list_snapshot | grep daily | head -n 1)
NEW_FILENAME="$(echo "$FILENAME" | sed "s/.*@//" | sed "s/daily/@monthly/")"
zfs rename -r "$FILENAME" "$NEW_FILENAME"

