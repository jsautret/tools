#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2012 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME DIRECTORY [DIRECTORIES...]

Perform common operations recursively on a music directory tree:

Fix errors and gain, download album art cover, embed it into files and
download lrc files.

Link it into /home/$USER/.local/share/nautilus/scripts/ to use it from
Nautilus. "

###########################################################################

if [ a$NAUTILUS_SCRIPT_CURRENT_URI != a ] ; then
    exec gnome-terminal --geometry=115x20 --hide-menubar --execute `readlink "$0"` "`pwd`"
fi

if [[ a$1 == a ]] ; then
	echo "$HELP" >&2
	exit 1
fi

export PATH="$PATH:`dirname $0`"

for D in "$@"
do
    if test -d "$D" ; then
	cd "$D"
	find . -mindepth 1 -maxdepth 1 -type d -exec $0 {} \;
	fix_mp3.sh --no-recursive .
	echo -n "======= Download covers in "
	pwd
	download_album_covers.sh .
	add_cover_to_mp3.sh .
	echo -n "======= Download LRC in "
	pwd
	ls *.mp3 >/dev/null 2>&1 && download_lrc.sh *.mp3
	ls *.ogg >/dev/null 2>&1 && download_lrc.sh *.ogg
	cd -
    fi
done