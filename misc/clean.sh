#!/bin/bash

TRASH=$HOME/tmp/trash

test -d $TRASH || mkdir -p $TRASH

find $1 \( -name '*~' -o -name '*.bak' \) -print -exec mv {} $TRASH \;