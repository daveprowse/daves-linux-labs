# ⚙️ How I Use `tmux` in Linux

`tmux` is a terminal multiplexer that lets you run multiple terminals in one SSH session, split your screen any way you want, and keep your sessions alive even after disconnection. This lab walks through everything in the video — from basic pane splits to plugins to VS Code integration. It's pure terminal multiplexing plethoricalness!

📺 **Watch the video:** https://youtu.be/7KEaC9c18fY

🌐 **Website:** https://prowse.tech

---

## Goals
- Enable multiple terminals when SSH'd into a server.
- Use a terminal multiplexer with no GUI required.
- Learn the power of the `tmux` program.
- Utilize `tmux` as the default terminal in VS Code.

---

## Prerequisites
- Linux system (Ubuntu Server used for server sections)
- (Optional) SSH access to a server (Parts 1–2)
- Git installed (Part 4)
- VS Code or VSCodium (Part 6)

---

## Part 1 — Install, First Look, and SSH Use Case

Install:
```
sudo apt install tmux        # Debian/Ubuntu (Debian Server: no sudo)
dnf install tmux             # CentOS/RHEL/Fedora
pacman -S tmux               # Arch
```

Check version:
```
tmux -V
```

Run:
```
tmux
```

Split panes:
```
Ctrl+b then %    # left-right split
Ctrl+b then "    # up-down split
```

Navigate panes:
```
Ctrl+b then arrow key
```

Fullscreen a pane (toggle):
```
Ctrl+b then z
```

Show pane numbers:
```
Ctrl+b then q
```

Exit a pane:
```
exit
```

Windows:
```
Ctrl+b then c          # new window
Ctrl+b then w          # list/switch windows
Ctrl+b then 0, 1, 2   # switch by number
Ctrl+b then ,          # rename window
```

If you ever get lost in a tmux mode, press `q` to return to standard operation.

---

## Part 2 — Sessions: The Real Power

Simulate a dropped connection (suspends the tmux client):
```
Ctrl+b then Ctrl+z
```

List sessions:
```
tmux ls
```

Reconnect by number:
```
tmux a -t 0
```

Create a named session:
```
tmux new -s mysession
```

Detach (keeps session running in background):
```
Ctrl+b then d
```

Reconnect by name:
```
tmux ls
tmux a -t mysession
```

---

## Part 3 — The Config File

The config file lives at `~/.tmux.conf` — does not exist by default.

Create it:
```
touch ~/.tmux.conf
```

Enable mouse support — append to config:
```
echo "set -g mouse on" >> ~/.tmux.conf
```
Or add the line directly inside `~/.tmux.conf`:
```
set -g mouse on
```

Reload the config:
```
tmux source-file ~/.tmux.conf
```

View all available config options:
```
tmux show -g
tmux show -g > ~/tmux-defaults.txt
```

**Optional** — remap the prefix (add to `~/.tmux.conf`):
```
set -g prefix C-a
unbind C-b
```

Then reload:
```
tmux source-file ~/.tmux.conf
```

> **Note:** To revert to the original prefix, add `set -g prefix C-b`, remove or comment out `unbind C-b`, and reload the config.

---

## Part 4 — Plugins: TPM, tmux-resurrect, tmux-sensible, Dracula

### Install the Tmux Plugin Manager (TPM)
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Add to `~/.tmux.conf` (top):
```
set -g @plugin 'tmux-plugins/tpm'
```

Add to `~/.tmux.conf` (bottom):
```
# TPM init
run '~/.tmux/plugins/tpm/tpm'
```

Reload:
```
tmux source ~/.tmux.conf
```

### tmux-resurrect

Add to `~/.tmux.conf`:
```
set -g @plugin 'tmux-plugins/tmux-resurrect'
```

Reload and install:
```
tmux source ~/.tmux.conf
Ctrl+b then Shift+I
```

Save and restore sessions:
```
Ctrl+b then Ctrl+s    # save
Ctrl+b then Ctrl+r    # restore after reboot
```

### tmux-sensible

Add to `~/.tmux.conf`:
```
set -g @plugin 'tmux-plugins/tmux-sensible'
```

Reload and install:
```
tmux source ~/.tmux.conf
Ctrl+b then Shift+I
```

> **Note:** tmux-sensible adds `Ctrl+b then Shift+R` as a quick shortcut for `tmux source ~/.tmux.conf` — use it from here on instead of typing the full command.

### Dracula Theme

Add to `~/.tmux.conf`:
```
set -g @plugin 'dracula/tmux'
```

Reload and install:
```
Ctrl+b then Shift+R    # reloads .tmux.conf
Ctrl+b then Shift+I    # fetches and installs plugins
```

Reference: https://draculatheme.com/tmux

---

## Part 5 — Workspace Template

Copy `tmux-workspace.sh` from this repository to your home directory:
```
cp tmux-workspace.sh ~/tmux-workspace.sh
```

Make executable and run:
```
chmod +x ~/tmux-workspace.sh
./tmux-workspace.sh
```

> **Note:** The script must live in your home directory (`~/`) for the VS Code integration in Part 6 to work correctly.

---

## Part 6 — VS Code / VSCodium Integration

Open User Settings JSON:
```
Ctrl+Shift+P → Open User Settings JSON
```

Add to `settings.json`:
```json
"terminal.integrated.defaultProfile.linux": "tmux-workspace",
"terminal.integrated.profiles.linux": {
    "tmux-workspace": {
        "path": "/bin/bash",
        "args": ["-c", "tmux has-session -t tmux-workspace 2>/dev/null && tmux attach -t tmux-workspace || ~/tmux-workspace.sh"]
    }
}
```

Reopen VS Code. New terminals (Ctrl + `) will auto-attach to the existing tmux-workspace session, or build it fresh from the script if none exists.

---

## Excellent work! Now you know tmux ❣️

---

## Links
- tmux GitHub: https://github.com/tmux/tmux
- Tmux Plugin Manager (TPM): https://github.com/tmux-plugins/tpm
- tmux-resurrect: https://github.com/tmux-plugins/tmux-resurrect
- tmux-sensible: https://github.com/tmux-plugins/tmux-sensible
- Dracula theme: https://draculatheme.com/tmux
- VSCodium: https://vscodium.com

---

## `tmux` Keyboard Shortcuts

All shortcuts use the default prefix `Ctrl+b` (release before the next key).

| Shortcut | Action |
|---|---|
| `Ctrl+b` then `%` | Split pane left-right |
| `Ctrl+b` then `"` | Split pane up-down |
| `Ctrl+b` then arrow key | Navigate panes |
| `Ctrl+b` then `z` | Toggle pane fullscreen |
| `Ctrl+b` then `c` | New window |
| `Ctrl+b` then `w` | List/switch windows |
| `Ctrl+b` then `0, 1, 2` | Switch to window by number |
| `Ctrl+b` then `,` | Rename window |
| `Ctrl+b` then `Ctrl+z` | Simulate dropped connection |
| `Ctrl+b` then `d` | Detach session |
| `Ctrl+b` then `q` | Show pane numbers |
| `Ctrl+b` then `Shift+I` | Install plugins (TPM) |
| `Ctrl+b` then `Shift+R` | Reload config (tmux-sensible) |
| `Ctrl+b` then `Ctrl+r` | Restore sessions (tmux-resurrect) |
| `Ctrl+b` then `Ctrl+s` | Save sessions (tmux-resurrect) |
| `Ctrl+b` then `[` | Enter copy mode |
| `Ctrl+b` then `]` | Paste inside tmux |

## Bonus: My .tmux.conf

```
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'dracula/tmux'
set -g @dracula-plugins "cpu-usage ram-usage time"
set -g @dracula-show-left-icon "🐧"

# More plugins
set -g @plugin 'tmux-plugins/tmux-yank'

# Use vi keys in copy mode
setw -g mode-keys vi

# Enable Mouse
set -g mouse on

# TPM init
run '~/.tmux/plugins/tpm/tpm'
```

---

## Copying Text in tmux

Keyboard-only copy process (vi mode):

1. **Enter copy mode:** Press `Ctrl+b`, let go, then press `[`
2. **Move:** Use arrow keys to position the cursor at the start of your text
3. **Select:** Press `Spacebar` to start highlighting, then use arrow keys to select the text
4. **Copy:** Press `y` (or `Enter`) to copy and exit — text is now available to paste anywhere in the system
5. **Paste:** Press `Ctrl+b`, let go, then press `]` to paste inside tmux

> **Note:** vi mode is enabled by `setw -g mode-keys vi` in the .tmux.conf shown above.