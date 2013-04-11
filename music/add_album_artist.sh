#!/bin/bash
PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2013 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME DIRECTORY

Copy Artist to Album Artist if name of Album is generic (empty, Misc, etc.).

"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

DIRNAME="`dirname $0`"
. "$DIRNAME"/music_include.sh

check_dep avconv libav-tools >/dev/null
check_dep id3v2 id3v2 >/dev/null
check_dep vorbiscomment vorbis-tools >/dev/null
check_dep totem-video-indexer totem >/dev/null

shopt -s nocasematch

cd "$1"
for F in *
do
    if test -d "$F" ; then
	$0 "$F"
    else
	A="`get_tag ARTIST "$F" 2>/dev/null`"
	if [[ -n "$A" ]] ; then
	    B="`get_tag ALBUM "$F"`"
	    case "$B" in
		"" | "Misc"* | *"Greatest Hits"* | *"Best Of"* | Rarities*)
		    AA="`get_tag ALBUM_ARTIST "$F"`"
		    if [[ -z "$AA" ]] ; then
			echo
			echo -n "$A - $B - $F "
			if is_mp3 "$F" ; then
			    id3v2 --TPE2 "$A" "$F"
			elif is_ogg "$F" ; then
			    vorbiscomment -l "$F" | grep -vi '^ALBUMARTIST=' | vorbiscomment -w "$F"
			    vorbiscomment -a --tag "ALBUMARTIST=$A" "$F"
			else
			    echo -n"  FORMAT NOT SUPPORTED"
			fi
			echo " done."
		    fi
		    ;;
		*) echo -n .
		    ;;
	    esac
	fi
    fi
done
