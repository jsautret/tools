

DIRNAME="`dirname $0`"
. "$DIRNAME"/../utils.sh

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


is_mp3() {
    FILE="$1"
    file "$FILE" | grep -i audio | grep -i ID3 >/dev/null 2>/dev/null
}

is_ogg() {
    FILE="$1"
    file "$FILE" | grep -i audio| grep -i Vorbis >/dev/null 2>/dev/null
}

get_tag_totem() {
    FILE="$2"
    TAG="$1"
    if [ "$TAG" == ALBUM_ARTIST ] || [ "$TAG" == TRACKTOTAL ]; then
	get_tag_avconv "$TAG" "$FILE"
    else
	totem-video-indexer "$FILE" |grep "^TOTEM_INFO_$TAG="|sed 's/^[^=]*=//' #| iconv -f latin1 -t utf8
    fi
}

get_tag() {
    FILE="$2"
    TAG="$1"
    get_tag_avconv "$TAG" "$FILE"
}

get_tag_avconv() {
    FILE="$2"
    TAG="$1"
    avconv -i "$FILE" 2>&1 |grep -i "^ *$TAG *:"|sed 's/^[^:]*: *//' #| iconv -f latin1 -t utf8
}

get_tag_lltag() {
    FILE="$2"
    TAG="$1"
    lltag --mp3v2 --mp3read=2 --show-tags "$TAG" "$FILE"|grep "$TAG" |\
        cut -d= -f 2 #| iconv -f latin1 -t utf8
}
