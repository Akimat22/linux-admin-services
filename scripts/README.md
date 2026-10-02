# Scripts

## `autoconfig.sh`

Script d'auto-configuration d'une machine **Rocky Linux** fraîchement installée. Il automatise les premières étapes de mise en service d'un serveur et journalise chaque action avec un niveau (`INFO`, `WARN`, `ERROR`).

Ce qu'il fait :
- vérifie qu'il est lancé en **root** ;
- passe **SELinux** en mode permissif (temporaire + fichier de conf) ;
- vérifie que le **pare-feu firewalld** est actif ;
- **déplace SSH** du port 22 vers un port aléatoire, et met à jour le pare-feu en conséquence ;
- change le **nom d'hôte** si la machine s'appelle encore `localhost` ;
- vérifie l'appartenance de l'utilisateur au groupe `wheel`.

```bash
sudo ./autoconfig.sh mon-serveur.local
```

## `backup.sh`

Script de sauvegarde : il compresse un dossier source dans une archive `tar.gz` horodatée, déposée sur une partition de sauvegarde, et vérifie que la compression a réussi. Il est conçu pour être lancé automatiquement par un **service + timer systemd** (voir [`../03-stockage-et-backup/`](../03-stockage-et-backup/)).

```bash
./backup.sh
# -> music_251002_143026.tar.gz créé dans le dossier de destination
```
