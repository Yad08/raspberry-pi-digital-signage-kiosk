#!/bin/bash

LOG="$HOME/kiosk.log"

OPEN_HOUR=7
CLOSE_HOUR=22

HOUR=$(date +%H)

echo "$(date '+%Y-%m-%d %H:%M:%S') - Screen state check started" >> "$LOG"

if [ "$HOUR" -ge "$OPEN_HOUR" ] && [ "$HOUR" -lt "$CLOSE_HOUR" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Open hours detected" >> "$LOG"
    "$HOME/screen_on.sh"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Closed hours detected" >> "$LOG"
    "$HOME/screen_off.sh"
fi
