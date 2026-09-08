# Know Your Linux System! — 20 Linux Analysis Commands (of Perpetual Power)

When I sit down to a Linux system I've never touched before, the first thing I do is run a series of commands to figure out what I'm dealing with.

Here are 20+ of them.

📺 **Watch the video:** [INSERT YOUTUBE LINK HERE]

🌐 **Website:** https://prowse.tech

---

## The Commands

### System Info

```bash
cat /etc/os-release
```

```bash
hostnamectl
```

```bash
uname -a
```

```bash
uptime
```

```bash
lscpu
```

```bash
lshw -short
```

```bash
lspci -tv
```

### Networking

```bash
ip -br -c a && ip -c r
```

```bash
ss -tulnw
```

```bash
ping -c 3 1.1.1.1
```

### Storage

```bash
lsblk
```

```bash
df -h
```

```bash
du -sh /* 2>/dev/null
```

```bash
free -h
```

### Packages

```bash
sudo apt-get check
```

```bash
sudo dpkg --audit
```

### Services & Logs

```bash
systemctl status
```

```bash
systemctl --failed
```

```bash
top
```

```bash
journalctl -p 3 -xb
```

### Users *(Optional)*

```bash
whoami
```

```bash
w
```

```bash
last -a
```

```bash
sudo -l
```

---

## The Bash Scripts

Run all of the above (minus `top`) automatically — saves a markdown summary report.

### Debian
```bash
chmod +x sys_audit_debian.sh
./sys_audit_debian.sh
```

### CentOS / RHEL / Fedora
```bash
chmod +x sys_audit_centos.sh
./sys_audit_centos.sh
```
> **Note:** Minimal CentOS installs may not include `lshw`. Install it with: `sudo dnf install lshw -y`

### Arch Linux
```bash
chmod +x sys_audit_arch.sh
./sys_audit_arch.sh
```
> **Note:** Fresh Arch installs may not include `lshw` or `lspci`. Install with: `sudo pacman -S lshw pciutils --noconfirm`

---

## Distro Modifications

### CentOS / RHEL / Fedora

| Category | Debian Command | CentOS Command | Reason |
|----------|---------------|----------------|--------|
| Package check | `apt-get check` | `dnf check` | RPM-based package manager |
| Package audit | `dpkg --audit` | `rpm -Va --nofiles` | RPM integrity check |
| Listening ports | `ss -tulnw` | `ss -tulpn` | `-p` adds process name on CentOS |

### Arch Linux

| Category | Debian Command | Arch Command | Reason |
|----------|---------------|--------------|--------|
| Package check | `apt-get check` | `pacman -Qk` | Checks integrity of installed packages |
| Package audit | `dpkg --audit` | `pacman -D --check` | Scans for broken dependencies |

---

## The Bonus (from the video)

```bash
((1-1)); echo $?
```

Mathematically? Zero. In Bash? **One.**

...You're welcome.

---

## About Dave's Linux Labs

Created by **Dave Prowse** — author, trainer, and maintainer of [Draw on Gnome](https://github.com/daveprowse/Draw-On-Gnome).

- 🌐 Website: https://prowse.tech
- 🎥 YouTube: https://youtube.com/@prowsetech
- 💬 Discord: https://discord.com/invite/mggw8VGzUp