#!/bin/bash
#
# by Silviu Vulcan
# http://www.silviuvulcan.ro http://github.com/silviuvulcan/
# 
GIT="$(which git)"
CONF="/usr/local/etc/ba-backup.conf"

if [ -f $CONF ]; then
    . $CONF
else 
    echo "Could not find $CONF, cannot continue."
    exit 1
fi

if [ ! -d $BACKUPDIR ]; then
    echo "Backup target $BACKUPDIR was not found, please create and/or check permissions"
    exit 1
fi

while read REPOURL; do

    REPONAME=$(basename "$REPOURL")
    echo "Backing up $REPONAME from $REPOURL"

    if [ -d $BACKUPDIR/$REPONAME ]; then 
        echo "$REPONAME was already backed up, updating..."
        $GIT --git-dir $BACKUPDIR/$REPONAME remote update
        echo
    else
        echo "Backing up $REPONAME for the first time"
        $GIT clone --mirror $REPOURL $BACKUPDIR/$REPONAME
        echo
    fi

done < <(curl -s $API/users/$GITHUBUSER/repos | grep git_url | awk -F\" '{print $4}')
