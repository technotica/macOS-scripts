# macOS-scripts
Scripts for macOS in enterprise environment and beyond

### Set MacOS Updates
Script configures macOS update parameters.   It also tells the system to ignore and prevent macOS updates to major OS release. The update installer will not get downloaded. If the user has already clicked the "Upgrade to MacOS BLAHBLAH" it will continue to nag.  This script removes the an installed bundle (/Library/Bundles/OSXNotification.bundle) that will remove future popups.  It also removes the Install macOS High Sierra.app and Install macOS Mojave.app from /Applications if it is found.

modified from https://grahamrpugh.com/2018/10/19/disable-macos-upgrade-notifications.html and https://www.jamf.com/jamf-nation/discussions/26103/high-sierra-upgrade-nags
