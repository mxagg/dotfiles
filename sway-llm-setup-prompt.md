# Sway Window Manager Setup — LLM Agent Prompt

You are helping a user transition from GNOME to the Sway tiling window manager on Ubuntu/Debian. Your job is to install the necessary packages, ask the user about their preferred key mappings, and then generate a clean, reliable, minimal Sway configuration.

---

## Phase 1: Install Essential Packages

Run the following to install all required components:

```bash
sudo apt update && sudo apt install -y \
  sway \
  waybar \
  foot \
  wofi \
  swaylock \
  swayidle \
  grim \
  slurp \
  wl-clipboard \
  brightnessctl \
  pamixer \
  playerctl \
  mako-notifier \
  libnotify-bin \
  network-manager-gnome \
  xdg-desktop-portal-wlr \
  fonts-font-awesome
```

After installation, confirm to the user what was installed and briefly explain what each package does:
- **sway** — the tiling Wayland compositor (i3-compatible)
- **waybar** — status bar (clock, workspaces, system tray)
- **foot** — lightweight Wayland-native terminal emulator
- **wofi** — application launcher (like GNOME's Activities search)
- **swaylock** — screen locker
- **swayidle** — idle management (auto-lock, screen off)
- **grim + slurp** — screenshot tools (region select + capture)
- **wl-clipboard** — clipboard utilities for Wayland (needed for screenshot-to-clipboard)
- **brightnessctl** — screen brightness control
- **pamixer** — PulseAudio volume control from CLI
- **playerctl** — media playback control (play/pause/next/prev)
- **mako-notifier** — lightweight notification daemon
- **libnotify-bin** — lets apps send desktop notifications
- **network-manager-gnome** — network manager system tray applet (nm-applet)
- **xdg-desktop-portal-wlr** — enables screen sharing in browsers/apps
- **fonts-font-awesome** — icon font used by waybar

---

## Phase 2: Ask About Key Mapping Preferences

Before generating the config, ask the user the following questions. Present the **defaults shown below** and let them accept all defaults or customize individual bindings.

Present it like this:

> Here are the recommended default key mappings for your Sway config. You can accept all of them by saying "use defaults", or tell me which ones you'd like to change.
>
> | # | Action | Default Binding | Notes |
> |---|--------|-----------------|-------|
> | 1 | **Mod key** | `Super` (Windows key) | Alternative: `Alt` |
> | 2 | **Open terminal** | `Mod+Return` | Opens foot terminal |
> | 3 | **App launcher** | `Ctrl+Space` | Opens wofi (like GNOME Activities) |
> | 4 | **Kill focused window** | `Mod+Shift+Q` | Closes the active window |
> | 5 | **Lock screen** | `Mod+Escape` | Locks with swaylock |
> | 6 | **Screenshot (region)** | `Mod+S` | Select area, copies to clipboard |
> | 7 | **Fullscreen toggle** | `Mod+F` | Makes focused window fullscreen |
> | 8 | **Toggle floating** | `Mod+Shift+Space` | Float/unfloat a window |
> | 9 | **Focus navigation** | `Mod+H/J/K/L` (vim) + Arrow keys | Move focus between windows |
> | 10 | **Move window** | `Mod+Shift+H/J/K/L` + Shift+Arrows | Move window in layout |
> | 11 | **Switch workspace** | `Mod+1` through `Mod+0` | Workspaces 1–10 |
> | 12 | **Move window to workspace** | `Mod+Shift+1` through `Mod+Shift+0` | Sends window to workspace |
> | 13 | **Horizontal split** | `Mod+B` | Next window opens to the right |
> | 14 | **Vertical split** | `Mod+V` | Next window opens below |
> | 15 | **Tabbed layout** | `Mod+W` | Stack windows as tabs |
> | 16 | **Toggle split layout** | `Mod+E` | Switch between split orientations |
> | 17 | **Focus parent** | `Mod+A` | Select parent container |
> | 18 | **Scratchpad (hide)** | `Mod+Shift+Minus` | Send window to scratchpad |
> | 19 | **Scratchpad (show)** | `Mod+Minus` | Show/cycle scratchpad windows |
> | 20 | **Enter resize mode** | `Mod+R` | Then use H/J/K/L or arrows to resize |
> | 21 | **Reload config** | `Mod+Shift+C` | Reload sway config without logout |
> | 22 | **Exit sway** | `Mod+Shift+E` | Log out (with confirmation prompt) |
> | 23 | **Switch to last workspace** | `Mod+Tab` | Toggle between last two workspaces |

Wait for the user's response before proceeding. Store their choices for use in Phase 3.

---

## Phase 3: Generate the Sway Config

Create the directory and config file:

```bash
mkdir -p ~/.config/sway
```

Generate `~/.config/sway/config` using the user's key mapping choices (or defaults if they accepted them). The config should follow this exact structure, substituting any changed bindings:

```ini
# Sway Configuration
# Generated for a clean transition from GNOME

### Variables
set $mod Mod4
set $term foot
set $menu wofi --show drun
set $left h
set $down j
set $up k
set $right l

### Output configuration
# Set your wallpaper (change path as desired)
output * bg /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill

### Input configuration
# Touchpad — tap to click + natural scrolling (like GNOME default)
input type:touchpad {
    dwt enabled
    tap enabled
    natural_scroll enabled
    middle_emulation enabled
}

### Key bindings — Basics
bindsym $mod+Return exec $term
bindsym $mod+Shift+q kill
bindsym Control+space exec pkill wofi || $menu
floating_modifier $mod normal
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'

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

bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9
bindsym $mod+Shift+0 move container to workspace number 10

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

### Lock screen
bindsym $mod+Escape exec swaylock -f -c 333333

### Screenshot (region to clipboard)
bindsym $mod+s exec grim -g "$(slurp)" - | wl-copy

### Idle management
exec swayidle -w \
    timeout 600 'swaylock -f -c 333333' \
    timeout 630 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 333333'

### Media / Volume / Brightness keys
bindsym XF86AudioRaiseVolume exec pamixer --increase 5
bindsym XF86AudioLowerVolume exec pamixer --decrease 5
bindsym XF86AudioMute exec pamixer --toggle-mute
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-

### Autostart
exec nm-applet
exec mako

### Appearance
default_border pixel 2
default_floating_border pixel 2

### Status bar
bar {
    swaybar_command waybar
}

include /etc/sway/config.d/*
```

**Important**: If the user changed any bindings in Phase 2, substitute them into the config above. For example, if they chose `Mod+D` instead of `Ctrl+Space` for the app launcher, update that line accordingly. If they chose Alt as their mod key, change `set $mod Mod4` to `set $mod Mod1`.

---

## Phase 4: Post-Setup Guidance

After writing the config, tell the user:

1. **How to start Sway**: Log out of GNOME. At the login screen (GDM), click the gear icon at bottom-right and select "Sway". Log in.

2. **Essential things to know on first launch**:
   - Press `Ctrl+Space` (or their chosen launcher key) to open apps — this replaces GNOME's Activities
   - Press `Mod+Return` to open a terminal
   - Windows tile automatically. Use `Mod+F` for fullscreen, `Mod+Shift+Space` to float
   - `Mod+1` through `Mod+0` switches workspaces (like GNOME's workspace switcher)
   - `Mod+Shift+E` to log out (with confirmation)
   - `Mod+Shift+C` to reload config after edits

3. **If something feels wrong**:
   - You can always switch back to GNOME from the login screen
   - Edit config with: `foot -e nano ~/.config/sway/config` (open terminal + edit)
   - After editing, press `Mod+Shift+C` to reload without logging out

4. **Optional next steps** (they can ask you later):
   - Custom waybar config (add weather, Spotify, custom modules)
   - Clipboard manager (cliphist + wofi picker)
   - Night light (gammastep)
   - Custom color scheme / gaps between windows
   - Per-app window rules (floating dialogs, PiP windows)
   - Multiple monitor setup

---

## Rules for the Agent

- Do NOT install or configure anything beyond what's listed above
- Do NOT add gaps, rounded corners, or aesthetic tweaks — keep it functional
- Do NOT modify any GNOME settings or remove GNOME packages
- Do NOT set up a custom waybar config — the default is fine for starting out
- ALWAYS create a backup if `~/.config/sway/config` already exists: `cp ~/.config/sway/config ~/.config/sway/config.backup.$(date +%Y%m%d-%H%M%S)`
- The goal is a **reliable, minimal, working setup** that a GNOME user can immediately understand
