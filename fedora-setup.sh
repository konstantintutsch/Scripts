#!/usr/bin/bash

SYSTEM_REPOSITORIES=("kallepm/tuxedo-keyboard" "kallepm/tuxedo-control-center")

# RPMs
# Generate: for package in $(dnf repoquery --userinstalled --queryformat "%{name}"); do printf "\"%s\" " "${package}"; done; printf "\n"
#     + manual sort
SYSTEM_PACKAGES=("adw-gtk3-theme" "arm-image-installer" "fuse-sshfs" "gnome-tweaks" "gstreamer1-plugin-openh264" "gstreamer1-plugins-bad-free-extras" "gstreamer1-plugins-bad-free-fluidsynth" "gstreamer1-plugins-bad-free-opencv" "gstreamer1-plugins-bad-free-wildmidi" "gstreamer1-plugins-bad-free-zbar" "gstreamer1-plugins-good-extras" "gstreamer1-plugins-good-qt6" "htop" "mozilla-fira-mono-fonts" "neofetch" "neovim" "nodejs" "nodesource-release" "openssh-askpass" "perl-Image-ExifTool" "python3-pip" "source-foundry-hack-fonts" "sqlitebrowser" "tlp" "toot" "tuxedo-control-center" "tuxedo-keyboard" "ufraw" "yt-dlp" "zoxide")

# Flatpaks
# Generate: for package in $(flatpak list --user --app --columns=application); do printf "\"%s\" " "${package}"; done; printf "\n"
USER_PACKAGES=("com.belmoussaoui.Obfuscate" "com.cburch.Logisim" "com.discordapp.Discord" "com.github.huluti.Curtail" "com.github.tchx84.Flatseal" "com.google.Chrome" "com.mardojai.ForgeSparks" "com.spotify.Client" "com.valvesoftware.Steam" "de.schmidhuberj.Flare" "de.zwarf.picplanner" "dev.geopjr.Tuba" "fr.romainvigier.MetadataCleaner" "io.github.Foldex.AdwSteamGtk" "io.github.celluloid_player.Celluloid" "io.github.david_swift.Flashcards" "io.github.fizzyizzy05.binary" "io.gitlab.librewolf-community" "io.gitlab.liferooter.TextPieces" "io.gitlab.news_flash.NewsFlash" "me.kozec.syncthingtk" "net.ankiweb.Anki" "org.darktable.Darktable" "org.gimp.GIMP" "org.gnome.Builder" "org.gnome.Maps" "org.gnome.Weather" "org.gnome.World.PikaBackup" "org.gnome.World.Secrets" "org.gnome.gitlab.cheywood.Buffer" "org.gnome.gitlab.somas.Apostrophe" "org.inkscape.Inkscape" "org.kde.kdenlive" "org.localsend.localsend_app" "org.mozilla.Thunderbird" "org.nickvision.money" "org.tenacityaudio.Tenacity" "page.kramo.Cartridges" "so.libdb.dissent")

# Add system repositories
for REPOSITORY in "${SYSTEM_REPOSITORIES[@]}"
do
    sudo dnf copr enable "${REPOSITORY}"
done

# Install system packages
sudo dnf install "${SYSTEM_PACKAGES[@]}"

# Install user packages
flatpak install --user "${USER_PACKAGES[@]}"
