#!/bin/bash

# 1. Set Correct Paths
wallpaper_folder="$HOME/Pictures/Wallpapers"
cache_dir="$HOME/.cache/qtile"
cache_file="$cache_dir/current_wallpaper"
blurred="$cache_dir/blurred_wallpaper.png"

# Create cache directory if not exists
mkdir -p "$cache_dir"
mkdir -p "$wallpaper_folder"

# Create cache file if not exists
if [ ! -f $cache_file ]; then
    touch $cache_file
    echo "$wallpaper_folder/default.jpg" > "$cache_file"
fi

current_wallpaper=$(cat "$cache_file")

case $1 in
    # Load wallpaper from cache
    "init")
        if [ -f $cache_file ]; then
            wal -q -i "$(cat $cache_file)"
        else
            wal -q -i "$wallpaper_folder"
        fi
    ;;

    # Select wallpaper with rofi
    "select")
        # I removed the reference to 'config-wallpaper.rasi' to prevent crashing
        selected=$( find "$wallpaper_folder" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; | sort -R | while read rfile
        do
            echo -en "$rfile\x00icon\x1f$wallpaper_folder/${rfile}\n"
        done | rofi -dmenu -i -p "Select Wallpaper" -show-icons)
        
        if [ ! "$selected" ]; then
            echo "No wallpaper selected"
            exit
        fi
        wal -q -i "$wallpaper_folder/$selected"
    ;;

    # Randomly select wallpaper 
    *)
        wal -q -i "$wallpaper_folder/"
    ;;
esac

# ----------------------------------------------------- 
# Reload qtile to apply colors
# ----------------------------------------------------- 
qtile cmd-obj -o cmd -f reload_config

# ----------------------------------------------------- 
# Get new theme
# ----------------------------------------------------- 
source "$HOME/.cache/wal/colors.sh"
newwall=$(echo $wallpaper | sed "s|$wallpaper_folder/||g")

# ----------------------------------------------------- 
# Create blurred wallpaper (Requires ImageMagick)
# ----------------------------------------------------- 
if command -v magick &> /dev/null; then
    magick "$wallpaper" -resize 50% "$blurred"
    magick "$blurred" -blur 50x30 "$blurred"
    echo ":: Blurred wallpaper created"
else
    echo ":: ImageMagick not found, skipping blur."
fi

# Write selected wallpaper to cache
echo "$wallpaper" > "$cache_file"

# Send notification
notify-send "Wallpaper updated" "Image: $newwall"