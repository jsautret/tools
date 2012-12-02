#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2012 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.mkv [FILES.mkv...]

Convert a MKV audio DTS track into AC3 (to play on Freebox for example).
Original files will be backuped.
"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

set -o errexit
set -o nounset

DIRNAME="`dirname $0`"
. "$DIRNAME"/../utils.sh

check_dep mkvmerge mkvtoolnix
check_dep mkvextract mkvtoolnix
check_dep dcadec libdca-utils
check_dep aften aften

TMP="`mktemp`"
TMPDIR="`mktemp --directory`"

for F in "$@"
do
    mkvmerge -i "$F"
    TRACK=`LC_ALL=C mkvmerge -i "$F" | grep ^Track | grep DTS |sed 's/^Track ID \(.\):.*$/\1/'`
    if [[ a$TRACK == a ]] ; then
	echo "No DTS track found." 1>&2
	exit 1
    fi
    mkvextract tracks "$F" $TRACK:$TMP.dts
    dcadec -o wavall $TMP.dts 2>/dev/null| aften -b 640 - $TMP.ac3
    mkvmerge -o "$F".new -A "$F" $TMP.ac3
    echo
    mkvmerge -i "$F".new
    mv "$F" $TMPDIR
    mv "$F.new" "$F"
done

rm $TMP*
echo
echo "Old files have been backuped in $TMPDIR"