#!/usr/bin/bash

SYSTEM_REPOSITORIES=("kallepm/tuxedo-keyboard" "kallepm/tuxedo-control-center")
SYSTEM_PACKAGES=("adw-gtk3-theme" "fuse-sshfs" "gnome-console" "gnome-tweaks" "neovim" "jekyll" "source-foundry-hack-fonts" "syncthing" "tlp" "toot" "tuxedo-control-center" "tuxedo-keyboard")
USER_PACKAGES=("com.belmoussaoui.Decoder" "com.belmoussaoui.Obfuscate" "com.github.ADBeveridge.Raider" "com.github.Eloston.UngoogledChromium" "com.github.huluti.Curtail" "com.github.tchx84.Flatseal" "com.spotify.Client" "de.haeckerfelix.Fragments" "de.schmidhuberj.tubefeeder" "dev.geopjr.Collision" "dev.geopjr.Tuba" "fr.romainvigier.MetadataCleaner" "io.github.celluloid_player.Celluloid" "io.github.mrvladus.List" "io.gitlab.librewolf-community" "io.gitlab.news_flash.NewsFlash" "net.ankiweb.Anki" "org.darktable.Darktable" "org.gaphor.Gaphor" "org.gimp.GIMP" "org.gnome.Geary" "org.gnome.Maps" "org.gnome.Snapshot" "org.gnome.World.PikaBackup" "org.gnome.World.Secrets" "org.gtk.Gtk3theme.adw-gtk3" "org.inkscape.Inkscape" "org.localsend.localsend_app" "org.nickvision.money" "org.pitivi.Pitivi")

# Add system repositories
for REPOSITORY in "${SYSTEM_REPOSITORIES[@]}"
do
    sudo dnf copr enable "${REPOSITORY}"
done

# Install system packages
sudo dnf install "${SYSTEM_PACKAGES[@]}"

# Install user packages
flatpak install --user "${USER_PACKAGES[@]}"
