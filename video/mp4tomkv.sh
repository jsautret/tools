#!/bin/bash

PROGNAME="`basename $0`"
###########################################################################
# Copyright (c) 2014 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.mp4 [FILES.mp4...]

Convert MP4 file(s) to MKV (Matroska).
MKV will use the same video and audio codecs (just demuxing and muxing).
Original MP4 files will be keeped.
Existing MKV files will be overwritten.
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

check_dep ffmpeg ffmpeg
echo
for MP4 in "$@"
do
    if ! $( echo "$MP4" | grep -i \\.mp4$ >/dev/null 2>&1 ) ; then
	echo "Ignoring file with unknown extension: $MP4" >&2
	continue
    fi
    MKV="${MP4%.*}".mkv

    echo -n "Converting $MP4 to $MKV..."
    ffmpeg -loglevel warning -i "$MP4" -vcodec copy -acodec copy  "$MKV"
    echo " done"
done
