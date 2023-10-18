#!/bin/bash

# This script is used to mount the encrypted backup drive.

# Name of the encrypted drive (as defined in /etc/crypttab)
encrypted_drive="backup"

# Mount point for the decrypted drive
mount_point="/mnt/backup"

# Check if the drive is already open
if ! cryptsetup isLuks /dev/mapper/$encrypted_drive; then
    # The drive is not open, so let's open it
    sudo cryptsetup luksOpen /dev/mapper/$encrypted_drive $encrypted_drive
fi

# Check if the drive is already mounted
if ! mountpoint -q $mount_point; then
    # The drive is not mounted, so let's mount it
    sudo mount /dev/mapper/$encrypted_drive $mount_point
    echo "Drive mounted at $mount_point"
else
    echo "Drive is already mounted at $mount_point"
fi
