#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2012 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME FILE.lrc [FILES.lrc...]

Remove the offset and recalculate all timestamps in lyrics LRC files.

"
###########################################################################

if [[ a$1 == a ]] ; then
    echo "$HELP" >&2
    exit 1
fi

process_line() {
    local OFFSET=-$1
    local OM=0
    local LINE=$2
    if ! echo "$LINE" | grep -q '^[[][0-9]\+:[0-9]\+\(\.[0-9]\+\)\?[]]' ; then
	echo "$LINE"
	return
    fi
    if echo "$LINE" | grep -q '^[[][0-9]\+:[0-9]\+\.[0-9]\+[]]' ; then
	local MS=$(echo "$LINE" | sed 's/^[[][0-9]\+:[0-9]\+.\([0-9]\+\)[]].*$/\1/')
    else
	local MS=000
    fi
    local S=$(echo "$LINE" | sed 's/^[[][0-9]\+:\([0-9]\+\)\(\.[0-9]\+\)\?[]].*$/\1/')
    local M=$(echo "$LINE" | sed 's/^[[]\([0-9]\+\):[0-9]\+\(\.[0-9]\+\)\?[]].*$/\1/')
    local TEXT=$(echo "$LINE" | sed 's/^[[][0-9]\+:[0-9]\+\(\.[0-9]\+\)\?[]]\(.*\)$/\2/')
    #echo "$M:$S.$MS" >&2

    local MSL=$(echo -n $MS | wc -c)
    local MSS=$((10**$MSL))

    #echo $MS >&2
    #echo $MSS >&2

    OS=$(($OFFSET / 1000 ))
    OMS=$(($OFFSET % 1000 / 10**(3-$MSL) ))

    MS=$(seq $MS $MS)
    S=$(seq $S $S)
    M=$(seq $M $M)

    MS=$(($MS + $OMS))
    if (( $MS < 0 )) ; then
	MS=$(($MSS+$MS))
	OS=$(($OS-1))
    fi
    OS=$(($OS + $MS / $MSS))
    MS=$(($MS % $MSS))

    S=$(($S + $OS))
    if (( $S < 0 )) ; then
	S=$((60+$S))
	OM=-1
    fi
    OM=$(($OM + $S / 60))
    S=$(($S % 60))

    M=$(($M+$OM))
    if (( $M < 0 )) ; then
	M=0
	S=0
	MS=0
    fi
    echo -n . >&2
    printf "[%02d:%02d.%0${MSL}d]%s\n" $M $S $MS "$TEXT"
}


for F in "$@"
do
    dos2unix --keepdate --quiet "$F"

    OFFSET=$(grep '^[[]offset:[-+]\?[0-9]\+[]] *$' "$F" |
	    sed 's/^[[]offset:\([-+]\?[0-9]\+\)[]] *$/\1/')
    if test ! -z $OFFSET ; then
	OLD="$F~"
	NEW="$F".new
	cp "$F" "$OLD"

	if grep -q '^[[]encoding:iso-8859[^]]\+[]] *$' "$F" ; then
	    LANG=fr_FR.iso885915@euro
	    LC_ALL=fr_FR.iso885915@euro
	fi

	# Fix one liner files
	sed "s/.\([[][0-9]\+:[0-9]\+\(\.[0-9]\+\)\?[]]\)/\\
\1/g" "$OLD" > "$F"

	echo -n "Converting '$F' with offset $OFFSET" >&2
	while read L
	do
	    case "$L" in
		[offset:* ) ;;
		[00:00.00* ) echo "$L";;
		* ) process_line $OFFSET "$L" ;;
	    esac
	done < "$F" >"$NEW"
	mv "$NEW" "$F"
	echo >&2
    fi
done