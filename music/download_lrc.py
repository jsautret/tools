#!/usr/bin/env python

###########################################################################
# Copyright (c) 2012 Jerome Sautret
# This file is distributed under The MIT License (MIT).
# See http://opensource.org/licenses/MIT for details.

# helper script used by download_lrc.sh
###########################################################################

import engine
import sys



filename=sys.argv[1]
artist=sys.argv[2]
title=sys.argv[3]

results=engine.multiSearch(["miniLyrics", "ALSong", "lrcdb", "lyrdb", "evillyrics", "ttPlayer"], artist, title)

if results:
    e=results[0]
    result=e.orderResults(results[1], artist, title)[0]

    if engine.cmpResult(result, [artist, title]) == 1:
        lrc=e.downIt(result[2])[0]
        #
        file = open(filename, 'w')
        file.write(lrc)
        file.close()
        print filename
