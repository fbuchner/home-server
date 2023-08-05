# Useful steps to configure a fresh install ubuntu home server

> Note that most commands require sudo privilege

## Initial configuration

### Setup Portainer environment
```
apt install docker-ce
systemctl status docker
docker create --name portainer --restart=always --net=bridge -e PGID=1001 -e PUID=1001 -v /docker/portainer/config:/config -v /var/run/docker.sock:/var/run/docker.sock -p 9000:9000 portainer/portainer
docker start portainer
```

### Setup new disk
```
lsblk -f
mkfs -t ext4 /dev/sda 
mkdir -p /usr/media
mount -t auto /dev/sda /usr/media
cp /etc/fstab /etc/fstab.backup
echo "/dev/sda /usr/media ext4 defaults 0 0" >> /etc/fstab
mount -a
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

## Server hardening
### Update system and activate automatic security updates
```
apt-get update && apt-get upgrade -y
dpkg-reconfigure -plow unattended-upgrades
```


