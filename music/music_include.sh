

DIRNAME="`dirname $0`"
. "$DIRNAME"/../utils.sh

check_dep totem-video-indexer totem

urlencode() {
    sed -e's/./&\n/g' -e's/ /%20/g' | grep -v '^$' |\
     while read CHAR
     do
	test "${CHAR}" = "%20" && echo "${CHAR}" || echo "${CHAR}" |\
          grep -E '[-[:alnum:]!*.'"'"'()]|\[|\]' || echo -n "${CHAR}" |\
            od -t x1 | tr ' ' '\n' | grep '^[[:alnum:]]\{2\}$' | tr '[a-z]' '[A-Z]' |\
               sed -e's/^/%/g'
    done | sed -e's/%20/+/g' | tr -d '\n'
}


get_tag() {
    FILE="$2"
    TAG="$1"
    totem-video-indexer "$FILE" |grep "^TOTEM_INFO_$TAG="|sed 's/^[^=]*=//' #| iconv -f latin1 -t utf8
}

get_tag_ffmpeg() {
    FILE="$2"
    TAG="$1"
    ffmpeg -i "$FILE" 2>&1 |grep -i "^ *$TAG *:"|sed 's/^[^:]*: *//' | iconv -f latin1 -t utf8
}

get_tag_lltag() {
    FILE="$2"
    TAG="$1"
    lltag --mp3v2 --mp3read=2 --show-tags "$TAG" "$FILE"|grep "$TAG" |\
        cut -d= -f 2 | iconv -f latin1 -t utf8
}
