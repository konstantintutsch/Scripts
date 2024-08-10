#!/usr/bin/bash

SYSTEM_REPOSITORIES=("kallepm/tuxedo-drivers" "kallepm/tuxedo-control-center")
SYSTEM_REPOSITORIES_EXTERNAL=("dnf install --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release")

# RPMs
# Generate: for package in $(dnf repoquery --userinstalled --queryformat "%{name}"); do printf "\"%s\" " "${package}"; done; printf "\n"
#     + manual sort
SYSTEM_PACKAGES=("aajohan-comfortaa-fonts" "adw-gtk3-theme" "arm-image-installer" "cargo" "fuse-sshfs" "git-filter-repo" "git-lfs" "gnome-console" "gnome-tweaks" "gstreamer1-plugin-openh264" "gstreamer1-plugins-bad-free-extras" "gstreamer1-plugins-bad-free-fluidsynth" "gstreamer1-plugins-bad-free-opencv" "gstreamer1-plugins-bad-free-wildmidi" "gstreamer1-plugins-bad-free-zbar" "gstreamer1-plugins-good-extras" "gstreamer1-plugins-good-qt6" "htop" "mozilla-fira-mono-fonts" "ncdu" "nodejs" "perl-Image-ExifTool" "rust" "rustfmt" "solaar" "source-foundry-hack-fonts" "tlp" "toot" "totem" "tuxedo-control-center" "tuxedo-drivers" "ufraw" "yt-dlp" "zed" "zoxide")

# Flatpaks
# Generate: for package in $(flatpak list --user --app --columns=application); do printf "\"%s\" " "${package}"; done; printf "\n"
USER_PACKAGES=("com.belmoussaoui.Obfuscate" "com.discordapp.Discord" "com.github.Matoking.protontricks" "com.github.tchx84.Flatseal" "com.jeffser.Alpaca" "com.spotify.Client" "com.valvesoftware.Steam" "de.schmidhuberj.Flare" "dev.bragefuglseth.Keypunch" "dev.geopjr.Tuba" "fr.romainvigier.MetadataCleaner" "io.github.Foldex.AdwSteamGtk" "io.github.david_swift.Flashcards" "io.github.ungoogled_software.ungoogled_chromium" "io.gitlab.librewolf-community" "io.gitlab.news_flash.NewsFlash" "me.kozec.syncthingtk" "net.codelogistics.webapps" "org.darktable.Darktable" "org.gimp.GIMP" "org.gnome.Gtranslator" "org.gnome.Maps" "org.gnome.Showtime" "org.gnome.Weather" "org.gnome.World.PikaBackup" "org.gnome.World.Secrets" "org.gnome.gitlab.somas.Apostrophe" "org.inkscape.Inkscape" "org.localsend.localsend_app" "org.mozilla.Thunderbird" "org.nickvision.money")

# Add system repositories
for REPOSITORY in "${SYSTEM_REPOSITORIES[@]}"
do
    sudo dnf copr enable "${REPOSITORY}"
done
for REPOSITORY in "${SYSTEM_REPOSITORIES_EXTERNAL[@]}"
do
    eval "sudo ${REPOSITORY}"
done

# Install system packages
sudo dnf install "${SYSTEM_PACKAGES[@]}"

# Install user packages
flatpak install --user "${USER_PACKAGES[@]}"
