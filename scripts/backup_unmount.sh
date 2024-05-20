#!/bin/bash

# This script unmounts and encrypts the encrypted backup drive.

# Name of the encrypted drive (as defined in /etc/crypttab)
encrypted_drive="backup"

# Mount point for the decrypted drive
mount_point="/mnt/backup"

# Check if the drive is mounted
if mountpoint -q $mount_point; then
    # The drive is mounted, so let's unmount it

    # in case you use this script for your main volume you might want to stop all docker containers
    # sudo docker stop $(sudo docker ps -aq)

    # in case you use this script for a network storage you might want to stop samba
    # sudo service smbd stop
    
    if sudo umount $mount_point; then
        echo "Drive unmounted from $mount_point"
    else
        echo "Failed to unmount $mount_point"
        echo "Processes using the mounted directory:"
        sudo lsof +D $mount_point
        exit 1
    fi
else
    echo "Drive is not mounted at $mount_point"
fi

sudo cryptsetup luksClose $encrypted_drive
echo "Drive encryption closed."
