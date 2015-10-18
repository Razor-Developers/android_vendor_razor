#!/bin/bash

# Shane Faulkner
# http://shanefaulkner.com
# You are free to modify and distribute this code,
# so long as you keep my name and URL in it.
# Lots of thanks go out to TeamBAMF

#-------------------ROMS To Be Built------------------#

PRODUCT[0]="$1"			# phone model name (product folder name)
LUNCHCMD[0]="razor_$1-userdebug"	# lunch command used for ROM
BUILDNME[0]="razor_$1"		# name of the output ROM in the out folder, before "-ota-"
OUTPUTNME[0]="TEAM-RAZOR-$1"		# what you want the new name to be

#---------------------Build Settings------------------#

# CCACHE Settings
export USE_CCACHE=1
ccache -M 50

# should they be moved out of the output folder
# like a dropbox or other cloud storage folder
# or any other folder you want
# also required for FTP upload
MOVE=y

# folder they should be moved to
STORAGE=~/android/zips

# your build source code directory path
SAUCE=`pwd`

# number for the -j parameter
J=`nproc`

# generate an MD5
MD5=y

# sync repositories
SYNC=y

# run make clean first
CLEAN=y

# leave alone
DATE=`eval date +%m`-`eval date +%d`

#----------------------FTP Settings--------------------#

# set "FTP=y" if you want to enable FTP uploading
# must have moving to storage folder enabled first
FTP=y

# FTP server settings
FTPHOST[0]="download.razor-rom.com"	# ftp hostname
FTPUSER[0]="zadmin_razord"	# ftp username 
FTPPASS[0]="razordev"	# ftp password
FTPDIR[0]="$1"	# ftp upload directory

#---------------------Build Bot Code-------------------#

echo -n "Moving to source directory..."
cd $SAUCE
echo "done!"

if [ $SYNC = "y" ]; then
	echo -n "Running repo sync..."
	repo sync
	echo "done!"
fi

if [ $CLEAN = "y" ]; then
	echo -n "Running make clean..."
	make clean
	echo "done!"
fi

for VAL in "${!PRODUCT[@]}"
do
	echo -n "Starting build..."
	source build/envsetup.sh && lunch ${LUNCHCMD[$VAL]} && time make -j$J razor
	echo "done!"

	if [ $MD5 = "y" ]; then
		echo -n "Moving md5sum to cloud storage directory..."
		cp $SAUCE/out/target/product/${PRODUCT[$VAL]}/${OUTPUTNME[$VAL]}-*.zip.md5sum $STORAGE
		echo "done!"
	fi

	if  [ $MOVE = "y" ]; then
		echo -n "Moving OTA to cloud storage directory..."
		cp $SAUCE/out/target/product/${PRODUCT[$VAL]}/${OUTPUTNME[$VAL]}-*.zip $STORAGE/
		echo "done!"
	fi

done

#----------------------FTP Upload Code--------------------#

if  [ $FTP = "y" ]; then
	echo "Initiating FTP connection..."

	cd $STORAGE
	ATTACHROM=`for file in *.zip; do echo -n -e "put ${file}\n"; done`
	if [ $MD5 = "y" ]; then
		ATTACHMD5=`for file in *.zip.md5sum; do echo -n -e "put ${file}\n"; done`
		ATTACH=$ATTACHROM
	fi

for VAL in "${!FTPHOST[@]}"
do
	echo -e "\nConnecting to ${FTPHOST[$VAL]} with user ${FTPUSER[$VAL]}..."
	ftp -in <<EOF
	open ${FTPHOST[$VAL]}
	user ${FTPUSER[$VAL]} ${FTPPASS[$VAL]}
	cd ${FTPDIR[$VAL]}
	$ATTACH
	quit

	ftp -in <<EOF
	open ${FTPHOST[$VAL]}
	user ${FTPUSER[$VAL]} ${FTPPASS[$VAL]}
	cd ${FTPDIR[$VAL]}
	$ATTACHMD5
	quit
EOF
done

	echo -e  "FTP transfer complete! \n"
fi

rm -rf $STORAGE/*
echo "All done!"
