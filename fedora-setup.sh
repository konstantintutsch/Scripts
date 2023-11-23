#!/usr/bin/bash

SYSTEM_REPOSITORIES=("kallepm/tuxedo-keyboard" "kallepm/tuxedo-control-center")
SYSTEM_PACKAGES=("adw-gtk3-theme" "fuse-sshfs" "gnome-console" "gnome-tweaks" "neovim" "jekyll" "source-foundry-hack-fonts" "syncthing" "tlp" "toot" "tuxedo-control-center" "tuxedo-keyboard")
USER_PACKAGES=("app.drey.EarTag" "com.github.Eloston.UngoogledChromium" "com.github.huluti.Curtail" "com.github.neithern.g4music" "com.github.neithern.g4music" "com.ranfdev.Notify" "com.ranfdev.Notify" "com.ranfdev.Notify" "io.freetubeapp.FreeTube" "io.gitlab.librewolf-community" "io.gitlab.news_flash.NewsFlash" "org.darktable.Darktable" "org.gimp.GIMP" "org.gnome.World.PikaBackup" "org.gnome.World.PikaBackup" "org.gtk.Gtk3theme.adw-gtk3" "org.mozilla.Thunderbird" "org.nickvision.money" "org.prismlauncher.PrismLauncher" "re.sonny.Tangram")

# Add system repositories
for REPOSITORY in "${SYSTEM_REPOSITORIES[@]}"
do
    sudo dnf copr enable "${REPOSITORY}"
done

# Install system packages
sudo dnf install "${SYSTEM_PACKAGES[@]}"

# Install user packages
flatpak install --user "${USER_PACKAGES[@]}"
