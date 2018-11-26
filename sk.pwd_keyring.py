#!/usr/bin/env python

from gi.repository import GObject
from gi.repository import GnomeKeyring
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-a','--action',help='Action: can be keyring or item',required=True)
parser.add_argument('-k','--keyring',help='Keyring name',required=False)
parser.add_argument('-l','--label',help='Item label', required=False)
parser.add_argument('-c','--create',help='Create new item if doesn\'t exists', action='store_true')
parser.add_argument('-t','--attributes',help='Add attributes to keyring item (use with --create)', required=False)
parser.add_argument('-o','--oldPwd',help='Old/current keyring password, to change the keyring pwd or to unlock the keyring', required=False)
parser.add_argument('-n','--newPwd',help='New Password for keyring or item', required=False)
parser.add_argument('-s','--showPwd',help='Show item password', action='store_true')
parser.add_argument('-q','--quiet', action='store_true')
args = parser.parse_args()
 

# keyring is 'login' by default
if args.keyring:
    keyringName = args.keyring
else:
    keyringName = 'login'

def unlock_keyring():
    result = GnomeKeyring.unlock_sync("login", args.oldPwd)
    if result == GnomeKeyring.Result.OK:
        if not args.quiet:
            print 'keyring unlocked'
        return True
    else: 
        result = GnomeKeyring.unlock_sync("login", args.newPwd)
        if result == GnomeKeyring.Result.OK:
            if not args.quiet:
                print 'unlocked with new password'
            return True

    print 'Error: cannot unlock keyring'
    return False


def change_pwd_keyring():
    if not unlock_keyring():
        sys.exit(-1)

    result = GnomeKeyring.change_password_sync(keyringName, args.oldPwd, args.newPwd)
    if result != GnomeKeyring.Result.OK:

        # maybe Gnome changed the password already
        result = GnomeKeyring.change_password_sync(keyringName, args.newPwd, args.newPwd)
        if result != GnomeKeyring.Result.OK:
            print 'Error on changing keyring password'
            sys.exit(-1)
        else:
            if not args.quiet:
                print 'ok: re-changed with new password'
            sys.exit(0)
    else:
        print 'ok: password changed'
        sys.exit(0)

def change_pw_item():
    if not unlock_keyring():
        sys.exit(-1)

    (result, ids) = GnomeKeyring.list_item_ids_sync(keyringName)
    for id in ids:	
        (result, item) = GnomeKeyring.item_get_info_sync(keyringName, id)
        if result != GnomeKeyring.Result.OK:
            print '%s is locked!' % (id)
            sys.exit(-1)
        else:
            if item.get_display_name() == args.label:
                # print '  => %s = %s' % (item.get_display_name(), item.get_secret())
                item.set_secret(args.newPwd) 
                res = GnomeKeyring.item_set_info_sync(keyringName, id, item)
                if res != GnomeKeyring.Result.OK:
                    print 'Error on changing item password'
                    sys.exit(-1)
                else:
                    if not args.quiet:
                        print 'ok: item password changed'
                    sys.exit(0)
    # if the item is not found but the --create option was selected, create it
    if not args.create:
        if not args.quiet:
            print 'Item %s not found in keyring %s' % (args.label, keyringName)
        sys.exit(1)
    else:
        attrs = GnomeKeyring.attribute_list_new()
        if args.attributes:
            attrsList = args.attributes.split(",")
            for attr in attrsList:
                (attrName, attrVal) = attr.split(":")
                GnomeKeyring.attribute_list_append_string(attrs, attrName, attrVal)
        
        res = GnomeKeyring.item_create_sync(keyringName, 0, args.label, attrs, args.newPwd, True)
        if res[0] != GnomeKeyring.Result.OK:
            print 'Error on creating the new keyring item'
            sys.exit(-1)
        else:
            if not args.quiet:
                print 'ok: item created'
            sys.exit(0)

def get_pw_item():
    if not unlock_keyring():
        sys.exit(-1)

    (result, ids) = GnomeKeyring.list_item_ids_sync(keyringName)
    for id in ids:	
        (result, item) = GnomeKeyring.item_get_info_sync(keyringName, id)
        if result != GnomeKeyring.Result.OK:
            print '%s is locked!' % (id)
            sys.exit(-1)
        else:
            if item.get_display_name() == args.label:
                print '  => %s = %s' % (item.get_display_name(), item.get_secret())
                sys.exit(0)
    # item is not found
    if not args.quiet:
        print 'Item %s not found in keyring %s' % (args.label, keyringName)
    sys.exit(1)


if args.action == 'keyring':
    if args.oldPwd and args.newPwd:
        change_pwd_keyring()
    else:
        print 'Old and new keyring passwords are needed (-o and -n option)'
        sys.exit(1)
elif args.action == 'item':
    if args.label:
        if args.showPwd:
            get_pw_item()
        elif args.newPwd:
            change_pw_item()
        else:
            print 'New item password is needed (-n option)'
            sys.exit(1)
    else:
        print 'Item label is needed (-l option)'
        sys.exit(1)
else:
    print "-a options (--action) can be only 'keyring' or 'item'"
    sys.exit(1)

