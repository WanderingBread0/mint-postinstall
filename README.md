# mint-postinstall

An interactive, profile-based post-install setup script for **Linux Mint 22.x Cinnamon**, with a clean [gum](https://github.com/charmbracelet/gum)-powered TUI.

```bash
git clone https://github.com/WanderingBread0/mint-postinstall.git
cd mint-postinstall
./install.sh --dry-run    # walk the full flow, install nothing
./install.sh              # do it for real
```

Run as your normal user. `sudo` will be requested once and kept warm. `gum` is auto-installed silently on first launch.

---

## Flow

1. **Welcome** — Mint version sanity check
2. **Profile select** — stackable: privacy / gaming / dev / content / general
3. **Per-category app select** — defaults pre-checked based on profiles
4. **Extras** — full catalog browse, add/remove freely (preserves prior selections)
5. **Summary** — final list, last chance to bail
6. **Install** — gum spinners, failures logged but don't abort the run
7. **Post-flight** — snap removal, firmware updates, git/ssh setup, ROG hardware tools
8. **Done** — install report + neofetch + reboot prompt

---

## Profiles

| Profile     | Defaults |
|-------------|----------|
| 🔒 privacy  | ProtonVPN, Signal, LibreWolf, Standard Notes, ClamTK, Firefox, Vivaldi |
| 🎮 gaming   | Steam, Lutris, Discord, Opera GX |
| 💻 dev      | VS Code, Tmux, Obsidian, Zsh + Oh My Zsh, Neofetch |
| 🎬 content  | KDenlive, OBS, GIMP, Inkscape |
| 🪟 general  | VLC, Flameshot, Firefox, Stacer, Neofetch |

Profiles are additive — selecting `privacy` + `dev` gives you the union of both default sets, deduplicated.

---

## Catalog

See [`apps/`](apps/) for full definitions. Categories: browsers, proton, messengers, notes, gaming, terminal, utilities, dev, media.

Each app file declares metadata (`NAME`, `DESC`, `PROFILES`, `DEFAULT_IN`, optional `SCORE` privacy bar) and an `install_<id>` function.

Install methods covered by the generic library:

- `install_apt`        — vanilla apt
- `install_flatpak`    — flathub
- `install_deb_url`    — download + apt-install a `.deb`
- `install_repo`       — add a GPG-signed apt repo, then install
- `install_script`     — anything else (custom function)
- `manual_install`     — opens browser, never auto-installs (DaVinci Resolve)

All respect `--dry-run` and never abort the run on a single failure.

---

## Customising

### Add a new app

Drop it into the matching `apps/<cat>/<cat>.sh`:

```bash
APP_myapp_NAME="My App"
APP_myapp_DESC="One-line description."
APP_myapp_PROFILES=("dev")
APP_myapp_DEFAULT_IN=()           # leave empty if you don't want it pre-checked
install_myapp() { install_flatpak "My App" "com.example.MyApp"; }
```

Then add `myapp` to the `<CAT>_IDS=(...)` array at the top of that file. That's it — categories.sh and extras.sh will pick it up automatically.

### Bump pinned versions

Proton Mail Bridge has a pinned version at the top of `apps/proton/proton.sh`. Bump it when new releases ship.

---

## Why no Mint 21.x support

The old single-file 21.x version was tossed in favour of the modular 22.x TUI. If you need the old script, check the git history before this rewrite.

---

## Known gotchas

- **Signal** keeps `xenial` in the repo line — that's Signal's choice, not a typo.
- **ProtonVPN** release URL is pinned; if it 404s, Proton bumped their release package — update `apps/proton/proton.sh`.
- **DaVinci Resolve** is intentionally manual. Blackmagic gates downloads behind a free account and ships a `.run` installer with quirky dependencies.
- **Steam** enables i386 multilib. If you don't game, leave it out.
- **ROG tools** are *companion repos*; this script only links to them.

---

## License

MIT.
