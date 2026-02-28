#!/bin/bash

# This script unmounts and closes the encrypted media drive.

# Name of the encrypted drive (as defined in /etc/crypttab)
encrypted_drive="media"

# Mount point for the decrypted drive
mount_point="/usr/media"

# Check if the drive is mounted
if mountpoint -q $mount_point; then
    echo "stopping all docker containers"
    sudo docker stop $(sudo docker ps -aq)

    echo "stopping samba"
    sudo service smbd stop

    # The drive is mounted, so let's unmount it
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
