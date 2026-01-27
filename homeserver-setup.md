# Useful steps to configure a fresh install ubuntu home server

> Note that most commands require sudo privilege

## Table of Contents

- [Initial configuration](#initial-configuration)
  - [Setup Portainer environment](#setup-portainer-environment)
  - [Setup new disk](#setup-new-disk)
  - [Setup encrypted backup disk](#setup-encrypted-backup-disk)
  - [Setup fileshare](#setup-fileshare)
  - [Increase swap space](#increase-swap-space)
  - [Misc](#misc)
- [Server hardening](#server-hardening)
  - [Update system and activate automatic security updates](#update-system-and-activate-automatic-security-updates)
  - [Configure SSH](#configure-ssh)
- [Data quality](#data-quality)

## Initial configuration

### Setup Portainer environment

```bash
sudo apt install docker-ce
sudo systemctl status docker
```

Create and start the Portainer container:

```bash
docker create \
  --name portainer \
  --restart=always \
  --net=bridge \
  -e PGID=1001 \
  -e PUID=1001 \
  -v /docker/portainer/config:/config \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 9443:9443 \
  portainer/portainer-ce

docker start portainer
```

### Setup new disk

Make sure to only add the automatic mounting with fstab if the volume will not be encrypted. A failure in mounting because of an encrypted volume leads to the system refusing to boot up properly.

```bash
lsblk -f
sudo mkfs -t ext4 /dev/sda
sudo mkdir -p /usr/media
sudo mount -t auto /dev/sda /usr/media
sudo cp /etc/fstab /etc/fstab.backup
echo "/dev/sda /usr/media ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a
```

### Setup encrypted backup disk

You can find scripts for automatic mounting and unmounting of the encrypted backup disk in the scripts folder.

```bash
lsblk -f
sudo umount /dev/sdb
sudo cryptsetup luksFormat /dev/sdb
sudo cryptsetup luksOpen /dev/sdb backup
sudo mkfs.ext4 /dev/mapper/backup
sudo mkdir -p /mnt/backup
sudo mount /dev/mapper/backup /mnt/backup

# When done, unmount and close
sudo umount /mnt/backup
sudo cryptsetup luksClose backup
```

### Setup fileshare

Install and configure Samba:

```bash
sudo apt install samba
sudo nano /etc/samba/smb.conf
sudo service smbd restart
sudo ufw allow samba
sudo adduser sambauser
sudo smbpasswd -a sambauser
sudo chmod -R 1777 /usr/media/
```

Add the following to `/etc/samba/smb.conf`:

```ini
socket options = TCP_NODELAY

[sambashare]
   comment = Media Share
   path = /usr/media/
   read only = no
   browsable = yes
   guest ok = no
   valid users = sambauser
```

### Increase swap space

```bash
swapon --show
sudo swapoff -a
sudo dd if=/dev/zero of=/swap.img bs=1G count=18 status=progress
sudo chmod 600 /swap.img
sudo mkswap /swap.img
sudo swapon /swap.img
free -h
echo '/swap.img none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Misc

Remove ubuntu pro advertisement:

```bash
sudo dpkg-divert --divert /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak --rename --local /etc/apt/apt.conf.d/20apt-esm-hook.conf
```

## Server hardening

### Update system and activate automatic security updates

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Configure SSH

On client machine, generate key pair and copy to server:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/serverkey
ssh-copy-id -i ~/.ssh/serverkey.pub username@yourip
```

On server, disable password-based authentication:

```bash
sudo nano /etc/ssh/sshd_config
```

Set the following options:

```
PasswordAuthentication no
PubkeyAuthentication yes
```

Then restart SSH:

```bash
sudo systemctl restart ssh
```

## Data quality

Once everything is up and running the integrity of the media library should be monitored.

Print a directory tree:

```bash
ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
```

Check which media uses the most storage space:

```bash
du -sch /usr/media/movies/* /usr/media/tvseries/* | sort -rh
```

Make sure that all the files in the media directory have an extension:

```bash
find /usr/media/movies -type f ! -name "*.*"
```
