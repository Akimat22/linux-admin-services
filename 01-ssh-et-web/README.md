# 1. Services SSH et Web

**Objectif :** analyser, sécuriser et déployer les deux services de base d'un serveur Linux : **SSH** (administration à distance) et **NGINX** (serveur web).

## Service SSH

Analyse du service : état, processus, port d'écoute et logs.

```
$ systemctl status sshd
$ ss | grep sshd
Dec 01 18:39:54 Candice sshd[702]: Server listening on 0.0.0.0 port 22.
Dec 01 18:52:45 Candice sshd[1319]: Accepted password for it5 from 10.1.1.6 port 51569 ssh2
```

**Durcissement :** changer le port d'écoute de SSH (22 → port personnalisé) pour réduire le bruit des scans automatiques, et ouvrir le nouveau port dans le pare-feu.

```
$ sudo nano /etc/ssh/ssh_config      # Port <nouveau_port>
$ sudo firewall-cmd --permanent --remove-port=22/tcp
$ sudo firewall-cmd --permanent --add-port=<nouveau_port>/tcp
$ systemctl restart sshd
```

> Changer le port n'est pas une vraie mesure de sécurité à lui seul (security by obscurity), mais réduit nettement le bruit. Les vraies mesures : authentification par clé, désactivation du login root, fail2ban.

## Service Web (NGINX)

Installation, démarrage et vérification du port d'écoute :

```
$ sudo dnf install nginx
$ sudo systemctl start nginx
$ sudo ss -lnpt | grep nginx
LISTEN 0  511  0.0.0.0:80  0.0.0.0:*  users:(("nginx",pid=1501),("nginx",pid=1500))
```

**Déploiement d'un site :** création d'un dossier web, d'une page `index.html`, gestion des permissions (le fichier appartient à l'utilisateur `nginx`), et configuration d'un *server block* qui écoute sur un port dédié.

```nginx
server {
  listen 23372;
  root /var/www/tp1_parc;
}
```

```
PS> curl 10.1.1.1:23372
StatusCode : 200
Content    : <h1>MEOW mon premier serveur web</h1>
```

## Outils

Rocky Linux · systemd · SSH (sshd) · NGINX · firewalld · ss · curl
