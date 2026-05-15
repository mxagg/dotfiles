# Advanced Sway Setup — Full Custom Environment (LLM Agent Prompt)

You are setting up a complete, fully custom Sway tiling window manager environment on a fresh Ubuntu installation. This is an advanced configuration with custom scripts, a Dracula-themed waybar, clipboard manager, night light, OSD feedback bar, and all the tools needed for a productive daily-driver laptop workflow.

The user is experienced with Sway. Do not ask clarifying questions — just execute everything in order.

---

## Phase 1: Install All Required Packages

```bash
sudo apt update && sudo apt install -y \
  sway \
  waybar \
  wofi \
  swaylock \
  swayidle \
  grim \
  slurp \
  wl-clipboard \
  wtype \
  cliphist \
  brightnessctl \
  pamixer \
  pavucontrol \
  playerctl \
  mako-notifier \
  libnotify-bin \
  network-manager-gnome \
  xdg-desktop-portal-wlr \
  gammastep \
  wob \
  wdisplays \
  dex \
  fonts-font-awesome \
  power-profiles-daemon \
  flatpak
```

Then install Ghostty terminal (not in apt repos — install from official source):

```bash
# Ghostty - check https://ghostty.org/download for latest install method
# As of 2025+, install via the official .deb or build from source:
curl -fsSL https://ghostty.org/install.sh | bash
# If that doesn't work, fall back to the snap/flatpak or manual .deb:
# sudo snap install ghostty --classic
```

Install NoiseTorch (microphone noise suppression):

```bash
# Download latest release from https://github.com/noisetorch/NoiseTorch/releases
# Install to ~/.local/bin/
mkdir -p ~/.local/bin
curl -L -o /tmp/noisetorch.tgz "https://github.com/noisetorch/NoiseTorch/releases/latest/download/NoiseTorch_x64_v0.12.2.tgz"
tar -xzf /tmp/noisetorch.tgz -C ~/.local/bin/
# Grant capabilities
sudo setcap 'cap_sys_resource=+ep' ~/.local/bin/noisetorch
```

Install Meslo Nerd Font (used by terminal and waybar):

```bash
mkdir -p ~/.local/share/fonts
cd /tmp
curl -fLo "MesloLGMNerdFont-Regular.ttf" \
  "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
unzip -o Meslo.zip -d ~/.local/share/fonts/
fc-cache -fv
```

Install Cloudflare WARP (VPN):

```bash
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
sudo apt update && sudo apt install -y cloudflare-warp
warp-cli registration new
warp-cli connect
```

---

## Phase 2: Create Directory Structure

```bash
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/mako
mkdir -p ~/.config/gammastep
mkdir -p ~/.config/wob
```

---

## Phase 3: Sway Main Config

Create `~/.config/sway/config`:

```ini
# Sway Configuration — Advanced Custom Setup
# Mod4 = Super key, Ghostty terminal, Wofi launcher

### Variables
set $mod Mod4
set $left h
set $down j
set $up k
set $right l
set $term ghostty
set $menu dmenu_path | wmenu | xargs swaymsg exec --

include /etc/sway/config-vars.d/*

### Output configuration
output * bg /usr/share/backgrounds/sway/sway.jpg fill

### Input configuration
# Keyboard — Caps Lock swapped with Ctrl, GB layout
input type:keyboard {
    xkb_options ctrl:swapcaps
    xkb_layout gb
}

# Touchpad — tap, natural scroll, acceleration
input type:touchpad {
    dwt enabled
    tap enabled
    natural_scroll enabled
    pointer_accel 0.4
    scroll_factor 0.5
}

# Monitor setup (adjust for your hardware)
# Laptop internal display scaled for HiDPI
output eDP-1 scale 1.9 pos 1920 0
# External monitor at native res to the left
output HDMI-A-1 scale 1 pos 0 0

# Cursor theme
seat seat0 xcursor_theme Adwaita 24

### Key bindings — Basics
bindsym $mod+Return exec $term
bindsym $mod+Shift+q kill
bindsym $mod+d exec $menu
floating_modifier $mod normal
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'

### Navigation
bindsym $mod+$left focus left
bindsym $mod+$down focus down
bindsym $mod+$up focus up
bindsym $mod+$right focus right
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

bindsym $mod+Shift+$left move left
bindsym $mod+Shift+$down move down
bindsym $mod+Shift+$up move up
bindsym $mod+Shift+$right move right
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

### Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9
bindsym $mod+0 workspace number 10

bindsym $mod+Shift+1 move container to workspace number 1, workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2, workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3, workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4, workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5, workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6, workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7, workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8, workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9, workspace number 9
bindsym $mod+Shift+0 move container to workspace number 10, workspace number 10

# Dedicated backtick workspace
bindsym $mod+grave workspace terminal
bindsym $mod+Shift+grave move container to workspace terminal

# Quick switch to last workspace
bindsym $mod+Tab workspace back_and_forth

### Layout
bindsym $mod+b splith
bindsym $mod+v splitv
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+f fullscreen
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle
bindsym $mod+a focus parent

### Scratchpad
bindsym $mod+Shift+minus move scratchpad
bindsym $mod+minus scratchpad show

### Resize mode
mode "resize" {
    bindsym $left resize shrink width 10px
    bindsym $down resize grow height 10px
    bindsym $up resize shrink height 10px
    bindsym $right resize grow width 10px
    bindsym Left resize shrink width 10px
    bindsym Down resize grow height 10px
    bindsym Up resize shrink height 10px
    bindsym Right resize grow width 10px
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

### Picture-in-Picture
for_window [title="^Picture-in-Picture$"] floating enable, sticky enable, border pixel 2
for_window [title="^Picture-in-Picture$"] resize set 480 270, move position 1400 20

### Lock Screen & Idle
# Lock screen manually
bindsym $mod+Escape exec swaylock -f -i /usr/share/backgrounds/sway/sway.jpg -s fill

# Lock + suspend
bindsym $mod+Shift+s exec swaylock -f -i /usr/share/backgrounds/sway/sway.jpg -s fill && systemctl suspend

# Idle daemon — lock after 15min, screen off after 15.5min
exec swayidle -w \
    timeout 900 'swaylock -f -i /usr/share/backgrounds/sway/sway.jpg -s fill' \
    timeout 930 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -i /usr/share/backgrounds/sway/sway.jpg -s fill'

### Screenshot (region to clipboard)
bindsym $mod+s exec grim -g "$(slurp)" - | wl-copy

### App Launcher (Wofi — toggles on/off)
bindsym Control+space exec pkill wofi || wofi --show drun

### GUI Monitor Configuration
bindsym $mod+m exec wdisplays

### Clipboard History Picker
bindsym $mod+c exec ~/.config/sway/clipboard-picker.sh

### Media / Volume / Brightness (with OSD via wob)
bindsym XF86AudioRaiseVolume exec sh -c 'pamixer --increase 5; pamixer --get-volume > /tmp/wobpipe'
bindsym XF86AudioLowerVolume exec sh -c 'pamixer --decrease 5; pamixer --get-volume > /tmp/wobpipe'
bindsym XF86AudioMute exec sh -c 'pamixer --toggle-mute; if [ "$(pamixer --get-mute)" = "true" ]; then echo 0 > /tmp/wobpipe; else pamixer --get-volume > /tmp/wobpipe; fi'
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous
bindsym XF86MonBrightnessUp exec sh -c 'brightnessctl set +5%; brightnessctl -m | cut -d, -f4 | tr -d "%" > /tmp/wobpipe'
bindsym XF86MonBrightnessDown exec sh -c 'brightnessctl set 5%-; brightnessctl -m | cut -d, -f4 | tr -d "%" > /tmp/wobpipe'

### Autostart
exec dex --autostart --environment sway
exec nm-applet
exec warp-cli connect
exec gammastep
exec sh -c 'sleep 4 && noisetorch -i'
exec ~/.config/sway/battery-monitor.sh

# Kill dunst so mako takes over notifications
exec pkill -x dunst

# Clipboard history daemon
exec wl-paste --watch cliphist store

# OSD overlay bar (wob)
exec mkfifo /tmp/wobpipe && tail -f /tmp/wobpipe | wob

### Status Bar
# Kill default swaybar from distro includes
exec_always killall swaybar
# Launch waybar (kill old on reload)
exec_always pkill waybar; waybar

### Appearance
default_border none
default_floating_border none

include /etc/sway/config.d/*
```

---

## Phase 4: Custom Scripts

### `~/.config/sway/battery-monitor.sh`

```bash
#!/bin/bash

LAST_NOTIFIED=-1

while true; do
    BATTERY_PATH="/sys/class/power_supply/BAT0"
    
    if [ -d "$BATTERY_PATH" ]; then
        CAPACITY=$(cat "$BATTERY_PATH/capacity")
        STATUS=$(cat "$BATTERY_PATH/status")
        
        if [ "$STATUS" = "Discharging" ]; then
            if [ "$CAPACITY" -le 5 ] && [ "$LAST_NOTIFIED" -ne "$CAPACITY" ]; then
                notify-send -u critical -t 0 "🔋 CRITICAL BATTERY!" "Battery at ${CAPACITY}% - PLUG IN NOW!" 
                LAST_NOTIFIED=$CAPACITY
            elif [ "$CAPACITY" -le 10 ] && [ "$LAST_NOTIFIED" -ne "$CAPACITY" ]; then
                notify-send -u critical -t 10000 "⚠️ Low Battery Warning" "Battery at ${CAPACITY}% - Please charge soon"
                LAST_NOTIFIED=$CAPACITY
            fi
        else
            LAST_NOTIFIED=-1
        fi
    fi
    
    sleep 60
done
```

### `~/.config/sway/clipboard-picker.sh`

```bash
#!/bin/bash
# Clipboard history picker using cliphist + wofi
selection=$(cliphist list | wofi --show dmenu --prompt="Clipboard" --width=600 --height=400 --cache-file=/dev/null)
if [ -n "$selection" ]; then
    echo "$selection" | cliphist decode | wl-copy
    sleep 0.1
    wtype -M ctrl v -m ctrl
fi
```

### `~/.config/sway/gammastep-toggle.sh`

```bash
#!/bin/bash
# Toggle gammastep on/off and emit waybar signal
if pgrep -x gammastep > /dev/null; then
    pkill -x gammastep
else
    gammastep &
    disown
fi
pkill -RTMIN+10 waybar
```

### `~/.config/sway/performance-toggle.sh`

```bash
#!/bin/bash
# Toggle power profile: power-saver -> balanced -> performance -> power-saver
current=$(powerprofilesctl get)

case "$current" in
    power-saver)
        powerprofilesctl set balanced
        ;;
    balanced)
        powerprofilesctl set performance
        ;;
    performance)
        powerprofilesctl set power-saver
        ;;
esac

pkill -RTMIN+11 waybar
```

Make all scripts executable:

```bash
chmod +x ~/.config/sway/battery-monitor.sh
chmod +x ~/.config/sway/clipboard-picker.sh
chmod +x ~/.config/sway/gammastep-toggle.sh
chmod +x ~/.config/sway/performance-toggle.sh
```

---

## Phase 5: Waybar Config (Dracula Theme, Bottom Bar)

### `~/.config/waybar/config`

```json
{
    "layer": "top",
    "position": "bottom",
    "height": 24, 
    "spacing": 4,
    "modules-left": ["sway/workspaces", "sway/mode", "idle_inhibitor", "custom/nightlight", "custom/powerprofile"],
    "modules-center": ["mpris"],
    "modules-right": ["custom/vpn", "network", "pulseaudio", "battery", "clock", "tray"],

    "sway/workspaces": {
        "disable-scroll": true,
        "all-outputs": true
    },
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "☕",
            "deactivated": "💤"
        },
        "tooltip-format-activated": "Sleep prevention: ON",
        "tooltip-format-deactivated": "Sleep prevention: OFF"
    },
    "custom/nightlight": {
        "exec": "if pgrep -x gammastep > /dev/null; then echo '{\"text\": \"🌙\", \"class\": \"on\", \"tooltip\": \"Night Light: ON\"}'; else echo '{\"text\": \"☀️\", \"class\": \"off\", \"tooltip\": \"Night Light: OFF\"}'; fi",
        "return-type": "json",
        "interval": "once",
        "signal": 10,
        "on-click": "~/.config/sway/gammastep-toggle.sh"
    },
    "custom/powerprofile": {
        "exec": "profile=$(powerprofilesctl get); case $profile in performance) echo '{\"text\": \"🚀\", \"class\": \"performance\", \"tooltip\": \"Power: Performance\"}';; balanced) echo '{\"text\": \"⚡\", \"class\": \"balanced\", \"tooltip\": \"Power: Balanced\"}';; power-saver) echo '{\"text\": \"🔋\", \"class\": \"power-saver\", \"tooltip\": \"Power: Power Saver\"}';; esac",
        "return-type": "json",
        "interval": "once",
        "signal": 11,
        "on-click": "~/.config/sway/performance-toggle.sh"
    },
    "mpris": {
        "format": "{player_icon} {artist} - {title}",
        "format-paused": "{status_icon} {artist} - {title}",
        "player-icons": {
            "default": "▶",
            "spotify": ""
        },
        "status-icons": {
            "paused": "⏸"
        },
        "max-length": 50,
        "on-click": "playerctl play-pause",
        "on-click-right": "playerctl next"
    },
    "custom/vpn": {
        "exec": "if warp-cli status 2>/dev/null | grep -q 'Connected'; then echo '󰖂 Warp'; elif nmcli con show --active | grep -q 'vpn\\|tun\\|wireguard'; then echo '󰖂 VPN'; else echo '󰖂 None'; fi",
        "interval": 5,
        "format": "{}",
        "tooltip": false
    },
    "tray": {
        "spacing": 10
    },
    "clock": {
        "interval": 1,
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format": "{:%Y-%m-%d %H:%M:%S}",
        "format-alt": "{:%A, %B %d, %Y %H:%M:%S}"
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ⚡",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% {icon}",
        "format-muted": " Muted",
        "format-icons": {
            "headphone": "",
            "default": ["", ""]
        },
        "on-click": "pavucontrol"
    }
}
```

### `~/.config/waybar/style.css`

```css
* {
    border: none;
    border-radius: 0;
    font-family: "Meslo LGM Nerd Font", "DejaVu Sans Mono", monospace;
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: #000000;
    color: #f8f8f2;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #888888;
}

#workspaces button:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #ffffff;
}

#workspaces button.focused {
    background-color: #111111;
    box-shadow: inset 0 -2px #ffffff;
    color: #ffffff;
}

#clock {
    padding: 0 10px;
    background-color: #282a36;
    color: #f1fa8c;
}

#battery {
    padding: 0 10px;
    background-color: #44475a;
    color: #8be9fd;
}

#network {
    padding: 0 10px;
    background-color: #282a36;
    color: #50fa7b;
}

#pulseaudio {
    padding: 0 10px;
    background-color: #44475a;
    color: #ff79c6;
}

#tray {
    padding: 0 10px;
    background-color: #282a36;
}

#mode {
    padding: 0 10px;
    background-color: #ff5555;
    color: #f8f8f2;
    font-weight: bold;
}

#idle_inhibitor {
    padding: 0 10px;
    background-color: #282a36;
    color: #bd93f9;
}

#idle_inhibitor.activated {
    background-color: #50fa7b;
    color: #000000;
}

#custom-nightlight {
    padding: 0 10px;
}

#custom-nightlight.on {
    background-color: #282a36;
    color: #ffb86c;
}

#custom-nightlight.off {
    background-color: #282a36;
    color: #6272a4;
}

#mpris {
    padding: 0 10px;
    background-color: #44475a;
    color: #ffb86c;
}

#custom-vpn {
    padding: 0 10px;
    background-color: #282a36;
    color: #8be9fd;
}

#battery.charging {
    color: #50fa7b;
}

#battery.warning:not(.charging) {
    color: #ffb86c;
}

#battery.critical:not(.charging) {
    background-color: #ff5555;
    color: #f8f8f2;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

@keyframes blink {
    to {
        background-color: #f8f8f2;
        color: #ff5555;
    }
}

#custom-powerprofile {
    padding: 0 10px;
    background-color: #282a36;
}

#custom-powerprofile.performance {
    color: #ff5555;
}

#custom-powerprofile.balanced {
    color: #f1fa8c;
}

#custom-powerprofile.power-saver {
    color: #50fa7b;
}
```

---

## Phase 6: Ghostty Terminal Config

Create `~/.config/ghostty/config`:

```ini
# Fonts
font-family = "Meslo LGM Nerd Font"
font-size = 13

# Fix line-wrapping/cursor position issues
grapheme-width-method = unicode

# OLED Jet Black Theme
background = 000000
foreground = f8f8f2

# Window Appearance
window-decoration = false
window-padding-x = 8
window-padding-y = 8

# Native Tabs Configuration
window-theme = dark
gtk-tabs-location = bottom

# Trackpad and mouse scroll tuning
mouse-scroll-multiplier = precision:0.5,discrete:1.0

# Disable shell integration (conflicts with powerlevel10k prompt)
shell-integration = none

# Use xterm-256color for SSH compatibility
term = xterm-256color

# Ctrl+Backspace deletes previous word
keybind = ctrl+backspace=text:\x17
```

---

## Phase 7: Mako Notification Config (Dracula Theme)

Create `~/.config/mako/config`:

```ini
# Mako notification daemon — Dracula theme
font=Meslo LGM Nerd Font 11
background-color=#282a36
text-color=#f8f8f2
border-color=#6272a4
border-size=2
border-radius=8
padding=12
margin=8
width=380
height=150
max-visible=4
default-timeout=8000
layer=overlay
anchor=top-right

on-notify=none
on-button-left=invoke-default-action
on-button-right=dismiss

[urgency=low]
border-color=#44475a
default-timeout=5000

[urgency=normal]
border-color=#6272a4

[urgency=critical]
border-color=#ff5555
background-color=#44475a
default-timeout=0
```

---

## Phase 8: Gammastep (Night Light) Config

Create `~/.config/gammastep/config.ini`:

```ini
[general]
location-provider=manual

; Warm baseline during day, deeper red at night
temp-day=5500
temp-night=3400

; Smooth transitions matching sunrise/sunset
dawn-time=06:00-07:00
dusk-time=19:00-20:00

; Slight brightness reduction at night
brightness-day=1.0
brightness-night=0.9

gamma=1.0
fade=1
adjustment-method=wayland

[manual]
lat=51.5
lon=-0.1

[wayland]
```

---

## Phase 9: Wob (OSD Overlay Bar) Config

Create `~/.config/wob/wob.ini`:

```ini
timeout = 1000
max = 100
width = 400
height = 30
border_offset = 0
border_size = 2
bar_padding = 2
anchor = bottom
margin = 50
bar_color = bd93f9FF
background_color = 282a36FF
border_color = 6272a4FF
overflow_bar_color = ff5555FF
```

---

## Phase 10: Final Steps

### Set correct permissions

```bash
chmod +x ~/.config/sway/*.sh
```

### Verify sway config syntax

```bash
sway --validate 2>&1 || echo "Config has errors — review above"
```

### Enable required systemd services

```bash
# Power profiles daemon
sudo systemctl enable --now power-profiles-daemon

# NetworkManager (should already be running from GNOME)
sudo systemctl enable --now NetworkManager
```

### Notes for first login

1. Log out, select "Sway" from the GDM gear menu, log in.
2. Key bindings quick reference:
   - `Ctrl+Space` — App launcher (Wofi)
   - `Mod+Return` — Terminal (Ghostty)
   - `Mod+S` — Screenshot region to clipboard
   - `Mod+C` — Clipboard history
   - `Mod+Escape` — Lock screen
   - `Mod+Shift+S` — Lock + suspend
   - `Mod+M` — Monitor config GUI
   - `Mod+Tab` — Switch to last workspace
   - `Mod+Shift+C` — Reload config
   - `Mod+Shift+E` — Exit sway

3. Waybar clickable modules:
   - Click 🌙/☀️ to toggle night light
   - Click 🚀/⚡/🔋 to cycle power profiles
   - Click ▶ in center to play/pause media
   - Click volume to open pavucontrol

4. **Adjust `output` lines in sway config** for your specific monitor setup. Use `swaymsg -t get_outputs` to identify connected displays, then edit accordingly.

5. **Adjust gammastep lat/lon** in `~/.config/gammastep/config.ini` for your location.

---

## Rules for the Agent

- Create backups of any existing config files before overwriting: `cp file file.backup.$(date +%Y%m%d-%H%M%S)`
- Write all files exactly as specified — do not simplify, summarize, or omit sections
- Make all `.sh` files executable
- Run `sway --validate` at the end to confirm the config is valid
- If any package fails to install, note it and continue with the rest
- Do NOT install or configure a display manager — assume GDM is already present from GNOME
- Do NOT remove GNOME — it stays as a fallback
