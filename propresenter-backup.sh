#!/bin/bash

# Directory Paths
if [ -n "$librarypath" ]; then
	true
else
	librarypath=~/"Documents/ProPresenter6"
fi
if [ -n "$usersettings" ]; then
	true
else
	usersettings=~/"Library/Application Support/RenewedVision/ProPresenter6"
fi
if [ -n "$sharedsettings" ]; then
	true
else
	sharedsettings="/Users/Shared/Renewed Vision Application Support/ProPresenter6"
fi
if [ -n "$usermedia" ]; then
	true
else
	usermedia=~/"Renewed Vision Media"
fi
if [ -n "$sharedmedia" ]; then
	true
else
	sharedmedia="/Users/Shared/Renewed Vision Media"
fi
# Where rclone will save ProPresenter backups to.
# Make sure that you set this.
if [ -n "$rcdest" ]; then
	true
else
	rcdest=""
fi
# Leave blank to pull rclone binary from default $PATH.
if [ -n "$rcpath" ]; then
	true
else
	rcpath=""
fi

# System Name
systemname=$(hostname)

# Program Variables
libraryname=$(basename "$librarypath")
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

if [ "$rcdest" == "" ]; then
	echo "Please ensure that \$rcdest is set either in environment variables or manually in the script."
	exit
fi

# Library
if [ -d "$librarypath" ]; then
	backup_start "$librarypath"
	if "$rcpath"rclone copy --exclude=".DS_Store" "$librarypath" "$rcdest/$systemname/Libraries/$libraryname"; then
		backup_success "$librarypath"
	else
		(( libraryfailcount++ )) || true
		backup_fail "$librarypath"
	fi
else
	(( libraryfailcount++ )) || true
	backup_does_not_exist "$librarypath"
fi

# Per User Settings
if [ -d "$usersettings" ]; then
	backup_start "$usersettings"
	if "$rcpath"rclone copy --exclude=".DS_Store" --exclude="/cache/" "$usersettings" "$rcdest/$systemname/Settings/User"; then
		backup_success "$usersettings"
	else
		(( settingsfailcount++ )) || true
		backup_fail "$usersettings"
	fi
else
	(( settingsfailcount++ )) || true
	backup_does_not_exist "$usersettings"
fi

# All User Settings
if [ -d "$sharedsettings" ]; then
	backup_start "$sharedsettings"
	if "$rcpath"rclone copy --exclude=".DS_Store" --exclude="/cache/" "$sharedsettings" "$rcdest/$systemname/Settings/Shared"; then
		backup_success "$sharedsettings"
	else
		(( settingsfailcount++ )) || true
		backup_fail "$sharedsettings"
	fi
else
	(( settingsfailcount++ )) || true
	backup_does_not_exist "$sharedsettings"
fi

# Per User Media
if [ -d "$usermedia" ]; then
	backup_start "$usermedia"
	if "$rcpath"rclone copy --exclude=".DS_Store" "$usermedia" "$rcdest/$systemname/Media/User"; then
		backup_success "$usermedia"
	else
		(( mediafailcount++ )) || true
		backup_fail "$usermedia"
	fi
else
	(( mediafailcount++ )) || true
	backup_does_not_exist "$usermedia"
fi

# All User Media
if [ -d "$sharedmedia" ]; then
	backup_start "$sharedmedia"
	if "$rcpath"rclone copy --exclude=".DS_Store" "$sharedmedia" "$rcdest/$systemname/Media/Shared"; then
		backup_success "$sharedmedia"
	else
		(( mediafailcount++ )) || true
		backup_fail "$sharedmedia"
	fi
else
	(( mediafailcount++ )) || true
	backup_does_not_exist "$sharedmedia"
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
