#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2012 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.jpg [FILES.jpg...]
$PROGNAME DIRECTORY [DIRECTORIES...]

Embeded resized cover art into ID3 tags of MP3 files. If a directory
is given as parameter, the folder.jpg file is used. If an image
is already embeded, it's replaced.

"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

DIRNAME="`dirname $0`"
. "$DIRNAME"/utils.sh

check_dep eyeD3 eyed3
check_dep convert imagemagick

TMP=`mktemp /tmp/folder_XXXXXXX.jpg`

for F in "$@"
do
    test -d "$F" && find "$F" -iname folder.jpg -exec $0 {} \;
    if echo "$F" |grep jpg$ >/dev/null 2>&1 ; then
	D=`dirname "$F"`
	for M in "$D/"*.mp3
	do
	    eyeD3 --add-image=:FRONT_COVER "$M"
	    convert "$F" -resize 800x800\> "$TMP"
	    eyeD3 --add-image="$TMP":FRONT_COVER "$M"
	done
    fi
done
rm -f "$TMP"