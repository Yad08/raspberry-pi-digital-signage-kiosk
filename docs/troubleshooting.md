# Troubleshooting Guide

This document contains basic troubleshooting steps for the Raspberry Pi Digital Signage Kiosk.

## Quick Diagnostic Checklist

If the menu display is blank or not working, check:

1. Is the Raspberry Pi powered on?
2. Is the television powered on?
3. Is the HDMI cable connected?
4. Can the Raspberry Pi be reached over SSH?
5. Is `feh` running?
6. Did the screen automation intentionally turn the display off?
7. Did the Raspberry Pi recently reboot?

## Check Whether the Raspberry Pi Is Online

Try connecting over SSH:

```bash
ssh username@raspberrypi.local
```

If the SSH connection works, the Raspberry Pi itself is running.

If it does not work, possible causes include:

- Raspberry Pi lost power
- Raspberry Pi crashed
- Network connection is unavailable
- Hostname changed
- Wi-Fi connection failed

## Check System Uptime

Run:

```bash
uptime
```

Example:

```text
up 3 days, 4 hours
```

A short uptime may indicate that the Raspberry Pi recently restarted.

## Check Reboot History

Run:

```bash
last -x | head -20
```

This can show recent:

- reboots
- shutdowns
- system starts

You can also use:

```bash
journalctl --list-boots
```

## Check Whether FEH Is Running

Run:

```bash
pgrep -a feh
```

Expected output should show a process similar to:

```text
1234 /usr/bin/feh -F -Z -Y --auto-zoom /boot/firmware/kiosk_images/menu.png
```

If no output appears, the image viewer is not currently running.

## Check the Kiosk Log

Run:

```bash
tail -50 ~/kiosk.log
```

Look for messages such as:

```text
Screen OFF requested
```

or:

```text
Screen ON requested
```

If a screen-off request appears at the same time the display became blank, the kiosk software intentionally disabled the display.

## Follow the Log Live

Run:

```bash
tail -f ~/kiosk.log
```

This displays new log entries as they occur.

Press:

```text
Ctrl + C
```

to stop viewing the live log.

## Check Scheduled Jobs

Run:

```bash
crontab -l
```

Expected entries:

```cron
0 7 * * * /home/YOUR_USERNAME/screen_on.sh
0 22 * * * /home/YOUR_USERNAME/screen_off.sh
```

These mean:

```text
07:00 -> screen on
22:00 -> screen off
```

## Check Current Time and Timezone

Run:

```bash
date
```

and:

```bash
timedatectl
```

Make sure the system time is correct.

For a Central Time deployment:

```text
America/Chicago
```

To change the timezone:

```bash
sudo timedatectl set-timezone America/Chicago
```

## Manually Turn the Display On

Run:

```bash
~/screen_on.sh
```

If the display returns, the Raspberry Pi and menu application may still be functioning normally.

## Manually Turn the Display Off

Run:

```bash
~/screen_off.sh
```

## Check Wayland Display Outputs

Run:

```bash
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
wlopm
```

This can help verify whether the display output is visible to Wayland.

## Restart the Menu Viewer

Check for the current FEH process:

```bash
pgrep -a feh
```

If needed, stop it:

```bash
pkill feh
```

If `lwrespawn` is configured correctly, `feh` should automatically restart.

## Check the Menu Image

Verify that the image file exists:

```bash
ls -l /boot/firmware/kiosk_images/
```

Confirm the configured filename matches the actual file.

Example:

```text
menu.png
```

## Verify Labwc Autostart

View the file:

```bash
cat ~/.config/labwc/autostart
```

The configuration should include the screen state script and FEH startup command.

Example:

```bash
sleep 5
"$HOME/screen_state.sh" &

/usr/bin/lwrespawn /usr/bin/feh \
    -F \
    -Z \
    -Y \
    --auto-zoom \
    /boot/firmware/kiosk_images/menu.png &
```

## Blank Screen but Raspberry Pi Is Online

Possible causes include:

- Display was intentionally powered off
- FEH stopped running
- HDMI handshake issue
- Television input changed
- Television powered itself off
- Wayland output became unavailable
- Menu image path is incorrect

Recommended commands:

```bash
date
uptime
pgrep -a feh
crontab -l
tail -50 ~/kiosk.log
```

## Raspberry Pi Recently Rebooted

Possible causes include:

- Power outage
- Power supply issue
- Manual reboot
- Operating system crash
- Unexpected power loss

Check:

```bash
last -x | head -20
```

and:

```bash
journalctl --list-boots
```

## Before Rebooting During a Failure

If possible, avoid immediately rebooting the Raspberry Pi when something goes wrong.

Collect the following first:

```bash
date
uptime
pgrep -a feh
crontab -l
tail -50 ~/kiosk.log
last -x | head -20
```

This information can help determine the actual cause of the failure before the reboot clears useful evidence.
