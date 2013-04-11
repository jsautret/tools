#!/bin/bash

check_mp3() {
    while read F
    do
	MP3="`echo ${F%%.bak}`"
	file "$MP3"
    done
}

find $1 -name '*.bak' | check_mp3 | grep -v "Audio file with ID3"