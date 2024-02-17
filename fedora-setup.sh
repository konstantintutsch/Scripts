#!/usr/bin/bash

SYSTEM_REPOSITORIES=("kallepm/tuxedo-keyboard" "kallepm/tuxedo-control-center")
SYSTEM_PACKAGES=("adw-gtk3-theme" "fuse-sshfs" "gnome-console" "gnome-tweaks" "neovim" "jekyll" "source-foundry-hack-fonts" "tlp" "toot" "tuxedo-control-center" "tuxedo-keyboard" "ufraw" "zoxide")
USER_PACKAGES=("com.belmoussaoui.Obfuscate" "com.cburch.Logisim" "com.github.Eloston.UngoogledChromium" "com.github.huluti.Curtail" "com.github.tchx84.Flatseal" "com.spotify.Client" "com.valvesoftware.Steam" "de.schmidhuberj.tubefeeder" "dev.alextren.Spot" "dev.geopjr.Tuba" "fr.romainvigier.MetadataCleaner" "hu.kramo.Cartridges" "io.github.celluloid_player.Celluloid" "io.gitlab.librewolf-community" "io.gitlab.news_flash.NewsFlash" "me.kozec.syncthingtk" "net.ankiweb.Anki" "org.darktable.Darktable" "org.gimp.GIMP" "org.gnome.Maps" "org.gnome.World.PikaBackup" "org.gnome.World.Secrets" "org.gtk.Gtk3theme.adw-gtk3" "org.inkscape.Inkscape" "org.localsend.localsend_app" "org.mozilla.Thunderbird" "org.nickvision.money" "org.pitivi.Pitivi")

# Add system repositories
for REPOSITORY in "${SYSTEM_REPOSITORIES[@]}"
do
    sudo dnf copr enable "${REPOSITORY}"
done

# Install system packages
sudo dnf install "${SYSTEM_PACKAGES[@]}"

# Install user packages
flatpak install --user "${USER_PACKAGES[@]}"
