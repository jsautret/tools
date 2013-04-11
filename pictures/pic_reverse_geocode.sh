#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Copyright (c) 2013 Jérôme Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.
HELP="
Usage:
$PROGNAME [-l CITY COUNTRY COUNTRY_CODE]  FILE.jpg [FILES.jpg...]

Add location tags (if missing) to pictures by geodecoding the GPS
coordinates embedded in the Exif tags. If no GPS coordinates are
present in the file, use command line parameters CITY, COUNTRY
and COUNTRY_CODE in -l parameter is present.

$PROGNAME -d FILE.jpg [FILES.jpg...]

Delete locations tags.

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

check_dep exiv2 exiv2
check_dep curl curl
check_dep jshon http://kmkeen.com/jshon/index.html

TMP="`mktemp`"

get_coordinate()
{
    T=$1
    FILE="$2"

    exiv2 -P v -g Exif.GPSInfo.GPS${T}Ref pr "$FILE" 2>/dev/null | sed 's/S\|W/-/' | sed 's/N\|E//' | tr -d '\n'
    exiv2 -P v -g Exif.GPSInfo.GPS$T pr "$FILE" 2>/dev/null |\
         sed 's%^\(.*\) \(.*\) \(.*\)$%scale=6\n\1+\2/60+\3/3600%' | bc
}

get_component()
{
    TYPE=$1
    NAME=$2
    I=`jshon -e results -e 0 -e address_components -a -e types -e 0 -u  <$TMP | grep -nx $TYPE | cut -d: -f1`
    [ -z "$I"  ] && return 1
    jshon -e results -e 0 -e address_components -e $(($I-1)) -e ${NAME}_name -u  <$TMP
}

geodecode() {
    X=$1
    Y=$2
    curl -s "http://maps.googleapis.com/maps/api/geocode/json?latlng=$X,$Y&sensor=false" >$TMP
}


if [ "$1" == -d ] ; then
    shift
    echo "Deleting location tags"
    exiv2 \
	-M "del Xmp.iptc.Location" \
	-M "del Xmp.iptcExt.CountryName" \
	-M "del Xmp.iptcExt.CountryCode" \
	-M "del Xmp.iptcExt.City" \
	-M "del Xmp.photoshop.Country " \
	-M "del Xmp.photoshop.City " \
	-M "del Iptc.Application2.CountryName" \
	-M "del Iptc.Application2.CountryCode" \
	-M "del Iptc.Application2.City" \
	"$@"
    exit $?
fi

UCITY=""
UCOUNTRY=""
UCOUNTRY_CODE=""
if [ "$1" == -l ] ; then
    UCITY=$2
    UCOUNTRY=$3
    UCOUNTRY_CODE=$4
    shift 4
fi

echo
for FILE in "$@"
do
    echo -n "$FILE:"

    set +o errexit
    CURRENT_LOCATION="`exiv2 -P v -g Xmp.iptc.Location pr "$FILE"`"
    set -o errexit
    if [ -n "$CURRENT_LOCATION" ] ; then
	echo " keeping '$CURRENT_LOCATION'"
	continue
    fi

    X=`get_coordinate Latitude "$FILE"`
    if [ -n "$X" ] ; then
	Y=`get_coordinate Longitude "$FILE"`

	echo -n " $X,$Y"

	geodecode $X $Y

	if [[ "`jshon -e status -u <$TMP`" == OVER_QUERY_LIMIT ]] ; then
	    echo -n "..."
	    # Google API cooldown
	    sleep 1
	    geodecode $X $Y
	else
	    echo -n "   "
	fi

	if [[ "`jshon -e status -u <$TMP`" != OK ]] ; then
	    echo "ERROR returned by external API:" >&2
	    cat $TMP >&2
	    exit 1
	fi

	set +o errexit
	COUNTRY="`get_component country long`"
	if [ $? != 0  ] ; then
	    echo "no country found" >&2
	    continue
	fi
	COUNTRY_CODE="`get_component country short`"
	if [ $? != 0  ] ; then
	    echo "no country code found" >&2
	    continue
	fi
	CITY="`get_component locality long`"
	if [ $? != 0  ] ; then
	    echo "no city found" >&2
	    continue
	fi
	set -o errexit
    else
	if [ -n "$UCOUNTRY_CODE"  ] ; then
	    COUNTRY=$UCOUNTRY
	    COUNTRY_CODE=$UCOUNTRY_CODE
	    CITY=$UCITY
	else
	    echo " no GPS info"
	    continue
	fi
    fi

    echo " setting location $CITY, $COUNTRY ($COUNTRY_CODE)"

    exiv2 \
	-M "set Xmp.iptc.Location \"$CITY, $COUNTRY ($COUNTRY_CODE)\"" \
	-M "set Xmp.iptcExt.CountryName \"$COUNTRY\"" \
	-M "set Xmp.iptcExt.CountryCode \"$COUNTRY_CODE\"" \
	-M "set Xmp.iptcExt.City \"$CITY\"" \
	-M "set Xmp.photoshop.Country \"$COUNTRY\"" \
	-M "set Xmp.photoshop.City \"$CITY\"" \
	-M "set Iptc.Application2.CountryName \"$COUNTRY\"" \
	-M "set Iptc.Application2.CountryCode \"$COUNTRY_CODE\"" \
	-M "set Iptc.Application2.City \"$CITY\"" \
	"$FILE"

done
echo
rm $TMP

exit $?

Xmp.iptc.Location : eog
Xmp.iptcExt.CountryName
Xmp.iptcExt.LocationShown.CountryName
Xmp.photoshop.Country
Iptc.Application2.CountryName