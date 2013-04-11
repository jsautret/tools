

check_dep() {
    PROG=$1
    PACKAGE=$2

    type $PROG 2> /dev/null && return 0

    if echo "$PACKAGE" | grep -qs '^https\?://'  ; then
	MESSAGE="See $PACKAGE to get it"
    else
	MESSAGE="On Debian/Ubuntu, install $PACKAGE package"
    fi


    cat <<EOF >&2

$PROG not Found.
$MESSAGE.

EOF
    exit 1
}