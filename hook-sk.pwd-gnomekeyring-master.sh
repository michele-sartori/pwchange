#!/bin/bash

# example hook for sk.pwchange: sync gnome keyring master password
# usage: $0 old_password new_password

mex=""

if /usr/lib/sk-pwchange/sk.pwd_keyring.py -q -a keyring -o "$1" -n "$2"; then
    mex='gnome keyring master password changed'
else
    mex='gnome keyring master password NOT changed'
fi

echo $mex

