#!/bin/bash

# This script is used to mount the encrypted backup drive.

# Name of the encrypted drive (as defined in /etc/crypttab)
encrypted_drive="backup"

# Device as listed in lsblk
encrypted_device="sdb1"

# Mount point for the decrypted drive
mount_point="/mnt/backup"

sudo cryptsetup luksOpen /dev/$encrypted_device $encrypted_drive

# Check if the drive is already mounted
if ! mountpoint -q $mount_point; then
    # The drive is not mounted, so let's mount it
    echo "Mounting drive at $mount_point"
    sudo mount /dev/mapper/$encrypted_drive $mount_point
    echo "Drive mounted at $mount_point"
else
    echo "Drive is already mounted at $mount_point"
fi
