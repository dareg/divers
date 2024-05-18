#!/bin/sh

zfs snapshot -r zroot/usr/home@daily-"$(date -I)"

