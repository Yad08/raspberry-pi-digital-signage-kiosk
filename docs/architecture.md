# System Architecture

This project turns a Raspberry Pi into a dedicated digital signage appliance for a restaurant environment.

The system is intentionally lightweight. Instead of relying on a cloud-based signage platform, the Raspberry Pi handles the core display logic locally.

## Overview

The Raspberry Pi is connected to a television over HDMI and automatically displays a static restaurant menu image during business hours.

The system also manages:

- automatic startup
- fullscreen image display
- screen power scheduling
- restart recovery
- process recovery
- remote SSH access
- basic logging for troubleshooting

## Startup Flow

When the Raspberry Pi boots:

1. Raspberry Pi OS starts.
2. The graphical session launches.
3. Labwc starts the kiosk autostart configuration.
4. The system waits briefly for the Wayland session to initialize.
5. `screen_state.sh` checks the current local time.
6. The display is turned on or off depending on business hours.
7. `feh` launches the menu image fullscreen.
8. `lwrespawn` monitors `feh` and restarts it if it exits unexpectedly.

## Architecture Diagram

```text
                  POWER ON / REBOOT
                          |
                          v
                  Raspberry Pi OS
                          |
                          v
                    Labwc / Wayland
                    /             \
                   /               \
                  v                 v
         Check Current Time      Start FEH
                  |                 |
         +--------+--------+        v
         |                 |     Menu Image
      Open Hours       Closed Hours
         |                 |
         v                 v
      Screen ON        Screen OFF
```

## Display Scheduling

The display is controlled using `wlopm`.

During business hours:

```bash
wlopm --on '*'
```

Outside business hours:

```bash
wlopm --off '*'
```

The default schedule is:

```text
07:00 AM -> Display ON
10:00 PM -> Display OFF
```

These times can be changed in the crontab configuration and in `screen_state.sh`.

## Boot-Time State Recovery

The scheduled cron jobs only run at specific times, so a reboot between scheduled events could otherwise leave the display in the wrong state.

To prevent this, `screen_state.sh` runs whenever the kiosk starts.

Example:

```text
Pi reboots at 2:00 PM
        |
        v
Open hours detected
        |
        v
Display ON
```

```text
Pi reboots at 2:00 AM
        |
        v
Closed hours detected
        |
        v
Display OFF
```

This helps the kiosk recover correctly after:

- power outages
- manual reboots
- unexpected restarts

## Menu Playback

The menu image is displayed using `feh`.

Example:

```bash
/usr/bin/feh -F -Z -Y --auto-zoom /path/to/menu.png
```

The options are used to:

- display the image fullscreen
- automatically scale the image
- hide the mouse pointer
- fit the image to the display

## Application Recovery

The menu viewer is launched using `lwrespawn`.

```bash
/usr/bin/lwrespawn /usr/bin/feh ...
```

If `feh` unexpectedly exits, `lwrespawn` relaunches it.

This is useful for unattended operation because the menu does not depend on a staff member manually reopening the application.

## Logging

Screen power actions are recorded in:

```text
~/kiosk.log
```

Example entries:

```text
2026-10-06 07:00:01 - Screen ON requested
2026-10-06 07:00:01 - Screen ON command completed with exit code 0

2026-10-06 22:00:01 - Screen OFF requested
2026-10-06 22:00:01 - Screen OFF command completed with exit code 0
```

These logs help distinguish between:

- scheduled screen shutdowns
- application failures
- Raspberry Pi reboots
- HDMI or television issues

## Remote Administration

The Raspberry Pi can be managed remotely using SSH.

Example:

```bash
ssh username@raspberrypi.local
```

This allows maintenance and troubleshooting without requiring physical access to the kiosk.

## Design Philosophy

The project was designed around a few priorities:

- simplicity
- low cost
- reliability
- local operation
- easy maintenance
- recovery after common failures

The Raspberry Pi performs the essential signage functions locally, making it suitable as a small embedded Linux edge device for a dedicated display task.
