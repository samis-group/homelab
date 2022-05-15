#######################################
### THIS FILE IS MANAGED BY ANSIBLE ###
###    PLEASE MAKE CHANGES THERE    ###
#######################################

#!/bin/bash
pvesm status | awk '/active/{gsub("%",""); print "disk,device=nvme0,fstype="$1, "used_percent="$NF}'
