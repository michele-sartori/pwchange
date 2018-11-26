#!/bin/bash

# example hook for sk.pwchange: sync gnome keyring item password
# usage: $0 old_password new_password

keyringItem="My password"
mex=""

if /usr/lib/sk-pwchange/sk.pwd_keyring.py -q -a item -l $keyringItem -c -n "$2"; then
    mex="keyring: $keyringItem password changed"
else
    mex="keyring: $keyringItem password NOT changed"
fi

echo $mex

