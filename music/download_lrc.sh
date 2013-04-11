#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2012 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.{mp3|ogg} [FILE.{mp3|ogg}...]

Download the LRC lyrics files for the given music files.

"
# set this to the path where lrcShow-X is installed:
LRCSHOW="/home/jerome/local/lrcShow-X.old"

###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

if ! test -d $LRCSHOW/engines ; then
    echo "lrcShow-X must be installed and the path must be set in the script $0." >&2
    exit 1
fi

. "`dirname $0`"/music_include.sh

check_dep totem-video-indexer totem

red="\E[31m"

TMP=/tmp/`basename $0`.html
TMPLRC=/tmp/`basename $0`.$$.lrc

export PYTHONPATH="$PYTHONPATH:$LRCSHOW/engines"

download_old() {
	    ARTISTURL="`echo "$ARTIST" | urlencode`"
	    SONGTITLEURL="`echo "$SONGTITLE" | urlencode`"

	    wget -o /tmp/wget.log -O $TMP 'http://www.lyrdb.com/karaoke/?q='"$ARTISTURL"+"$SONGTITLEURL"'&action=search'

	    LINE=$(grep tresults "$TMP" | grep -i '<a href="[^"]*">'"$SONGTITLE"'<' | grep -i '<td class="tresults">'"$ARTIST"'<' | head -n1)
	    if [ a"$LINE" != a ] ; then
		ID=$(echo "$LINE" | sed 's%^.*/karaoke/\([0-9]*\)\.htm.*$%\1%')
		wget -o /tmp/wget.log -O "$LYRICS" --referer=http://www.lyrdb.com/karaoke/$ID.htm 'http://www.lyrdb.com/karaoke/downloadlrc.php?q='$ID
	    else
		echo "   not found"
	    fi
}

normalize()
{
    LYRICS="$1"

    find "$LYRICS" -size -110c -printf "File too small : " -print -exec rm -f "{}" \;

    if [ -f "$LYRICS" ] ; then
	#sed --in-place 's/^.$//' "$LYRICS"
	sed --in-place 's/<!--[^>]*>//' "$LYRICS"
	#sed --in-place 's/^[^[ ].*$//'  "$LYRICS"
	#sed --in-place 's/^\[00:00\.00\]$//'  "$LYRICS"
	grep -v --text 51lrc.com "$LYRICS" >"$TMPLRC"
	mv "$TMPLRC" "$LYRICS"
	grep -v --text "LRC by lzh" "$LYRICS" >"$TMPLRC"
	mv "$TMPLRC" "$LYRICS"
	grep -v --text "qianqian.com" "$LYRICS" >"$TMPLRC"
	sed --in-place 's/^\([[][0-9]\+:[0-9]\+\(\.[0-9]\+\)\?$\)/\1]/' "$LYRICS"
	mv "$TMPLRC" "$LYRICS"
	find "$LYRICS" -size -200c -printf "****** File corrupted : " -print -exec rm -f "{}" \;

    fi
}

for FILE in "$@"
do
    LYRICS="${FILE%.*}.lrc"
    if [ ! -f "$LYRICS" ] ; then

	ARTIST="`get_tag ARTIST "$FILE"`"
	SONGTITLE="`get_tag TITLE  "$FILE"`"

	if [ a"$ARTIST" != a ] && [ a"$SONGTITLE" != a ] ; then
	    #ARTIST="Frank Zappa"
	    echo "$ARTIST - $SONGTITLE"

	    download_lrc.py "$LYRICS" "$ARTIST" "$SONGTITLE"

	else
	    echo -e $FILE "${red}EPIC FAIL"; tput sgr0
	fi
    fi
    if [ -f "$LYRICS" ] ; then
	normalize "$LYRICS"
    fi
    if [ -f "$LYRICS" ] ; then
	convert_offset_in_lrc.sh "$LYRICS"
    fi
done






















exit $?

# http://www.51lrcgc.com/htm/singer/singer7.htm
tr '<' '\n'|grep lrc.asp|sed 's%^.*/asp/lrc.asp?id=\([^"]*\)".*$%\1%g'|\
while read ID
do
    LRC="${1%.*}.lrc"
    echo "Getting $ID for $LRC"
    wget -o /tmp/wget.log -O "$LRC" 'http://www.51lrcgc.com/asp/lrc.asp?id='$ID
    shift
done