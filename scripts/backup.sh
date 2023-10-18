#!/bin/bash

# This script is used to backup a data folder on the server to an external hard drive folder. 
# Using rsync it creates an exact replica, non existing new files in the target directory are copied, non existing ones in the source are deleted.

# Source directory
source_dir="/usr/media"

# Target directory
target_dir="/mnt/backup/media"

# Ensure the source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Source directory does not exist: $source_dir"
    exit 1
fi

# Create the target directory if it doesn't exist
if [ ! -d "$target_dir" ]; then
    echo "Target directory $target_dir not found, make sure to mount the backup drive."
    exit 1
fi

# Perform the backup using rsync with sudo
sudo rsync -av --delete --update "$source_dir/" "$target_dir/"

# Check the rsync exit status
if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
else
    echo "Backup failed with error code $?."
fi
