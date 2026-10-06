#!/bin/bash

export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

LOG="$HOME/kiosk.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Screen OFF requested" >> "$LOG"

/usr/bin/wlopm --off '*' >> "$LOG" 2>&1
EXIT_CODE=$?

echo "$(date '+%Y-%m-%d %H:%M:%S') - Screen OFF command completed with exit code $EXIT_CODE" >> "$LOG"

exit "$EXIT_CODE"
