#!/bin/sh
#set -x

## Original code: https://github.com/pbowden-msft/Remove2011
## Modified by Jennifer Johnson - 10/27/17

## Set up logging
# All stdout and sterr will go to the log file.

LOG_FILE="/var/log/remove_office_2011.log"
touch "$LOG_FILE"
exec 3>&1 1>>${LOG_FILE} 2>&1

## Formatting support
TEXT_RED='\033[0;31m'
TEXT_YELLOW='\033[0;33m'
TEXT_GREEN='\033[0;32m'
TEXT_BLUE='\033[0;34m'
TEXT_NORMAL='\033[0m'

## Initialize global variables
#FORCE_PERM=true
#PRESERVE_DATA=true
APP_RUNNING=false
#SAVE_LICENSE=true

## Path constants
PATH_OFFICE2011="/Applications/Microsoft Office 2011"
PATH_WORD2011="/Applications/Microsoft Office 2011/Microsoft Word.app"
PATH_EXCEL2011="/Applications/Microsoft Office 2011/Microsoft Excel.app"
PATH_PPT2011="/Applications/Microsoft Office 2011/Microsoft PowerPoint.app"
PATH_OUTLOOK2011="/Applications/Microsoft Office 2011/Microsoft Outlook.app"
PATH_LYNC2011="/Applications/Microsoft Lync.app"
PATH_MAU="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"

## Functions for Logging
function LogMessage {
	echo $(date) "$*"
}

function ConsoleMessage {
	echo "$*" >&3
}

function FormattedConsoleMessage {
	FUNCDENT="$1"
	FUNCTEXT="$2"
	printf "$FUNCDENT" "$FUNCTEXT" >&3
}

function AllMessage {
	echo $(date) "$*"
	echo "$*" >&3
}

function LogDevice {
	LogMessage "In function 'LogDevice'"
	system_profiler SPSoftwareDataType -detailLevel mini
	system_profiler SPHardwareDataType -detailLevel mini
}

## Functions for checking if Office 2011 is currently running
function CheckRunning {
	FUNCPROC="$1"
	LogMessage "In function 'CheckRunning' with argument $FUNCPROC"
	local RUNNING_RESULT=$(ps ax | grep -v grep | grep "$FUNCPROC")
	if [ "${#RUNNING_RESULT}" -gt 0 ]; then
		LogMessage "$FUNCPROC is currently running"
		APP_RUNNING=true
		ForceQuit2011
	fi
}

## Kill Office 2011 apps
function ForceTerminate {
	FUNCPROC="$1"
	LogMessage "In function 'ForceTerminate' with argument $FUNCPROC"
	$(ps ax | grep -v grep | grep "$FUNCPROC" | cut -d' ' -f1 | xargs kill -9 2> /dev/null)
}

function ForceQuit2011 {
	LogMessage "In function 'ForceQuit2011'"
	FormattedConsoleMessage "%-55s" "Shutting down all Office 2011 applications"
	ForceTerminate "$PATH_WORD2011" "Word 2011"
	ForceTerminate "$PATH_EXCEL2011" "Excel 2011"
	ForceTerminate "$PATH_PPT2011" "PowerPoint 2011"
	ForceTerminate "$PATH_OUTLOOK2011" "Outlook 2011"
	ForceTerminate "$PATH_LYNC2011" "Lync 2011"
	ConsoleMessage "${TEXT_GREEN}Success${TEXT_NORMAL}"
}

# Remove Office 2011 Component
function RemoveComponent {
	FUNCPATH="$1"
	FUNCTEXT="$2"
	LogMessage "In function 'RemoveComponent with arguments $FUNCPATH and $FUNCTEXT'"
	FormattedConsoleMessage "%-55s" "Removing $FUNCTEXT"
	if [ -d "$FUNCPATH" ] || [ -e "$FUNCPATH" ] ; then
		LogMessage "Removing path $FUNCPATH"
		$(sudo rm -r -f "$FUNCPATH")
	else
		LogMessage "$FUNCPATH was not detected"
		ConsoleMessage "${TEXT_YELLOW}Not detected${TEXT_NORMAL}"
		return
	fi
	if [ -d "$FUNCPATH" ] || [ -e "$FUNCPATH" ] ; then
		LogMessage "Path $FUNCPATH still exists after deletion"
		ConsoleMessage "${TEXT_RED}Failed${TEXT_NORMAL}"
	else
		LogMessage "Path $FUNCPATH was successfully removed"
		ConsoleMessage "${TEXT_GREEN}Success${TEXT_NORMAL}"
	fi
}

## Remove 2011 Receipts
function Remove2011Receipts {
	LogMessage "In function 'Remove2011Receipts'"
	FormattedConsoleMessage "%-55s" "Removing Package Receipts"
	RECEIPTCOUNT=0
	RemoveReceipt "com.microsoft.office.all.*"
	RemoveReceipt "com.microsoft.office.en.*"
	RemoveReceipt "com.microsoft.merp.*"
	RemoveReceipt "com.microsoft.mau.*"
	if (( $RECEIPTCOUNT > 0 )) ; then
		ConsoleMessage "${TEXT_GREEN}Success${TEXT_NORMAL}"
	else
		ConsoleMessage "${TEXT_YELLOW}Not detected${TEXT_NORMAL}"
	fi
}

function RemoveReceipt {
	FUNCPATH="$1"
	LogMessage "In function 'RemoveReceipt' with argument $FUNCPATH"
	PKGARRAY=($(pkgutil --pkgs=$FUNCPATH))
	for p in "${PKGARRAY[@]}"
	do
		LogMessage "Forgetting package $p"
		sudo pkgutil --forget $p
		if [ $? -eq 0 ] ; then
			((RECEIPTCOUNT++))
		fi
	done
}

## Remove Office 2011 Preferences
function Remove2011Preferences {
	LogMessage "In function 'Remove2011Preferences'"
	FormattedConsoleMessage "%-55s" "Removing Preferences"
	PREFCOUNT=0
	RemovePref "/Library/Preferences/com.microsoft.Word.plist"
	RemovePref "/Library/Preferences/com.microsoft.Excel.plist"
	RemovePref "/Library/Preferences/com.microsoft.Powerpoint.plist"
	RemovePref "/Library/Preferences/com.microsoft.Outlook.plist"
	RemovePref "/Library/Preferences/com.microsoft.outlook.databasedaemon.plist"
	RemovePref "/Library/Preferences/com.microsoft.DocumentConnection.plist"
	RemovePref "/Library/Preferences/com.microsoft.office.setupassistant.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.Word.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.Excel.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.Powerpoint.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.Lync.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.Outlook.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.outlook.databasedaemon.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.outlook.office_reminders.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.DocumentConnection.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.office.setupassistant.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.office.plist"
	RemovePref "/Users/*/Library/Preferences/com.microsoft.error_reporting.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.Word.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.Excel.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.Powerpoint.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.Outlook.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.outlook.databasedaemon.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.DocumentConnection.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.office.setupassistant.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.registrationDB.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.e0Q*.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/com.microsoft.Office365.*.plist"
	RemovePref "/Users/*/Library/Preferences/ByHost/MicrosoftLyncRegistrationDB.*.plist"
	if (( $PREFCOUNT > 0 )); then
		ConsoleMessage "${TEXT_GREEN}Success${TEXT_NORMAL}"
	else
		ConsoleMessage "${TEXT_YELLOW}Not detected${TEXT_NORMAL}"
	fi
}

function RemovePref {
	FUNCPATH="$1"
	LogMessage "In function 'RemovePref' with argument $FUNCPATH"
	ls $FUNCPATH
	if [ $? -eq 0 ] ; then
		LogMessage "Found preference $FUNCPATH"
		$(sudo rm -f $FUNCPATH)
		if [ $? -eq 0 ] ; then
			LogMessage "Preference $FUNCPATH removed"
			((PREFCOUNT++))
		else
			LogMessage "Preference $FUNCPATH could NOT be removed"
		fi
	fi
}

## clean Dock
function CleanDock {
	LogMessage "In function 'CleanDock'"
	FormattedConsoleMessage "%-55s" "Cleaning icons in dock"
	if [ -e "$WORKING_FOLDER/dockutil" ]; then
		LogMessage "Found DockUtil tool"
		sudo "$WORKING_FOLDER"/dockutil --remove "file:///Applications/Microsoft%20Office%202011/Microsoft%20Document%20Connection.app/" --no-restart
		sudo "$WORKING_FOLDER"/dockutil --remove "file:///Applications/Microsoft%20Office%202011/Microsoft%20Word.app/" --no-restart
		sudo "$WORKING_FOLDER"/dockutil --remove "file:///Applications/Microsoft%20Office%202011/Microsoft%20Excel.app/" --no-restart
		sudo "$WORKING_FOLDER"/dockutil --remove "file:///Applications/Microsoft%20Office%202011/Microsoft%20PowerPoint.app/" --no-restart
		sudo "$WORKING_FOLDER"/dockutil --remove "file:///Applications/Microsoft%20Office%202011/Microsoft%20Lync.app/" --no-restart
		sudo "$WORKING_FOLDER"/dockutil --remove "file:///Applications/Microsoft%20Office%202011/Microsoft%20Outlook.app/"
		LogMessage "Completed dock clean-up"
		ConsoleMessage "${TEXT_GREEN}Success${TEXT_NORMAL}"
	else
		ConsoleMessage "${TEXT_YELLOW}Not detected${TEXT_NORMAL}"
	fi
}

## Relaunch Prefs and make sure they are really dead
function RelaunchCFPrefs {
	LogMessage "In function 'RelaunchCFPrefs'"
	FormattedConsoleMessage "%-55s" "Restarting Preferences Daemon"
	sudo ps ax | grep -v grep | grep "cfprefsd" | cut -d' ' -f1 | xargs sudo kill -9
	if [ $? -eq 0 ] ; then
		LogMessage "Successfully terminated all preferences daemons"
		ConsoleMessage "${TEXT_GREEN}Success${TEXT_NORMAL}"
	else
		LogMessage "FAILED to terminate all preferences daemons"
		ConsoleMessage "${TEXT_RED}Failed${TEXT_NORMAL}"
	fi
}

function MainLoop {
	LogMessage "In function 'MainLoop'"
	# Check to see if any of the 2011 apps are currently open
	CheckRunning2011
	if [ $APP_RUNNING = true ]; then
		LogMessage "One of more 2011 apps are running"
		Close2011
	fi
	# Remove Office 2011 apps
	RemoveComponent "$PATH_OFFICE2011" "Office 2011 Applications"
	RemoveComponent "$PATH_LYNC2011" "Lync"
	
	# Remove Office 2011 helpers
	RemoveComponent "/Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist" "Launch Daemon: Licensing Helper"
	RemoveComponent "/Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper" "Helper Tools: Licensing Helper"

	# Remove Office 2011 fonts - We are keeping old fonts - jdjohnso
	#RemoveComponent "/Library/Fonts/Microsoft" "Office Fonts"

	# Remove Office 2011 application support
	RemoveComponent "/Library/Application Support/Microsoft/MERP2.0" "Error Reporting"
	RemoveComponent "/Users/*/Library/Application Support/Microsoft/Office" "Application Support"

	# Remove Office 2011 caches
	RemoveComponent "/Users/*/Library/Caches/com.microsoft.browserfont.cache" "Browser Font Cache"
	RemoveComponent "/Users/*/Library/Caches/com.microsoft.office.setupassistant" "Setup Assistant Cache"
	RemoveComponent "/Users/*/Library/Caches/Microsoft/Office" "Office Cache"
	RemoveComponent "/Users/*/Library/Caches/Outlook" "Outlook Identity Cache"
	RemoveComponent "/Users/*/Library/Caches/com.microsoft.Outlook" "Outlook Cache"

	# Remove Office 2011 preferences
	Remove2011Preferences

	# Remove or rename Outlook 2011 identities and databases - We are keeping old identities - jdjohnso
	#if [ $PRESERVE_DATA = false ]; then
	#	RemoveComponent "/Users/*/Documents/Microsoft User Data/Office 2011 Identities" "Outlook Identities and Databases"
	#	RemoveComponent "/Users/*/Documents/Microsoft User Data/Saved Attachments" "Outlook Saved Attachments"
	#	RemoveComponent "/Users/*/Documents/Microsoft User Data/Outlook Sound Sets" "Outlook Sound Sets"
	#else
	#	PreserveComponent "/Users/*/Documents/Microsoft User Data/Office 2011 Identities" "Outlook Identities and Databases"
	#	PreserveComponent "/Users/*/Documents/Microsoft User Data/Saved Attachments" "Outlook Saved Attachments"
	#	PreserveComponent "/Users/*/Documents/Microsoft User Data/Outlook Sound Sets" "Outlook Sound Sets"
	#fi

	# Remove Office 2011 package receipts
	Remove2011Receipts

	# Clean up icons on the dock
	#CleanDock

	# Restart cfprefs
	RelaunchCFPrefs
}

## Main
LogMessage "Starting $SCRIPT_NAME"
LogDevice
MainLoop

ConsoleMessage ""
ConsoleMessage "All events and errors were logged to $LOG_FILE"
ConsoleMessage ""
LogMessage "Exiting script"
exit 0