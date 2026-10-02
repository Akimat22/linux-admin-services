# 4. Serveur de streaming et supervision

**Objectif :** déployer un vrai service applicatif (**Jellyfin**, serveur de streaming multimédia) puis le **superviser** avec **Netdata**, avec des alertes automatiques quand un service tombe.

## Serveur de streaming Jellyfin

Déploiement sur Rocky Linux : ajout des dépôts, installation, démarrage, ouverture du port dans le pare-feu.

```
$ sudo dnf install jellyfin
$ sudo systemctl start jellyfin
$ sudo ss -lnpt | grep jellyfin
LISTEN 0  512  0.0.0.0:8096  0.0.0.0:*  users:(("jellyfin",pid=778))
$ sudo firewall-cmd --permanent --add-port=8096/tcp && sudo firewall-cmd --reload
```

Les fichiers multimédia sont déposés dans `/srv/music`, transférés depuis le poste client avec `scp`.

## Supervision avec Netdata

Installation de l'agent Netdata, qui expose un tableau de bord temps réel sur le port `19999` (CPU, RAM, disque, réseau, services…).

```
$ sudo systemctl start netdata
$ sudo ss -lnpt | grep netdata
LISTEN 0  4096  0.0.0.0:19999  0.0.0.0:*  users:(("netdata",pid=3025))
```

> Lien avec mon profil : c'est exactement le type d'outil de **métriques** (comme Zabbix ou Nagios) que j'oppose à un **SIEM** dans mes autres travaux. Netdata surveille la *santé* du système ; il répond à « est-ce que ça marche ? ».

## Check de port + alerte

Configuration d'un **check TCP** : Netdata surveille qu'un port précis (le serveur web, par exemple) répond toujours.

```yaml
# /etc/netdata/go.d/portcheck.conf
jobs:
  - name: site.tp3.b1
    host: 10.3.1.11
    ports:
      - 8096
```

Puis configuration d'une **alerte Discord** : dès qu'un service ne répond plus, un message est envoyé automatiquement sur un salon Discord via un webhook.

```
# /etc/netdata/health_alarm_notify.conf
SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/<WEBHOOK_MASQUE>"
DEFAULT_RECIPIENT_DISCORD="alert"
```

Test de l'alerting :

```
$ /usr/libexec/netdata/plugins.d/alarm-notify.sh test
# SENDING TEST WARNING ALARM TO ROLE: sysadmin
RECEIVED HTTP RESPONSE CODE: 200
# OK
```

> Note : le vrai webhook et le token d'enrôlement Netdata ont été retirés de ce dépôt. Ne jamais versionner ce type de secret.

## Ce que j'en retiens

Déployer un service, c'est seulement la moitié du travail : il faut aussi savoir s'il tourne et être prévenu quand il tombe. La chaîne supervision → alerte transforme une panne silencieuse en notification immédiate.

## Outils

Rocky Linux · Jellyfin · Netdata · firewalld · Discord (webhook) · scp
