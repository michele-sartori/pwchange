#!/bin/bash

# example hook for sk.pwchange: sync network 802-1x password using the network manager
# usage: $0 old_password new_password (old password not used)

myNet="NetworkConnectionName"
mex=""

if nmcli c modify $myNet 802-1x.password $2 > /dev/null 2>&1; then
    mex="current $myNet network connection password changed"
else
    mex="current $myNet network connection password NOT changed"
fi

echo $mex

