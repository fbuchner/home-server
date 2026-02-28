# Run your own home server

This repository contains all kinds of snippets that allow you to setup and run your own home server.

## Assumptions

In case you are basing your setup around other central premises make sure to adapt code and configurations accordingly.

- Ubuntu server is chosen as an operating system
- In addition to the internal storage there is a second LUKS-encrypted disk (`/dev/sda`) used for all media data, mounted at `/usr/media`, and a backup drive at `/dev/sdb1`
- Applications are run as docker containers using Portainer

## Setup Guide

For a walkthrough of setting up a fresh Ubuntu server, see [homeserver-setup.md](homeserver-setup.md).

## Services

This repository includes Docker Compose configurations for:

| Service | Description | Port |
|---------|-------------|------|
| Audiobookshelf | Audiobook and podcast server | 13378 |
| Backrest | Backup solution using restic | 9898 |
| Big-AGI | AI chat interface | 3000 |
| Booklore | Ebook library manager | 6060 |
| Filebrowser | Web-based file manager | 8773 |
| Home Assistant | Home automation platform | 8123 |
| Homer | Dashboard for services | 8091 |
| Immich | Photo and video management | 2283 |
| Jellyfin | Media server | 8096 |
| Meerkat CRM | Contact and relationship manager | 3007 |
| Navidrome | Music streaming server | 4533 |
| Watchtower | Automatic container updates | - |

## Repository Structure

```
├── docker/           # Docker Compose files for each service
├── scripts/          # Shell scripts for backup and maintenance
│   ├── backup_mount.sh       # Mount encrypted backup drive
│   ├── backup_unmount.sh     # Unmount encrypted backup drive
│   ├── backup.sh             # Rsync backup to external drive
│   ├── media_mount.sh        # Mount encrypted media drive
│   ├── media_unmount.sh      # Unmount encrypted media drive
│   └── navidrome-create-playlists.sh
└── homeserver-setup.md       # Step-by-step server setup guide
```

## Usage

### Deploy a service

Using Portainer, create a new stack and paste the contents of the desired compose file from the `docker/` folder.

Alternatively, deploy directly via command line:

```bash
docker compose -f docker/application.yml up -d
```

### Backup

1. Mount the encrypted backup drive:
   ```bash
   ./scripts/backup_mount.sh
   ```

2. Run the backup:
   ```bash
   ./scripts/backup.sh
   ```

3. Unmount the drive when done:
   ```bash
   ./scripts/backup_unmount.sh
   ```

