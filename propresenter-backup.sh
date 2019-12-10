#!/bin/bash

# Variables

# Directory Paths
librarypath=~/"Documents/ProPresenter6"
usersettings=~/"Library/Application Support/RenewedVision/ProPresenter6"
sharedsettings="/Users/Shared/Renewed Vision Application Support/ProPresenter6"
usermedia=~/"Renewed Vision Media"
sharedmedia="/Users/Shared/Renewed Vision Media"

# System Name
systemname=`hostname`

# Program Variables
libraryname=`echo $(basename "$librarypath")`
libraryfailcount=0
settingsfailcount=0
mediafailcount=0

function backup_start {
	echo "Backing Up $1"
}

function backup_success {
	echo "Successfully Backed Up $1"
}

function backup_fail {
	echo "Failed to Back Up $1"
}

function backup_does_not_exist {
	echo "$1 does not exist, skipping."
}

read -p "Press return to start backup"

# Library
currentpath="$librarypath"
if [ -d "$currentpath" ]; then
	backup_start "$currentpath"
	if rclone copy "$currentpath" "OneDrive:ProPresenter Backup/$systemname/Libraries/$libraryname"; then
		backup_success "$currentpath"
	else
		let "libraryfailcount++"
		backup_fail "$currentpath"
	fi
else
	let "libraryfailcount++"
	backup_does_not_exist "$currentpath"
fi

# Per User Settings
currentpath="$usersettings"
if [ -d "$currentpath" ]; then
	backup_start "$currentpath"
	if rclone copy --exclude="/cache/" "$currentpath" "OneDrive:ProPresenter Backup/$systemname/Settings/User"; then
		backup_success "$currentpath"
	else
		let "settingsfailcount++"
		backup_fail "$currentpath"
	fi
else
	let "settingsfailcount++"
	backup_does_not_exist "$currentpath"
fi

# All User Settings
currentpath="$sharedsettings"
if [ -d "$currentpath" ]; then
	backup_start "$currentpath"
	if rclone copy --exclude="/cache/" "$currentpath" "OneDrive:ProPresenter Backup/$systemname/Settings/Shared"; then
		backup_success "$currentpath"
	else
		let "settingsfailcount++"
		backup_fail "$currentpath"
	fi
else
	let "settingsfailcount++"
	backup_does_not_exist "$currentpath"
fi

# Per User Media
currentpath="$usermedia"
if [ -d "$currentpath" ]; then
	backup_start "$currentpath"
	if rclone copy "$currentpath" "OneDrive:ProPresenter Backup/$systemname/Media/User"; then
		backup_success "$currentpath"
	else
		let "mediafailcount++"
		backup_fail "$currentpath"
	fi
else
	let "mediafailcount++"
	backup_does_not_exist "$currentpath"
fi

# All User Media
currentpath="$sharedmedia"
if [ -d "$currentpath" ]; then
	backup_start "$currentpath"
	if rclone copy "$currentpath" "OneDrive:ProPresenter Backup/$systemname/Media/Shared"; then
		backup_success "$currentpath"
	else
		let "mediafailcount++"
		backup_fail "$currentpath"
	fi
else
	let "mediafailcount++"
	backup_does_not_exist "$currentpath"
fi

# Warn User If Library Could Not Be Backed Up
if [ $libraryfailcount -ge 1 ]; then
	echo "##################################################################"
	echo "##### WARNING!                                               #####"
	echo "##### No ProPresenter Library Folder Was Found During Backup #####"
	echo "##### ProPresenter library was not backed up!                #####"
	echo "##################################################################"
fi

# Warn User If Settings Could Not Be Backed Up
if [ $settingsfailcount -ge 2 ]; then
	echo "###################################################################"
	echo "##### WARNING!                                                #####"
	echo "##### No ProPresenter Settings Folder Was Found During Backup #####"
	echo "##### ProPresenter settings were not backed up!               #####"
	echo "###################################################################"
fi

# Warn User If Media Could Not Be Backed Up
if [ $mediafailcount -ge 2 ]; then
	echo "################################################################"
	echo "##### WARNING!                                             #####"
	echo "##### No ProPresenter Media Folder Was Found During Backup #####"
	echo "##### ProPresenter media was not backed up!                #####"
	echo "################################################################"
fi