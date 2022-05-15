#!/bin/bash
pvesm status | awk '/active/{gsub("%",""); print "disk,device=nvme0,fstype="$1, "used_percent="$NF}'
