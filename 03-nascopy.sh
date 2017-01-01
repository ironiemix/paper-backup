#!/bin/bash

BASE="/tmp"
HOST="helga"
SFTPUSER="paperbackup"
FOLDER="~/documents"
YEAR=$(date "+%Y")
MONTH=$(date "+%m")

# get wifi address
WIFIIP=$(ip addr show  wlan0  | grep "inet " | awk '{print $2}' | cut -d/ -f1)

if [ $WIFIIP == "192.168.1.128" ]; then
	HOST="192.168.1.2:2222"
fi



if [ -z "$1" ]; then
    echo "Usage: $0 <jobid> <user> [<keyword>]"
    echo
    echo "Please provide existing jobid as first parameter"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Usage: $0 <jobid> <user> [<keyword>]"
    echo
    echo "Please provide user as second parameter"
    exit 1
fi

OUTPUT="$BASE/$1"
REMOTE="sftp://$SFTPUSER@$HOST/$FOLDER/$2/$3/$YEAR/$MONTH/$1.pdf"
LOCAL="$OUTPUT/$1.pdf"

if [ ! -f "$LOCAL" ]; then
    echo "jobid does not exist"
    exit 1
fi


# For this to work, I had to create a dsa key für auth because 
# curl kept refusing to use the rsa key.
# The folder hat to be given as ~/documents, absolute paths didnt work 
# I suspect because of the changeroot jail on the server
echo copying to $REMOTE
curl --ftp-create-dirs --insecure -T "$LOCAL" "$REMOTE"

