# apps/media/media.sh — media & creative tools

MEDIA_IDS=(kdenlive obs handbrake gimp inkscape davinci)

APP_kdenlive_NAME="KDenlive"
APP_kdenlive_DESC="Non-linear video editor."
APP_kdenlive_PROFILES=("content")
APP_kdenlive_DEFAULT_IN=("content")
install_kdenlive() {
    ensure_flathub
    install_flatpak "KDenlive" "org.kde.kdenlive"
}

APP_obs_NAME="OBS Studio"
APP_obs_DESC="Streaming + screen recording."
APP_obs_PROFILES=("content")
APP_obs_DEFAULT_IN=("content")
install_obs() {
    ensure_flathub
    install_flatpak "OBS Studio" "com.obsproject.Studio"
}

APP_handbrake_NAME="HandBrake"
APP_handbrake_DESC="Video transcoder."
APP_handbrake_PROFILES=("content")
APP_handbrake_DEFAULT_IN=()
install_handbrake() {
    ensure_flathub
    install_flatpak "HandBrake" "fr.handbrake.ghb"
}

APP_gimp_NAME="GIMP"
APP_gimp_DESC="Raster image editor."
APP_gimp_PROFILES=("content")
APP_gimp_DEFAULT_IN=("content")
install_gimp() {
    ensure_flathub
    install_flatpak "GIMP" "org.gimp.GIMP"
}

APP_inkscape_NAME="Inkscape"
APP_inkscape_DESC="Vector graphics editor."
APP_inkscape_PROFILES=("content")
APP_inkscape_DEFAULT_IN=()
install_inkscape() { install_apt "Inkscape" inkscape; }

APP_davinci_NAME="DaVinci Resolve"
APP_davinci_DESC="Pro NLE. Requires manual install + free registration."
APP_davinci_PROFILES=("content")
APP_davinci_DEFAULT_IN=()
install_davinci() {
    manual_install "DaVinci Resolve" \
        "https://www.blackmagicdesign.com/products/davinciresolve" \
        "DaVinci Resolve has no apt/flatpak distribution. Blackmagic requires
a free account, then you download a .run installer. After download:
  chmod +x DaVinci_Resolve_*.run
  sudo ./DaVinci_Resolve_*.run
On Mint you also typically need libssl1.1 from an older Ubuntu repo and
to disable Wayland — see the Blackmagic forum for current notes."
}
