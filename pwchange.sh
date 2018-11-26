#!/bin/bash
# PasswordChange V0.3 20160723

export LC_MESSAGES="C"

hookFolder=/etc/sk-pwchange.d

# if the password change is successfull, maybe you want synchronize some other passwords (e.g. gnome keyring) using the hooks in /etc/sk-pwchange.d
# check the examples in /usr/share/sk-pwchange

sync_services_pw() {
    oldPwd=$1
    newPwd=$2
    fullMex=''

    if [ -d $hookFolder ]; then
        for hookScript in $hookFolder/hook-sk.pwd-*.sh; do
            newMex=$($hookScript $oldPwd $newPwd)
            fullMex="${fullMex} $newMex"
        done
    fi
}

while true
do
        PWCHANGE=$(zenity --forms --title="Password Change" --text="Please insert information below" --add-password="Old Password" --add-password="New Password" --add-password="Retype New Password" 2>/dev/null)
        if [ $? -ne 0 ]; then
		exit 1
	fi

	OLDPW=$(echo $PWCHANGE | awk -F'|' '{print $1}')
	PW1=$(echo $PWCHANGE | awk -F'|' '{print $2}')
	PW2=$(echo $PWCHANGE | awk -F'|' '{print $3}')
	if [ "$PW1" != "$PW2" ]; then
		zenity --error --title="Password Change" --text="Passwords do not match... Please try again" 2>/dev/null
		continue
	fi

	CHANGE=$(echo $PWCHANGE | sed -r 's/[|]+/\\n/g')

	# ${PIPESTATUS[1]} variable is the $? of the passwd command in pipe
	RS=$(printf "$CHANGE" | passwd 2>&1 | sed -e 's#$#\\n#'; echo ${PIPESTATUS[1]})
	RES=$(echo -e $RS | tail -1)

	if [ $RES -ne 0 ]; then
        if echo $RS | grep -q '(current) UNIX password: passwd: Authentication token manipulation error'; then
            MEX="Error: wrong OLD password"
        else
            MEX=$(echo -e $RS | head -n1 | awk -F': *' '{print $4}')
        fi
		zenity --error --title="Password Change" --text="$MEX\nPassword unchanged" 2>/dev/null
		continue
	else
		# sync services password
		MESSAGE=`sync_services_pw $OLDPW $PW1`
        zenity --notification --window-icon=/usr/share/icons/gnome/48x48/emblems/emblem-default.png --text "Login password changed succesfully" --timeout 3 2>/dev/null
        # zenity --notification --window-icon=/usr/share/icons/gnome/48x48/emblems/emblem-default.png --text "${MESSAGE}" --timeout 2 2>/dev/null
        exit 0
	fi
done

