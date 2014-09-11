# Remove unused log to save space

adb shell su -c "du /data/log ; rm /data/log/dumpstate*.log"
