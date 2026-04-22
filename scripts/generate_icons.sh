#!/bin/bash
set -euo pipefail

# Ensure assets directory exists
mkdir -p assets

# Check if logo exists, if not download Flutter logo
if [ ! -f "assets/logo.png" ]; then
    echo "No custom logo found. Downloading Flutter logo..."
    curl -L "https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png" -o "assets/logo.png"

    # Verify download was successful
    if [ ! -f "assets/logo.png" ]; then
        echo "Failed to download Flutter logo. Please check your internet connection."
        exit 1
    fi
fi

pick_font() {
    local files=(
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf"x
        "/System/Library/Fonts/Supplemental/Arial.ttf"
        "/System/Library/Fonts/Supplemental/Helvetica.ttc"
        "/Library/Fonts/Arial Bold.ttf"
        "/Library/Fonts/Arial.ttf"
    )

    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            echo "$f"
            return 0
        fi
    done

    echo ""
}

generate_icons_for_flavor() {
    local flavor=$1
    local color=$2
    local banner_text=$3

    echo "Generating icons for $flavor flavor..."

    # Create necessary Android directories
    mkdir -p "android/app/src/$flavor/res/mipmap-mdpi"
    mkdir -p "android/app/src/$flavor/res/mipmap-hdpi"
    mkdir -p "android/app/src/$flavor/res/mipmap-xhdpi"
    mkdir -p "android/app/src/$flavor/res/mipmap-xxhdpi"
    mkdir -p "android/app/src/$flavor/res/mipmap-xxxhdpi"

    # Create necessary iOS directories
    mkdir -p "ios/Runner/Assets.xcassets/AppIcon-$flavor.appiconset"

    # Get logo dimensions
    logo_dims=$(magick identify -format "%wx%h" "assets/logo.png")
    logo_width=$(echo "$logo_dims" | cut -d'x' -f1)
    logo_height=$(echo "$logo_dims" | cut -d'x' -f2)

    # Calculate banner dimensions (20% of logo height)
    banner_height=$((logo_height / 5))

    local font_name
    font_name="$(pick_font)"

    # Create banner with solid color background
    if [ -n "$font_name" ]; then
        magick -size "${logo_width}x${banner_height}" xc:"$color" \
            -fill white \
            -gravity center \
            -pointsize $((banner_height / 2)) \
            -font "$font_name" \
            -annotate 0 "$banner_text" \
            "banner_$flavor.png"
    else
        echo "Warning: No preferred font found; using ImageMagick default font."
        magick -size "${logo_width}x${banner_height}" xc:"$color" \
            -fill white \
            -gravity center \
            -pointsize $((banner_height / 2)) \
            -annotate 0 "$banner_text" \
            "banner_$flavor.png"
    fi

    if [ ! -f "banner_$flavor.png" ]; then
        echo "Failed to generate banner_$flavor.png"
        exit 1
    fi

    # Combine logo with banner
    magick "assets/logo.png" \
        "banner_$flavor.png" \
        -gravity south \
        -composite \
        -resize 1024x1024 \
        "temp_icon_$flavor.png"

    if [ ! -f "temp_icon_$flavor.png" ]; then
        echo "Failed to generate temp_icon_$flavor.png"
        exit 1
    fi

    # Android icon sizes
    android_sizes=(
        "mdpi:48:48"
        "hdpi:72:72"
        "xhdpi:96:96"
        "xxhdpi:144:144"
        "xxxhdpi:192:192"
    )

    # Generate Android icons
    for entry in "${android_sizes[@]}"; do
        IFS=: read -r density width height <<< "$entry"
        magick "temp_icon_$flavor.png" \
            -resize "${width}x${height}" \
            "android/app/src/$flavor/res/mipmap-$density/ic_launcher.png"
    done

    # iOS icon sizes
    ios_sizes=(
        "20:20"
        "29:29"
        "40:40"
        "60:60"
        "76:76"
        "83.5:83.5"
        "1024:1024"
    )

    # Generate iOS icons
    for size in "${ios_sizes[@]}"; do
        IFS=: read -r width height <<< "$size"
        magick "temp_icon_$flavor.png" \
            -resize "${width}x${height}" \
            "ios/Runner/Assets.xcassets/AppIcon-$flavor.appiconset/Icon-${width}.png"
    done

    # Clean up temporary files (quietly)
    rm -f "banner_$flavor.png" "temp_icon_$flavor.png"
}

# Generate icons for each flavor with different colors and banner texts
generate_icons_for_flavor "development" "#FF5722" "DEV"
generate_icons_for_flavor "staging" "#FF9800" "STAGING"
generate_icons_for_flavor "production" "#4CAF50" "PROD"

echo "Icons generated successfully!"