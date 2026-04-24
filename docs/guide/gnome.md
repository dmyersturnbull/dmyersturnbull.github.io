# GNOME

## Extensions

In GNOME’s settings, set the time format to 24-hour and make sure _Automatic Data and Time_ is selected.
Also install the `gnome-tweaks` utility and Gnome extensions:

=== "Ubuntu"

    ```bash
    sudo apt-get install -y gnome-tweaks gnome-browser-connector
    ```

=== "Fedora"

    ```bash
    sudo dnf install -y gnome-tweaks gnome-browser-connector
    ```

Then open https://extensions.gnome.org/ and install the browser extension.
I recommend installing these extensions:

- **Force Quit.**
- **Panel Date Format.**
  To get YYYY-MM-DD HH:MM formatting, run

  ```bash
  dconf write \
    /org/gnome/shell/extensions/panel-date-format/format \
    "'%Y-%m-%d %H:%M'"
  ```

## Nautilus favorites

To remove the favorites for Videos, Music, etc. that Nautilus forces on you, run this script.

??? info "Script to remove built-in bookmarks"

    ```bash
    cat >> ~/.config/user-dirs.dirs << EOF
    # This file was created manually.

    # Keep these:
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Downloads"

    # Exclude these:
    #XDG_DOCUMENTS_DIR="$HOME/Documents"
    #XDG_TEMPLATES_DIR="$HOME/Templates"
    #XDG_PUBLICSHARE_DIR="$HOME/Public"
    #XDG_MUSIC_DIR="$HOME/Music"
    #XDG_PICTURES_DIR="$HOME/Pictures"
    #XDG_VIDEOS_DIR="$HOME/Videos"
    EOF

    cat >> ~/.config/user-dirs.conf << EOF
    # Create a user-dirs.conf file to prevent automatic updates
    # We created ~/.config/user-dirs.dirs manually
    # Prevent xdg-user-dirs-update from overwriting it
    enabled=False
    EOF
    ```

If that didn’t work, try replacing the commented-out lines with real links; e.g.
`XDG_VIDEOS_DIR="$HOME/.junk/"`.

For convenience, use
[`add-bookmarks.sh`](files/add-bookmarks.sh)
to add bookmarks.
Example: `~/bin/add-bookmarks.sh data=/data/ docs=/docs/`

After running it, restart Nautilus to apply the settings by running
`nautilus -q`.
