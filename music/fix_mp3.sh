#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2012 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.mp3 [FILES.jpg...]
$PROGNAME [--no-recursive] DIRECTORY [DIRECTORIES...]

Fix errors in mp3 files.

"
###########################################################################

RECURSIVE=1
if [[ a$1 == a--no-recursive ]] ; then
    shift
    RECURSIVE=0
fi

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

DIRNAME="`dirname $0`"
. "$DIRNAME"/utils.sh

check_dep vbrfix vbrfix
check_dep mp3val mp3val
check_dep mp3gain mp3gain

TMP=`mktemp --dry-run /tmp/fixed_XXXXXXX.mp3`

for F in "$@"
do
    if test -d "$F" ; then
	cd "$F"
	if [ RECURSIVE == 1 ] ; then
	    find . -mindepth 1 -maxdepth 1 -type d -exec $0 {} \;
	fi
	echo -n "======= Fix mp3 in "
	pwd
	ls *.mp3 >/dev/null 2>&1 && ( $0 *.mp3 ; mp3gain -r -c *.mp3 )
	cd -
    else
	if echo "$F" |grep mp3$ >/dev/null 2>&1 ; then
	    mp3val -f "$F"
	    vbrfix "$F" $TMP && mv $TMP "$F"
	fi
    fi
done

rm vbrfix.log vbrfix.tmp 2>/dev/null