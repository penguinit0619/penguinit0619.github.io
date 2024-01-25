+++
author = "penguinit"
Title = "xfce Desktop Monitor Sleep Control"
date = "2024-01-21"
Description = "Most of the time, I use a Linux laptop. Among them, I use Xfce-based Xubuntu, and I remember that in the past, it worked well if I removed the power saving mode from the GUI, but even though I turned off all the settings, there is a phenomenon that keeps going into power saving mode, so I record the solution process."
tags = [
"xfce", "xubuntu"
]

categories = [
"linux",
]
+++

## Overview

I have several laptops, but I mostly use Linux laptops these days. Among them, I use Xfce-based [Xubuntu] (https://xubuntu.org/) , but I remember removing the sleep mode from the GUI worked well in the past, but even though I turned off all the settings, there is a phenomenon that keeps going into sleep mode, so I record the solution process.

## a problem

I don't know why, but there was a phenomenon that the monitor went into power saving mode every 5 minutes even though the display power manager was turned off.

![Untitled](images/Untitled.png)

## Resolution process

First of all, after looking at various things, I thought it would be most accurate to look at the x window setting, so I checked it as below.

```bash
xset -q
```

```bash
Keyboard Control:
auto repeat: on key click percent: 0 LED mask: 00000000
XKB indicators:
00: Caps Lock: off 01: Num Lock: off 02: Scroll Lock: off
03: Compose: off 04: Kana: off 05: Sleep: off
06: Suspend: off 07: Mute: off 08: Misc: off
09: Mail: off 10: Charging: off 11: Shift Lock: off
12: Group 2: off 13: Mouse Keys: off
auto repeat delay: 500 repeat rate: 20
auto repeating keys: 00ffffffdffffbbf
fadfffefffffffff
9fffffffffffffff
fff7ffffffffffff
bell percent: 50 bell pitch: 400 bell duration: 100
Pointer Control:
acceleration: 2/1 threshold: 4
Screen Saver:
prefer blanking: no allow exposures: no
timeout: 300 cycle: 300
Colors:
default colormap: 0x20 BlackPixel: 0x0 WhitePixel: 0xffffff
Font Path:
/usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1,built-ins
DPMS (Energy Star):
Standby: 600 Suspend: 600 Off: 600
DPMS is Enabled
Monitor is On
```

When I checked, **Screen Saver** was set to sleep every 5 minutes, so I executed the command as below.

```bash
xset -q
```

```bash
Keyboard Control:
auto repeat: on key click percent: 0 LED mask: 00000000
XKB indicators:
00: Caps Lock: off 01: Num Lock: off 02: Scroll Lock: off
03: Compose: off 04: Kana: off 05: Sleep: off
06: Suspend: off 07: Mute: off 08: Misc: off
09: Mail: off 10: Charging: off 11: Shift Lock: off
12: Group 2: off 13: Mouse Keys: off
auto repeat delay: 500 repeat rate: 20
auto repeating keys: 00ffffffdffffbbf
fadfffefffffffff
9fffffffffffffff
fff7ffffffffffff
bell percent: 50 bell pitch: 400 bell duration: 100
Pointer Control:
acceleration: 2/1 threshold: 4
Screen Saver:
prefer blanking: no allow exposures: no
timeout: 300 cycle: 300
Colors:
default colormap: 0x20 BlackPixel: 0x0 WhitePixel: 0xffffff
Font Path:
/usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1,built-ins
DPMS (Energy Star):
Standby: 600 Suspend: 600 Off: 600
DPMS is Enabled
Monitor is On
```

When I checked, **Screen Saver** was set to sleep every 5 minutes, so I executed the command as below.

```bash
xset s off
xset -q
```

```bash
Keyboard Control:
auto repeat: on key click percent: 0 LED mask: 00000000
XKB indicators:
00: Caps Lock: off 01: Num Lock: off 02: Scroll Lock: off
03: Compose: off 04: Kana: off 05: Sleep: off
06: Suspend: off 07: Mute: off 08: Misc: off
09: Mail: off 10: Charging: off 11: Shift Lock: off
12: Group 2: off 13: Mouse Keys: off
auto repeat delay: 500 repeat rate: 20
auto repeating keys: 00ffffffdffffbbf
fadfffefffffffff
9fffffffffffffff
fff7ffffffffffff
bell percent: 50 bell pitch: 400 bell duration: 100
Pointer Control:
acceleration: 2/1 threshold: 4
Screen Saver:
prefer blanking: no allow exposures: no
timeout: 0 cycle: 300
Colors:
default colormap: 0x20 BlackPixel: 0x0 WhitePixel: 0xffffff
Font Path:
/usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1,built-ins
DPMS (Energy Star):
Standby: 600 Suspend: 600 Off: 600
DPMS is Enabled
Monitor is On
```

If you check the Screen Saver after the command above, you can see that the timeout is set to 0.

Since application, the display has not been reduced every 5 minutes.

### What is the xset off command?

'xset' is a tool to change user settings on X Windows systems. The 'xset off' command disables the screen saver and the screen off function. This setting must be applied manually on a per-session basis, which means you have to run it again every time you reboot your computer.

## ****How to set up automatic execution when booting****

### Create a .desktop file

You can set the 'xset off' command to run automatically at boot-up using the 'Automatic Application Start' feature provided by the Xfce environment. To do this, create the '.desktop' file
(ex. **disable_screensaver.desktop**)

```bash
[Desktop Entry]
Type=Application
Exec=bash -c "sleep 10; xset s off"
Name=Disable Screen Saver
Comment=Disables the screen saver at startup with a delay
X-GNOME-Autostart-enabled=true
```

This file runs at Xfce startup and disables the screen saver after a 10 second delay after booting with the **bash -c "sleep 10; xset off"** command.

### Why set a 10-second delay?

Ideal to run 'xset off' command immediately during bootup