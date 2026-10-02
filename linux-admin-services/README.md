# Administration de serveurs Linux : services, sécurité & supervision

Labs d'administration système Linux du Bachelor Cybersécurité & Ethical Hacking (EFREI, 2026). De l'installation d'un serveur Rocky Linux à la supervision avec alertes, en passant par les services (SSH, web, streaming), le stockage, la sauvegarde automatisée et le scripting.

> **Note sécurité :** les secrets présents à l'origine (webhook Discord, token Netdata) ont été retirés et remplacés par des marqueurs du type `<WEBHOOK_MASQUE>`.

## Sommaire

1. [Services SSH et Web](01-ssh-et-web/) — analyse, durcissement SSH, déploiement NGINX
2. [Utilisateurs, droits et processus](02-utilisateurs-et-processus/) — sudo, permissions, investigation
3. [Stockage, NFS et sauvegarde](03-stockage-et-backup/) — partitions, LVM, NFS, timer systemd
4. [Streaming et supervision](04-streaming-et-monitoring/) — Jellyfin, Netdata, alertes Discord
5. [Scripts](scripts/) — `autoconfig.sh` (mise en service auto) et `backup.sh`

## Compétences

| Domaine | Technologies |
|---|---|
| Systèmes | Rocky Linux, systemd, SELinux, firewalld |
| Services | SSH, NGINX, Jellyfin, NFS |
| Stockage | partitions, LVM, /etc/fstab |
| Automatisation | Bash, services + timers systemd |
| Supervision | Netdata, checks TCP, alerting Discord |

## Fil rouge

Ces TP suivent le cycle de vie d'un serveur : on l'installe et on le configure automatiquement (`autoconfig.sh`), on y déploie des services, on sécurise les accès et les droits, on sauvegarde les données, et enfin on surveille le tout pour être alerté en cas de problème.
