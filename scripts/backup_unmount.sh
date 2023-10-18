#!/bin/bash

# This script unmounts and encrypts the encrypted backup drive.

# Name of the encrypted drive (as defined in /etc/crypttab)
encrypted_drive="backup"

# Mount point for the decrypted drive
mount_point="/mnt/backup"

# Check if the drive is mounted
if mountpoint -q $mount_point; then
    # The drive is mounted, so let's unmount it
    sudo umount $mount_point
    echo "Drive unmounted from $mount_point"
else
    echo "Drive is not mounted at $mount_point"
fi

# Check if the drive is open
if cryptsetup isLuks /dev/mapper/$encrypted_drive; then
    # The drive is open, so let's close it
    sudo cryptsetup luksClose $encrypted_drive
    echo "Drive closed"
else
    echo "Drive is not open"
fi
