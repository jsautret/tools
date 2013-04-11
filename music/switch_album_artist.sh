#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2013 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE [FILES...]

Invert 'artist' and 'album artist' tag in mp3 or ogg files.

"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

DIRNAME="`dirname $0`"
. "$DIRNAME"/music_include.sh

check_dep avconv libav-tools
check_dep id3v2 id3v2
check_dep vorbiscomment vorbis-tools
check_dep totem-video-indexer totem

for FILE in "$@"
do
    A="`get_tag ARTIST "$FILE"`"
    B="`get_tag ALBUM_ARTIST "$FILE"`"

    if [ -n "$A" ] && [ -n "$B" ] ; then
	echo -n "$FILE: $A <-> $B"
	if is_mp3 "$FILE" ; then
	    id3v2 --artist "$B" --TPE2 "$A" "$FILE"
	elif is_ogg "$FILE" ; then
	    vorbiscomment -l "$FILE" | grep -vi '^ALBUMARTIST=' | grep -vi '^ARTIST=' | vorbiscomment -w "$FILE"
	    vorbiscomment -a --tag "ALBUMARTIST=$A" --tag "ARTIST=$B" "$FILE"
	else
	    echo -n"  FORMAT NOT SUPPORTED"
	fi
	echo .
    fi
done
