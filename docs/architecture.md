# System Architecture

The Raspberry Pi functions as a dedicated digital signage appliance.

## Startup Process

1. Raspberry Pi boots.
2. Raspberry Pi OS starts the graphical session.
3. Labwc loads the user's autostart configuration.
4. The system waits five seconds for Wayland to initialize.
5. `screen_state.sh` determines whether the display should currently be active.
6. `feh` displays the restaurant menu fullscreen.
7. `lwrespawn` monitors FEH and restarts it if necessary.

## Display Power Management

The kiosk uses `wlopm` to control Wayland display outputs.

During business hours:

```text
wlopm --on '*'
