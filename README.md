# mint-postinstall

A single-shot setup script for **Linux Mint 21.x (Cinnamon)** — installs the apps,
codecs, themes, drivers, and snapshot/auto-update config I want on a fresh box.

## Usage

```bash
git clone https://github.com/WanderingBread0/mint-postinstall.git
cd mint-postinstall
bash install.sh --dry-run    # see everything that would happen
bash install.sh              # do it
```

Run as your normal user — the script asks for sudo once and keeps it warm.

## What it installs

| Step | Packages |
|------|----------|
| System update | `apt full-upgrade`, `autoremove` |
| Drivers | `ubuntu-drivers autoinstall` (Nvidia / wifi / etc.) |
| Codecs | `mint-meta-codecs`, `ffmpeg`, `libavcodec-extra` |
| Flatpak | `flatpak` + Flathub remote |
| Signal | official `updates.signal.org` repo |
| Vivaldi | official `repo.vivaldi.com` |
| VS Code | official `packages.microsoft.com` |
| Proton | ProtonVPN GUI + Mail Bridge |
| Steam | `steam-installer` (with i386 arch) |
| Apps | VLC, Kdenlive, SimpleScreenRecorder, Flameshot, Kleopatra, ClamTK, Solaar, Stacer |
| Themes | Yaru cursor, Mint-L-Dark GTK + Cinnamon, Mint-Y-Yaru icons |
| Auto-updates | `mintupdate-automation` enabled |
| Timeshift | daily + weekly snapshots (keep 2 of each) |

## Customising

Pinned versions live at the top of `install.sh` — bump them when new releases ship:

```bash
PROTON_BRIDGE_VERSION="3.13.0-1"   # https://proton.me/mail/bridge
STACER_VERSION="1.1.0"             # https://github.com/oguzhaninan/Stacer/releases
```

To skip a step, comment its `do_step` line in the `main` block at the bottom.

## After reboot

A few things still need a one-time GUI sign-in:

- **Proton Mail Bridge** — launch and sign in
- **ProtonVPN** — launch and sign in
- **Signal** — scan the QR on your phone to link
- **ClamTK** — run first virus-DB update
- **Timeshift** — pick a backup destination, take the first snapshot
- **mintdrivers** — verify recommended drivers applied

## Compatibility

Tested on Linux Mint 21.x Cinnamon. Should work on other Mint editions
(Xfce / MATE) but the `gsettings` theme calls in `step_themes` are
Cinnamon-specific — comment that step out on non-Cinnamon installs.

## Licence

MIT.
