#!/bin/bash
# Open Setapp app pages for manual installation
# Note: This only opens the pages, installation still requires manual clicks

echo "Opening Setapp app pages for installation..."

# List of Setapp app URLs to open
apps=(
    "setapp://app/com.marcoarment.Batteries"
    "setapp://app/com.macpaw.CleanMyMac"
    "setapp://app/com.realmacsoftware.keepit"
    "setapp://app/com.jetbeach.MagicWindowAir"
    "setapp://app/com.brettterpstra.marked2"
    "setapp://app/com.creaceed.prizmo"
    "setapp://app/com.readdle.SparkMail"
)

for app in "${apps[@]}"; do
    echo "Opening: $app"
    open "$app"
    sleep 1  # Small delay between opening apps
done

echo "Please manually click 'Install' for each app in Setapp."