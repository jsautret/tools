#!/bin/bash
PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2013 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
cd /your/music
$PROGNAME .

Print Albums with same name but different Album Artists.

"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

DIRNAME="`dirname $0`"
. "$DIRNAME"/music_include.sh


ALBUMS=/tmp/albums.txt
TMP=`mktemp`

cd "$1"
echo "$1"
for F in *
do
    if test -d "$F" ; then
	$0 "$F"
    else
	B="`get_tag ALBUM "$F" 2>/dev/null `"
	if [[ -n "$B" ]] ; then
	    A="`get_tag ALBUM_ARTIST "$F"`"
	    echo "$B|$A" >>$ALBUMS
	fi
    fi
done

if [[ "$1" == .  ]]; then
    echo
    echo
    echo
    echo
    sort -u $ALBUMS > $TMP
    mv $TMP $ALBUMS
    cut -d'|' -f 1 $ALBUMS | uniq -d
fi

exit $?
