# 3. Stockage, partage réseau et sauvegarde automatisée

**Objectif :** gérer le stockage d'un serveur (partitions, LVM), partager un dossier sur le réseau avec **NFS**, et mettre en place une **sauvegarde automatique** planifiée.

## Partitionnement et montage

Création d'une partition sur un second disque, formatage, montage, puis montage automatique au démarrage via `/etc/fstab`.

```
$ sudo fdisk /dev/sdb          # créer la partition
$ sudo mkfs.ext4 /dev/sdb1     # formater
$ sudo mount /dev/sdb1 /mnt/backup
$ sudo blkid /dev/sdb1         # récupérer l'UUID pour /etc/fstab
```

J'ai aussi pratiqué **LVM** (Physical Volume, Volume Group, Logical Volume) pour créer des partitions redimensionnables, et agrandir un volume à chaud.

## Partage réseau NFS

Le dossier `/mnt/backup` d'un serveur est partagé sur le réseau pour qu'une autre machine puisse écrire ses sauvegardes dedans.

**Côté serveur** (`/etc/exports`) :
```
/mnt/backup 10.3.1.11(rw,sync,no_subtree_check)
```

**Côté client :**
```
$ sudo dnf install nfs-utils
$ sudo mount 10.3.1.13:/mnt/backup /mnt/music_backup
```

## Sauvegarde automatisée (service + timer systemd)

Le script [`../scripts/backup.sh`](../scripts/backup.sh) compresse le dossier à sauvegarder dans une archive horodatée. Il est déclenché par un **service systemd** de type `oneshot`, lui-même lancé régulièrement par un **timer**.

`backup.service` :
```ini
[Unit]
Description=Sauvegarde automatisée

[Service]
Type=oneshot
ExecStart=/opt/backup.sh

[Install]
WantedBy=multi-user.target
```

`backup.timer` (toutes les 5 h) :
```ini
[Timer]
OnBootSec=10min
OnUnitActiveSec=5h
Unit=backup.service

[Install]
WantedBy=timers.target
```

```
$ sudo systemctl enable --now backup.timer
$ sudo systemctl start backup       # test manuel
$ ls /mnt/music_backup/
music_250115_123426.tar.gz
```

## Ce que j'en retiens

Une sauvegarde qu'on doit penser à lancer est une sauvegarde qui n'existe pas. Les timers systemd permettent d'automatiser proprement, avec des logs consultables via `journalctl`.

## Outils

Rocky Linux · fdisk, LVM, mkfs · NFS · systemd (service + timer) · tar · Bash
