# Raspberry Pi Digital Signage Kiosk

### Why I Built This

This project started with a very simple problem at my family’s restaurant, Cafe Madina.

For years, they used a printed vinyl menu banner and whenever prices changed, they would literally cover the old price with white duct tape and write in the new one. I decided it was finally time to modernize it.

I sourced and installed two TVs and initially thought USB thumb drives would be more than enough. My plan was simple: create the menu graphics, make a promotional video, load everything onto the drives, and let each TV loop its assigned content.

In theory, that should have been the end of it.

Instead, I started getting calls from the restaurant every couple of days saying that one or both TVs were off.

Because the TVs were identical, the same remote controlled both of them. One TV was supposed to display the static digital menu while the other played a repeating promotional video, so even changing settings became a small challenge. I would literally cover the IR sensor on one TV with my hand while configuring the other, then switch sides and repeat the process.

I changed the available power and sleep settings, but the problem kept coming back. I still do not know exactly what caused the TVs to shut themselves down. My best guess was that the TVs interpreted the lack of user interaction or media activity as inactivity and entered a power-saving state.

After about four days of dealing with it, I decided I needed a better solution.

I have been experimenting with Raspberry Pis, microcontrollers, and small computing projects since the COVID-19 pandemic. I had also previously configured and installed a Yodeck digital signage system for a friend using a Raspberry Pi, so I already knew the general direction I wanted to take.

The difference here was that this display did not need a full digital signage platform. It only needed to reliably show one static menu image.

I happened to have a spare Raspberry Pi with a damaged camera connector. It was no longer very useful for camera projects, but it was perfectly capable of becoming a dedicated embedded Linux edge device for the restaurant.

The first prototype was simple: could I make the Pi automatically display the menu fullscreen?

Once that worked, I started adding the functionality I actually needed:

- automatic fullscreen menu display at startup
- remote SSH access in case I could not physically be at the restaurant
- scheduled display power on and off
- reduced overnight screen usage to conserve energy and help prevent image retention
- automatic recovery if the image viewer closes
- startup logic that checks whether the restaurant is currently open or closed
- logging to make future troubleshooting easier
- 
What started as “just put the menu on a TV” turned into a small embedded Linux project designed around reliability and unattended operation.

And I am not going to lie — I still think it is really cool that a tiny, inexpensive Raspberry Pi Zero 2 W can handle all of this.

The project is still evolving, and I already have ideas for additional functionality, but for now I am mostly happy that I was able to build something practical that solved a real problem for my family’s small business.

So, This is a lightweight embedded Linux digital signage system built with a Raspberry Pi to display a restaurant menu continuously during business hours while automatically managing display power, startup behavior, and application recovery.

The system was built for **Cafe Madina** as a simple alternative to a full cloud-based digital signage platform. A Raspberry Pi Zero 2 W acts as a dedicated kiosk appliance connected to a television, automatically displaying a fullscreen menu image when the system boots.

## Features

- Automatically launches a fullscreen menu after boot
- Runs as a dedicated Raspberry Pi kiosk
- Uses Labwc/Wayland for desktop session control
- Displays menu graphics using `feh`
- Hides the mouse cursor for unattended operation
- Automatically turns the display on at 7:00 AM
- Automatically turns the display off at 10:00 PM
- Checks business hours whenever the Pi restarts
- Automatically relaunches the image viewer if it exits
- Logs display power events for troubleshooting
- Recovers automatically after power outages or unexpected reboots
- Designed for continuous unattended operation

## Project Motivation

Cafe Madina needed a simple digital menu display that could operate reliably without requiring staff to manually open files or configure the Raspberry Pi each day.

The primary requirements were:

1. Display a restaurant menu image fullscreen.
2. Automatically start after power loss or reboot.
3. Turn the television display off overnight.
4. Turn the display back on before opening.
5. Reduce unnecessary screen usage and potential image retention.
6. Require minimal interaction from restaurant staff.
7. Remain easy to troubleshoot remotely.

Instead of using a full content-management platform, this project uses standard Linux tools and lightweight shell automation.

## System Architecture

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
        Check Current Time       Start FEH
                  |                 |
         +--------+--------+        v
         |                 |    Menu Image
      Open Hours       Closed Hours
         |                 |
         v                 v
     Screen ON        Screen OFF


Scheduled Events
----------------

07:00 AM  --->  Display ON
10:00 PM  --->  Display OFF


Application Recovery
--------------------

FEH exits unexpectedly
        |
        v
    lwrespawn
        |
        v
FEH automatically restarts
```

## Hardware

- Raspberry Pi Zero 2 W
- MicroSD card
- HDMI display or television
- HDMI cable
- Raspberry Pi power supply
- Network connection for remote administration

This deployment was configured on a Raspberry Pi Zero 2 W.

## Software

- Raspberry Pi OS
- Debian Linux
- Labwc
- Wayland
- Bash
- `feh`
- `wlopm`
- `cron`

## Repository Structure

```text
.
├── README.md
├── LICENSE
├── .gitignore
├── scripts/
│   ├── screen_on.sh
│   ├── screen_off.sh
│   └── screen_state.sh
├── config/
│   ├── labwc-autostart
│   └── crontab.example
├── assets/
│   └── README.md
└── docs/
    ├── architecture.md
    └── troubleshooting.md
```

## How It Works

### Menu Display

Labwc automatically launches the image viewer after the graphical desktop session starts.

The kiosk uses:

```bash
/usr/bin/lwrespawn /usr/bin/feh -F -Z -Y --auto-zoom /path/to/menu.png
```

`feh` displays the image fullscreen while `lwrespawn` monitors the application and relaunches it if the image viewer unexpectedly exits.

### Display Power Management

The project uses `wlopm` to control Wayland display power.

Two scripts handle display state:

```text
screen_on.sh
screen_off.sh
```

The scripts explicitly define the Wayland runtime environment so they can also run from scheduled jobs.

### Business-Hour Automation

Cron schedules control the display:

```text
07:00 AM - Display ON
10:00 PM - Display OFF
```

A separate `screen_state.sh` script checks the current hour whenever the kiosk starts.

For example:

```text
Reboot at 2:00 PM
→ business hours detected
→ display remains ON

Reboot at 2:00 AM
→ closed hours detected
→ display turns OFF
```

This prevents a power outage during the night from causing the display to remain illuminated until the following evening.

## Installation

### 1. Install required packages

```bash
sudo apt update
sudo apt install feh wlopm -y
```

### 2. Copy the scripts

Place the scripts from the `scripts/` directory into the kiosk user's home directory.

Example:

```bash
cp scripts/screen_on.sh ~/
cp scripts/screen_off.sh ~/
cp scripts/screen_state.sh ~/
```

Make them executable:

```bash
chmod +x ~/screen_on.sh
chmod +x ~/screen_off.sh
chmod +x ~/screen_state.sh
```

### 3. Configure the menu image

Copy the menu image to a stable location.

Example:

```text
/boot/firmware/kiosk_images/menu.png
```

Update the menu path inside the Labwc autostart configuration if necessary.

### 4. Configure Labwc

Create the user configuration directory:

```bash
mkdir -p ~/.config/labwc
```

Copy:

```text
config/labwc-autostart
```

to:

```text
~/.config/labwc/autostart
```

Example:

```bash
cp config/labwc-autostart ~/.config/labwc/autostart
```

### 5. Configure scheduled display power

Edit the user crontab:

```bash
crontab -e
```

Add:

```cron
0 7 * * * /home/YOUR_USERNAME/screen_on.sh
0 22 * * * /home/YOUR_USERNAME/screen_off.sh
```

Replace `YOUR_USERNAME` with the Raspberry Pi user account.

### 6. Verify the timezone

Scheduled jobs depend on the system clock.

Check:

```bash
timedatectl
```

For a Central Time deployment:

```bash
sudo timedatectl set-timezone America/Chicago
```

### 7. Reboot

```bash
sudo reboot
```

Once the graphical environment starts, the menu should automatically appear fullscreen.

## Logging

The kiosk records display-control activity in:

```text
~/kiosk.log
```

Example:

```text
2026-10-05 07:00:01 - Screen ON requested
2026-10-05 07:00:01 - Screen ON command completed with exit code 0

2026-10-05 22:00:01 - Screen OFF requested
2026-10-05 22:00:01 - Screen OFF command completed with exit code 0
```

This makes it possible to determine whether a blank display was caused by an intentional scheduled event or another problem.

## Troubleshooting

Useful commands:

Check Raspberry Pi uptime:

```bash
uptime
```

Check whether FEH is running:

```bash
pgrep -a feh
```

Check display automation logs:

```bash
tail -50 ~/kiosk.log
```

Check scheduled jobs:

```bash
crontab -l
```

Check current system time:

```bash
date
timedatectl
```

Check recent reboot history:

```bash
last -x | head -20
```

## Future Improvements

Potential improvements include:

- remote menu image updates
- automatic synchronization from cloud storage
- watchdog monitoring
- network connectivity monitoring
- system health reporting
- web-based remote administration
- multiple menu rotations
- scheduled promotional graphics
- automatic recovery from HDMI disconnects
- migration from cron to systemd timers
- content versioning and rollback

## Project Skills

This project demonstrates experience with:

- Embedded Linux
- Raspberry Pi
- Linux system administration
- Bash scripting
- Process management
- Wayland
- Labwc
- Scheduled automation
- Display power management
- Remote troubleshooting
- System reliability
- Digital signage
- Hardware/software integration
- Edge computing

## Screenshots



### Final Installation
## Coming Soon


### Raspberry Pi Hardware

<table>
  <tr>
    <td>
      <img width="320" alt="Raspberry Pi hardware"
        src="https://github.com/user-attachments/assets/717d20cf-4429-413f-a840-065b2901cea4" />
    </td>
    <td>
      <img width="320" alt="Raspberry Pi case setup"
        src="https://github.com/user-attachments/assets/38de33e3-aabe-41f3-b372-2ba7f54ea225" />
    </td>
  </tr>
  <tr>
    <td>
      <img width="320" alt="Raspberry Pi components"
        src="https://github.com/user-attachments/assets/782b028f-559d-4614-bafa-df7356ea2f1f" />
    </td>
    <td>
      <img width="320" alt="Raspberry Pi configuration"
        src="https://github.com/user-attachments/assets/17171b7a-178a-48f5-a448-55fb58e11c02" />
    </td>
  </tr>
</table>


### Menu Display

### Before
<img width="320" height="158" alt="IMG_9216 Small" src="https://github.com/user-attachments/assets/96f0d651-b10e-452d-9b3d-0466376769ac" />

### After -    Coming Soon

## Background

This project was designed and deployed for a real restaurant environment where reliability and simplicity were more important than building a large software platform.

The Raspberry Pi functions as a dedicated edge device: once configured, it can recover from normal reboots and power interruptions while requiring minimal staff interaction.

## License

This project is available under the MIT License.
