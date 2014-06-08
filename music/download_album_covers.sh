#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2012 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME DIRECTORY [DIRECTORIES...]

Try to find the cover album art for the music in the given directory.

The image is created as folder.jpg in given directory.
"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

DIRNAME="`dirname $0`"
. "$DIRNAME"/music_include.sh


TMPDIR="`mktemp --directory`"
TMP=$TMPDIR/tmp.html

export LC_ALL=C
export LANG=C

check_dep wget wget
check_dep convert imagemagick
#check_dep totem-video-indexer totem
check_dep avconv libav-tools


valid_image() {
    test -s folder.jpg && \
	! diff folder.jpg "$DIRNAME"/amazon_empty.jpg >/dev/null && \
	! diff folder.jpg "$DIRNAME"/amazon_empty2.jpg >/dev/null
}

normalize_album() {
    sed -r 's/\(?\[?remastere?d?\)?\]?$//i' |\
    sed -r 's/\(?\[?Special .dition\)?\]?$//i' |\
    sed -r 's/ \(?\[?(cd|disc)? ?[1234]( of [1234])?\)?\]?$//i'|\
    sed -r 's/\(?\[?Reissue\)?\]?$//i' |\
    sed -r 's/\(?\[?UK\)?\]?$//i'
}

image_in_directory()
{
    COVER=`ls | grep -i '.*\<front\>.*\.jpg$' | head -n 1`
    if [ x"$COVER" != x ] ; then
	ln -sf "$COVER" folder.jpg
	return 0
    fi
    if [[ `ls *.jpg 2>/dev/null|grep -v '^folder.jpg$'|wc -l` == 1 ]] ; then
	ln -sf "`ls *.jpg|grep -v '^folder.jpg$'`" folder.jpg
	return 0
    fi
    return 1
}


for DIR in "$@"
do
    if [ -d "$DIR" ] ; then
	echo "-> $DIR"
	cd "$DIR"
	FILE="`ls *.{mp3,ogg} 2>/dev/null | head -n 1`"
	if ! valid_image  && [ a"$FILE" != a ] && \
	    ! image_in_directory ; then
	    A="`get_tag ARTIST "$FILE"`"
	    B="`get_tag ALBUM  "$FILE"`"
	    if [ a"$B" != a ] && [ a"$A" != a ] ; then
		A="`echo "$A" | urlencode`"
		B="`echo "$B" | normalize_album | urlencode`"
		URL="http://www.albumart.org/index.php?skey=$A+$B&itempage=1&newsearch=1&searchindex=Music"
		echo "   trying $URL"
		wget -o $TMPDIR/wget.log --header='Accept-Language: en' \
		    -O $TMP "$URL"
		if ! grep -q 'Sorry! No results' $TMP 2>/dev/null ; then
		    grep "View larger image" $TMP | \
			sed 's%^.*href="\([^"]\+\)" title="View larger image"*.*$%\1%' |\
		    while read URL && ! valid_image
		    do
			echo "   got $URL"
			wget -o $TMPDIR/wget.log -O folder.jpg "$URL"
		    done
		    if ! ( file folder.jpg | grep -qi JPEG ) ; then
			convert folder.jpg folder.jpg
		    fi
                    touch folder.jpg
    		else
    		    echo "   Not Found."
    		fi
    	    fi
        else
	    if test -s folder.jpg ; then
    		echo -n "   " && ls folder.jpg
	    else
		echo "   Unable to find album art, no music file?" >&2
	    fi
        fi
        cd - >/dev/null
    fi
done

rm -Rf $TMPDIR