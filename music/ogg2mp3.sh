#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2013 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.ogg [FILES...]

Convert Ogg Vorbis file to MP3.

"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

DIRNAME="`dirname $0`"
. "$DIRNAME"/music_include.sh

check_dep avconv libav-tools
check_dep totem-video-indexer totem


for FILE in "$@"
do
    if is_ogg "$FILE" ; then
	BASE=${FILE%.ogg}

	if [ -f "$BASE.mp3" ] ; then
	    echo "'$BASE.mp3' already exists, skipping conversion."
	else
	    avconv -ab 192k -i "$BASE.ogg" "$BASE.mp3"
	    #sox "$BASE.ogg" "$BASE.wav" && lame -v "$BASE.wav" "$BASE.mp3" && rm -f "$BASE.wav" && echo "'$BASE.ogg' -> '$BASE.mp3' done."
	fi

	A="`get_tag ARTIST "$FILE"`"
	B="`get_tag ALBUM  "$FILE"`"
	T="`get_tag TITLE  "$FILE"`"
	Y="`get_tag YEAR  "$FILE"`"
	TN="`get_tag TRACK_NUMBER "$FILE"`"
	TT="`get_tag TRACKTOTAL "$FILE"`"
	AA="`get_tag ALBUM_ARTIST "$FILE"`"

	[ -n "$A" ] && id3v2 --artist "$A" "$BASE.mp3"
	[ -n "$B" ] && id3v2 --album  "$B" "$BASE.mp3"
	[ -n "$T" ] && id3v2 --song   "$T" "$BASE.mp3"
	[ -n "$Y" ] && id3v2 --year   "$Y" "$BASE.mp3"
	[ -n "$TT" ] && id3v2 --track "$TN/$TT" "$BASE.mp3"
	[ -n "$TN" ] && [ -z "TT" ] && id3v2 --track "$TN" "$BASE.mp3"
	[ -n "$AA" ] && id3v2 --TPE2 "$AA" "$BASE.mp3"

	id3v2 -l "$BASE.mp3"
    fi
done
