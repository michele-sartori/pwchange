##############
# GET:

#!/bin/bash

user=`whoami`

pidGnomeSession=`ps axu | grep gnome-session-binary | grep -Ev 'autostart|grep' | awk '{print $2}'`
dbusString=$(cd /proc/${pidGnomeSession} && strings environ | grep DBUS_SESSION_BUS_ADDRESS)
keyringItem='ItemName'

export $dbusString
export GPG_AGENT_INFO="/run/user/`id -u $user`/keyring/gpg:0:1"

/usr/lib/sk-pwchange/sk.pwd_keyring.py -a item -l "$keyringItem" -s | awk -F' = ' '/=>/ {print $2}'

##############

# STORE:
#!/bin/bash

newpasswd=$1
user=`whoami`

pidGnomeSession=`ps axu | grep gnome-session-binary | grep -Ev 'autostart|grep' | awk '{print $2}'`
dbusString=$(cd /proc/${pidGnomeSession} && strings environ | grep DBUS_SESSION_BUS_ADDRESS)
keyringItem='ItemName'

export $dbusString
export GPG_AGENT_INFO="/run/user/`id -u $user`/keyring/gpg:0:1"

/usr/lib/sk-pwchange/sk.pwd_keyring.py -a item -l "$keyringItem" -t attribute1:value1,attribute2:value2,attribute3:value3 -c -n $newpasswd

