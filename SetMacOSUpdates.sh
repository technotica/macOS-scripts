#!/bin/bash

# System Preferences >> App Store

# Get OS Version
macOSver=$(sw_vers -productVersion | awk -F. '{print $2}')
echo "macOS Version: $(SW_vers -productVersion)"

# macOS version is at least 10.8
if [[ ${macOSver} -ge 8 ]]; then

# Checks the "Automatically check for updates" check box
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool true

# GUI System Preferences >> App Store >> enable Download newly available updates in the background
# This is the 2nd of the 5 settings in the GUI within 10.11, 10.12
# Unchecks the "Download newly available updates in the background" check box
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool FALSE

# This is the 5th of the 5 settings in the GUI within 10.11, 10.12
# Enable XProtect and Gatekeeper updates to be installed automatically
# Enable automatic security updates to be installed automatically
# Checks the "Install system data files and security update boxes"
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool TRUE
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool TRUE

if [[ ${macOSver} -ge 10 ]]; then
# System Preferences >> App Store >> enable Install app updates
# This is the 3rd of the 5 settings in the GUI within 10.11, 10.12
# Checks the "Install app updates" checkbox
/usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE

# System Preferences >> App Store >> 4 of 5 enable Install OS X updates
# This is the 4th of the 5 settings in the GUI within 10.11, 10.12
# Checks the "Install macOS updates"
/usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE
fi

# One time actions:
# Ignores macOS update notification to major version
softwareupdate --ignore macOSInstallerNotification_GM

# Disables the Upgrade to macOS Mojave or High Sierra nag notification prompts if update was run
if [[ -d /Library/Bundles/OSXNotification.bundle ]]; then
    echo "OSXNotification.bundle found. Deleting..."
    rm -rf /Library/Bundles/OSXNotification.bundle ||:
else
    echo "OSXNotification.bundle not found."
fi

# Remove downloaded installer from Applications
if [[ -d "/Applications/Install macOS High Sierra.app" ]]; then
    echo "High Sierra installer found. Deleting..."
    rm -rf "/Applications/Install macOS High Sierra.app" ||:
else if [[ -d "/Applications/Install macOS Mojave.app" ]]; then
    echo "Mojave installer found. Deleting..."
    rm -rf "/Applications/Install macOS Mojave.app" ||:
else
    echo "macOS installer not found."
fi
# This is a one time action to trigger a background check with normal scan (critical and config-data updates only)
/usr/sbin/softwareupdate --background-critical
fi
exit 0
else 
	echo "Nothing changed.  macOS is not 10.8 or higher"
	exit 1
fi
