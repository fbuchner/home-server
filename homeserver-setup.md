# Useful steps to configure a fresh install ubuntu home server

> Note that most commands require sudo privilege

## Initial configuration

### Setup Portainer environment
```
apt install docker-ce
systemctl status docker
docker create --name portainer --restart=always --net=bridge -e PGID=1001 -e PUID=1001 -v /docker/portainer/config:/config -v /var/run/docker.sock:/var/run/docker.sock -p 9443:9443 portainer/portainer-ce
docker start portainer
```

### Setup new disk
Make sure to only add the automatic mounting with fstab if the volume will not be encrypted. A failure in mounting because of an encrypted volume leads to the system refusing to boot up properly.
```
lsblk -f
mkfs -t ext4 /dev/sda 
mkdir -p /usr/media
mount -t auto /dev/sda /usr/media
cp /etc/fstab /etc/fstab.backup
echo "/dev/sda /usr/media ext4 defaults 0 0" >> /etc/fstab
mount -a
```

### Setup encrypted backup disk
You can find scripts for automatic mounting and unmounting of the encrypted backup disk in the scripts folder.
```
lsblk -f
sudo umount /dev/sdb
sudo cryptsetup luksFormat /dev/sdb
sudo cryptsetup luksOpen /dev/sdb backup
sudo mkfs.ext4 /dev/mapper/backup
sudo mkdir /mnt/backup
sudo mount /dev/mapper/backup /mnt/backup

sudo umount backup
sudo cryptsetup luksClose backup
```

### Setup fileshare
```
apt install samba
nano /etc/samba/smb.conf
service smbd restart
ufw allow samba
adduser sambauser
smbpasswd -a sambauser
chmod -R 1777 /usr/media/
```

```
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
```
swapon --show
swapoff -a
dd if=/dev/zero of=/swap.img bs=1G count=18 status=progress
chmod 600 /swap.img
mkswap /swap.img
swapon /swap.img
free -h
echo '/swap.img none swap sw 0 0' | sudo tee -a /etc/fstab 
```

### Misc
Remove ubuntu pro advertisement
```
dpkg-divert --divert /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak --rename --local /etc/apt/apt.conf.d/20apt-esm-hook.conf
```

## Server hardening
### Update system and activate automatic security updates
```
apt-get update && apt-get upgrade -y
dpkg-reconfigure -plow unattended-upgrades
```

### Configure SSH
On client machine generate key pair and copy to server
```
ssh-keygen serverkey
ssh-copy-id username@yourip
```
On server remove password-based authentication
```
nano /etc/ssh/sshd_config
```
Set PasswordAuthentication no and PubkeyAuthentication yes
```
systemctl restart ssh
```

### Data quality
Once everything is up and running the integrity of the media library should be monitored.

Print a directory tree
```
ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
```

Check which media uses the most storage space
```
du -sch /usr/media/movies/* /usr/media/tvseries/*  | sort -rh
```

Make sure that all the files in the media directory have an extension
```
find /usr/media/movies -type f ! -name "*.*"
```
