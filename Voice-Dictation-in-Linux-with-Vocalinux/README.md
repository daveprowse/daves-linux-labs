# ⚙️ Voice Dictation in Linux with Vocalinux

Local, private, push-to-talk dictation using Vocalinux and whisper.cpp — no cloud, no subscription, no audio leaving your machine.

📺 Watch the video: [https://youtu.be/sJ1HS-XsbBY](https://youtu.be/sJ1HS-XsbBY) 

🌐 Website: [https://prowse.tech](https://prowse.tech/)

---

## Goals

- Install and configure Vocalinux for push-to-talk dictation on Linux.
- Use whisper.cpp with GPU acceleration for fast local transcription.
- Dictate into any application on a Wayland desktop.

> Note: In the video I am using a Debian Sid system with GNOME 50.4 and the Wayland display system. 

---

## Prerequisites

- A Linux system
- Microphone or headset connected and working
- GPU with Vulkan support (recommended; CPU fallback available)
- Git installed
- A Bash shell

---

## Stack

|Component|Tool|Purpose|
|---|---|---|
|Dictation (speech → text)|Vocalinux 0.17.0 or higher|whisper.cpp engine, push-to-talk, tray icon|
|Input simulation|ydotool|Wayland-compatible (and X11) keystroke injection|

---

## Step 1 — Install ydotool (optional)

> Note: On Wayland, the Vocalinux installer may install ydotool (or other appropriate tool) automatically for you and set permissions on `/dev/uinput` as well. I install it manually in this lab/video to show how it works. On X11, Vocalinux may install the `xdotool` for you automatically. 

```bash
sudo apt install ydotool
```

> Note: On Fedora: `sudo dnf install -y ydotool`
> 
> On Arch: `sudo pacman -S ydotool`

Add your user to the `input` group (required for `/dev/uinput` access without root):

```bash
sudo usermod -aG input $USER
```

Enable and start the ydotool user service:

```bash
systemctl --user enable ydotool
systemctl --user start ydotool
```

Apply the group change by logging out and back in, then restart the ydotool service:

```bash
systemctl --user restart ydotool
```

Verify the service is running:

```bash
systemctl status --user ydotool
```

Expected: `Active: active (running)`.

Then verify input injection works:

```bash
ydotool type "test"
```

Expected: the word "test" is typed into whatever window has focus.  
> **Sidebar — /dev/uinput permissions**
>
> If you get a permission error on `/dev/uinput`, log out and back in fully and retry.
>
> Verify permissions with:
> ```bash
> ls -la /dev/uinput
> ```
>
> Expected output:
> ```
> crw-rw---- 1 root input 10, 223 ... /dev/uinput
> ```
>
> `c` = character device. `660` permissions (`rw-rw----`) with `root:input` ownership means only root and members of the `input` group can access it — world access is denied. This is secure for our purposes.

---

> **Sidebar — Which text-injection tool does Vocalinux use?**
>
> Vocalinux types transcribed text into the focused window using a tool that matches your display server:
>
> | Session | Tool | Notes |
> | --- | --- | --- |
> | X11 | `xdotool` | Installed by the Vocalinux installer. The installer does no uinput or `input` group setup on X11. |
> | Wayland | `wtype`, `ydotool` | The installer installs `wtype` and tries to install `ydotool`. `ydotool` types through `/dev/uinput`, so it works on GNOME, where `wtype` may fail. |
>
> On Wayland the installer also adds your user to the `input` group and adds a udev rule for `/dev/uinput`. But you'll want to log out and back in afterward regardless. It may not enable the ydotool service. `ydotool` can also work on X11, since it types through the kernel’s uinput framework, though `xdotool` may be selected during the install process.
>
> So, there are a couple of options here depending on your display server. Step 1 of this lab isn't absolutely necessary, but it is a good learning process.

## Step 2 — Install Vocalinux

Install Python dependencies first:

```bash
sudo apt install python3 python3-pip python3-dev python3-venv libportaudio2
```

Install Vocalinux (whisper.cpp default, ~3-4 min — compiles from source for GPU/Vulkan):

```bash
curl -fsSL https://raw.githubusercontent.com/VocaHQ/vocalinux/main/install.sh -o /tmp/vocalinux-install.sh
cat /tmp/vocalinux-install.sh
bash /tmp/vocalinux-install.sh
```

The installer will ask three questions:

1. **Engine** — choose **whisper.cpp** (recommended)
2. **Backend** — choose **GPU** (Vulkan/CUDA; the GTX 970 supports Vulkan and will be faster than CPU)
3. **Download models now** — choose **1** (yes, download now)

The GPU option compiles whisper.cpp from source (~3-4 minutes). When complete, the installer confirms:

```
Engine:   Whisper.cpp
Backend:  GPU Accelerated
Location: ~/.local/share/vocalinux-install
Config:   ~/.config/vocalinux
```

Key commands after install:

```bash
vocalinux          # start the application
vocalinux-gui      # open settings GUI
vocalinux --debug  # start with debug logging
```

> 📋 The installer displays a full summary on completion. If you need to refer back to it, see [Appendix B — Vocalinux Installer Output (Reference)](#appendix-b--vocalinux-installer-output-reference).

---

## Step 3 — Configure Push-to-Talk

Launch Vocalinux from the GNOME application menu or:

```bash
vocalinux
```

A panel icon 🎤 appears. Push-to-talk with Right Alt is already configured by default — no changes needed to get started.

Default settings confirmed:

- **Activation mode:** Push-to-talk
- **Shortcut:** Right Alt (hold to speak, release to transcribe)
- **Engine:** whisper.cpp

Verify: hold Right Alt, speak a sentence, release. The text should appear in whatever app has focus within 1-2 seconds.

> **Sidebar — GNOME AppIndicator Extension**
>
> On GNOME, Vocalinux requires the AppIndicator extension for the panel icon to appear. If you see a message about AppIndicator support not being detected:
>
> Install the extension:
> ```bash
> sudo apt install gnome-shell-extension-appindicator
> ```
>
> Reboot, then verify it is present:
> ```bash
> gnome-extensions list | grep appindicator
> ```
>
> If listed but not enabled, enable it from the command line:
> ```bash
> gnome-extensions enable ubuntu-appindicators@ubuntu.com
> ```
>
> Or open the **Extensions** app, find **Ubuntu AppIndicators**, and toggle it on.
>
> Run `vocalinux` again. A small microphone icon will appear to the left of the panel icons.
> Push-to-talk keyboard shortcuts work without the icon, but the icon is required for Settings access.

---

## Step 4 — Upgrade Whisper Model (Optional)

Vocalinux **Settings → Speech Model** shows the following options (as of October 2026):

| Model | Size | Notes |
|---|---|---|
| Tiny | 74 MB | Fastest, least accurate, Likely installed by default |
| Base | 141 MB | 
| Small | 465 MB | 32 GB RAM systems should use this or higher |
| Medium | 1.5 GB | Higher accuracy, slower |
| Large v3 | 3.0 GB | Highest accuracy, most resource-intensive |

> **Note:** For systems with 32GB of RAM, **Small EN** is the recommended balance of accuracy and speed. In **Settings → Speech Model**, click **Use it** next to Small EN, then click the download button to download and activate it.

---

## Step 5 — Verify Full Dictation Flow

Vocalinux includes a built-in Dictation Pad accessible from the panel indicator (microphone icon). This is the easiest way to test:

1. Click the microphone icon in the panel
2. Select **Dictation Pad**
3. Click the checkbox for **"Dictate into this window..."**
4. Click in the white work area so that you see a cursor
5. Hold Right Alt
6. Speak: "The quick brown fox jumps over the lazy dog"
7. Release Right Alt

Expected: the sentence appears in the Dictation Pad within 1-2 seconds.

Dictation also works in any app with focus — text editors, terminals, browsers, etc.

### (Optional) Voice Commands

Enable Voice Commands at **Settings → Dictation → Voice Commands**. 

The User Guide lists these commands:
- new line / new paragraph
- period / full stop
- comma
- question mark
- exclamation point / exclamation mark
- semicolon
- colon
- delete that / scratch that
- capitalize / uppercase
- all caps

## 🏁 THAT"S THE END OF THE LAB! GREAT WORK!

---

## Verification Checklist

- [ ] `ydotool type "test"` types into focused window without errors
- [ ] Hold Right Alt → speak → release → text appears in focused app
- [ ] Whisper model upgraded to Small EN

---

## Links

- Vocalinux (https://vocalinux.com)
- Vocalinux GitHub (https://github.com/VocaHQ/vocalinux)
- whisper.cpp GitHub (https://github.com/ggml-org/whisper.cpp)
- ydotool (https://github.com/ReimuNotMoe/ydotool)


---

## Notes

- **Start on login:** On first launch a popup offers to enable this. It can also be toggled later via **Settings → Application → Start on Login**.
- **Unloading the model:** If Vocalinux is running in the background but not in active use, the model can be unloaded to free VRAM via **Settings → Performance**. Reload it when needed.
- **Remote access via RustDesk:** Vocalinux works over a RustDesk remote session without any additional configuration. Audio passes through the RustDesk connection normally.
- Vocalinux uses **Vulkan** for GPU acceleration, not CUDA — it will use your GPU automatically if Vulkan drivers are present. Install with: `sudo apt install vulkan-tools libvulkan1`
- The tray icon turns **red** while you are holding the push-to-talk key.
- Audio feedback (tones) plays on start/stop of recording — can be disabled in Settings.
- All processing is local. No audio or text leaves the machine.

---

## Appendix A — Reverting / Uninstalling

Follow these steps in reverse order to fully remove everything installed in this guide.

### Remove Vocalinux

```bash
cd ~/.local/share/vocalinux-install
bash uninstall.sh
```

Then remove remaining config and data directories:

```bash
rm -rf ~/.config/vocalinux
rm -rf ~/.local/share/vocalinux
rm -rf ~/.local/share/vocalinux-install
rm -f ~/.local/bin/activate-vocalinux.sh
```

### Remove Vocalinux custom scripts (if created in Step 6)

```bash
rm -f ~/.local/bin/open-terminal.sh
```

### Remove ydotool

Disable and stop the user service:

```bash
systemctl --user stop ydotool
systemctl --user disable ydotool
```

Remove the package:

```bash
sudo apt remove --purge ydotool
```

Remove the user from the `input` group:

```bash
sudo gpasswd -d $USER input
```

Log out and back in to apply the group change.

### Remove Python dependencies (optional)

> ⚠️ **WARNING** ⚠️ These packages are used by many other applications. Only remove them if you are certain nothing else on your system depends on them.

```bash
sudo apt remove python3-pip python3-dev python3-venv libportaudio2
sudo apt autoremove
```

### Remove Vulkan packages (optional)

> ⚠️ **WARNING** ⚠️ Vulkan is used by many applications beyond Vocalinux including games, graphics tools, and other GPU-accelerated software. Only remove these if you are certain nothing else on your system requires them.

```bash
sudo apt remove vulkan-tools libvulkan1
sudo apt autoremove
```

---

## Appendix B — Vocalinux Installer Output (Reference)

```
  ▗▖  ▗▖ ▗▄▖  ▗▄▄▖ ▗▄▖ ▗▖   ▗▄▄▄▖▗▖  ▗▖▗▖ ▗▖▗▖  ▗▖
  ▐▌  ▐▌▐▌ ▐▌▐▌   ▐▌ ▐▌▐▌     █  ▐▛▚▖▐▌▐▌ ▐▌ ▝▚▞▘
  ▐▌  ▐▌▐▌ ▐▌▐▌   ▐▛▀▜▌▐▌     █  ▐▌ ▝▜▌▐▌ ▐▌  ▐▌
   ▝▚▞▘ ▝▚▄▞▘▝▚▄▄▖▐▌ ▐▌▐▙▄▄▖▗▄█▄▖▐▌  ▐▌▝▚▄▞▘▗▞▘▝▚▖

                     ✓ Installation Complete!

[SUCCESS] Vocalinux has been installed successfully!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📦 What Was Installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Application:    Vocalinux (voice dictation for Linux)
  Engine:         Whisper.cpp
  Backend:        GPU Accelerated
  Location:       /home/dpro/.local/share/vocalinux-install
  Virtual Env:    /home/dpro/.local/share/vocalinux/venv
  Config:         /home/dpro/.config/vocalinux

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🚀 Getting Started
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Launch Vocalinux
   • From app menu: Look for 'Vocalinux'
   • From terminal: Run 'vocalinux' command

2. Find the icon in your system tray (top bar)
   • Click for settings and status
   • Right-click for menu options

3. Start dictating!
   Hold Right Alt while you speak, then release to transcribe
   (push-to-talk default; double-tap Right Alt in toggle mode)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎤 Testing Your Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Open any text editor (gedit, VS Code, LibreOffice, etc.)
2. Hold Right Alt, say: 'Hello world period', then release
3. You should see: 'Hello world.'

💡 Voice commands: 'period' 'comma' 'new line' 'delete that'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔧 Managing Vocalinux
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commands:
  vocalinux              Start the application
  vocalinux --debug      Start with debug logging
  vocalinux-gui          Open settings GUI

To activate the virtual environment:
  source /home/dpro/.local/bin/activate-vocalinux.sh

To uninstall:
  ./uninstall.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📚 Need Help?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Issues & Bugs:  https://github.com/VocaHQ/vocalinux/issues
• Documentation:  https://github.com/VocaHQ/vocalinux
• Star on GitHub: ⭐ https://github.com/VocaHQ/vocalinux

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✨ Happy Dictating! ✨
```

---

## Appendix C — Voice-Triggered App Launching (Optional)

> **Note:** This is a basic manual approach using scripted phrase hooks. A proper AI assistant (Ollama) handles this more naturally and is the recommended path. This appendix is provided for reference only.

Vocalinux supports custom command hooks — a spoken phrase triggers a shell script. To launch a terminal by voice:

Create the script:

```bash
cat > ~/.local/bin/open-terminal.sh << 'EOF'
#!/bin/bash
gnome-terminal
EOF
chmod +x ~/.local/bin/open-terminal.sh
```

In Vocalinux **Settings → Custom Commands**, add:
- **Trigger phrase:** "open terminal"
- **Command:** `~/.local/bin/open-terminal.sh`

The same pattern works for any application — replace `gnome-terminal` with the command for the app you want to launch.

## Appendix D — Remote API Engine (Optional)

Vocalinux can send audio to a server you configure instead of transcribing locally. It is off by default.

> ⚠️ Audio leaves this machine when the remote engine is enabled.

### Supported request formats

| Format | Endpoint | Servers |
| --- | --- | --- |
| whisper.cpp | `POST /inference` | whisper.cpp `whisper-server` (port 8080) |
| OpenAI-compatible | `POST /v1/audio/transcriptions` | OpenAI, Speaches, LocalAI, FunASR/SenseVoice |

### Configure

1. Open **Settings → Speech Engine** and turn on the **Advanced** toggle.
2. Under **Remote Server**, turn on **Use remote server**.
3. Enter **Server URL**, **API Key** (optional), **API Endpoint**, and **Model**.
4. Click **Test Connection**.

> **Note:** The API key is stored in plain text in `~/.config/vocalinux/config.json`. Beyond a trusted LAN, use HTTPS and an API key.

Source: [Vocalinux Remote HTTP API](https://github.com/VocaHQ/vocalinux/blob/main/docs/HTTP_REMOTE.md)