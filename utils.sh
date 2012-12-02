

check_dep() {
    PROG=$1
    PACKAGE=$2

    type $PROG 2> /dev/null && return 0

    cat <<EOF >&2

$PROG not Found.
On Debian/Ubuntu, install $2 package

EOF
    exit 1
}