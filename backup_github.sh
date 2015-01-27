#!/bin/bash
#
# by Silviu Vulcan
# http://www.silviuvulcan.ro http://github.com/silviuvulcan/
# 

CONF="/usr/local/etc/backup_github.conf"
GIT="$(type -P git)" || { echo >&2 "git seems to be missing and it is required."; exit 1; }
type -P curl >/dev/null 2>&1 || { echo >&2 "curl seems to be missing and it is required."; exit 1; }
type -P awk >/dev/null 2>&1 || { echo >&2 "awk seems to be missing and it is required."; exit 1; }

if [ -f $CONF ]; then
    . $CONF
else 
    >&2 echo "Could not find $CONF, cannot continue."
    exit 1
fi

if [ ! -d $BACKUPDIR ]; then
    >&2 echo "Backup target $BACKUPDIR was not found, please create and/or check permissions"
    exit 1
fi

while read REPOURL; do

    REPONAME=$(basename "$REPOURL")
    echo "Backing up $REPONAME from $REPOURL"

    if [ -d $BACKUPDIR/$REPONAME ]; then 
        echo "$REPONAME was already backed up, updating..."
        $GIT --git-dir $BACKUPDIR/$REPONAME fetch --quiet origin
        echo
    else
        echo "Backing up $REPONAME for the first time"
        $GIT clone --mirror --quiet $REPOURL $BACKUPDIR/$REPONAME
        echo
    fi

done < <(curl -s $API/users/$GITHUBUSER/repos | grep git_url | awk -F\" '{print $4}')
