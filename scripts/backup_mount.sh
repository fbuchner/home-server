#!/bin/bash

# This script is used to mount the encrypted backup drive.

set -e

# Name of the encrypted drive (as defined in /etc/crypttab)
encrypted_drive="backup"

# Device as listed in lsblk
encrypted_device="sdb1"

# Mount point for the decrypted drive
mount_point="/mnt/backup"

# Open the encrypted drive
if ! sudo cryptsetup luksOpen "/dev/$encrypted_device" "$encrypted_drive"; then
    echo "Failed to open encrypted drive"
    exit 1
fi

# Check if the drive is already mounted
if ! mountpoint -q "$mount_point"; then
    # The drive is not mounted, so let's mount it
    echo "Mounting drive at $mount_point"
    sudo mount "/dev/mapper/$encrypted_drive" "$mount_point"
    echo "Drive mounted at $mount_point"
else
    echo "Drive is already mounted at $mount_point"
fi
