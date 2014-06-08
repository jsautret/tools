#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2013 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.jpg [FILES.jpg...]

Normalize pictures:
Set author name in metadata.
Set location name in metadata.

"
###########################################################################

# Change this to set a specific author name.
NAME="$(grep "^`whoami`:" /etc/passwd | awk -F: '{print $5}' | cut -d, -f 1)"

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

if [[ a$NAME == a ]] ; then
    echo "set NAME variable in $0." >&2
    exit 1
fi

set -o nounset

DIRNAME="`dirname $0`"
. "$DIRNAME"/../utils.sh

check_dep exiv2 exiv2
check_dep exiftool libimage-exiftool-perl

echo
echo "Setting author name: $NAME"
#exiv2 \
#    -M "set Exif.Image.Artist \"Photographer, $NAME\"" \
#    -M "del Xmp.dc.creator" \
#    -M "set Xmp.dc.creator \"$NAME\"" \
exiftool -artist="$NAME" -if '$model eq "NEX-5N"' "$@"

exiv2 fixiso "$@"
echo

pic_reverse_geocode.sh "$@"
echo