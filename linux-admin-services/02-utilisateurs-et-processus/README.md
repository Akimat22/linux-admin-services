# 2. Utilisateurs, droits et processus

**Objectif :** maîtriser la gestion des utilisateurs, des droits `sudo` et des processus sous Linux — les bases de l'administration système et un terrain de sécurité (élévation de privilèges, permissions incohérentes).

## Utilisateurs et mots de passe

```
$ grep aki69 /etc/passwd
$ sudo grep aki69 /etc/shadow      # ligne contenant le hash du mot de passe
$ cat /etc/group                   # liste des groupes
```

- `/etc/passwd` : comptes utilisateurs (lisible par tous).
- `/etc/shadow` : hashs des mots de passe (lisible par root seulement).
- `/etc/group` : groupes.

## sudo et gestion fine des droits

Création de groupes et d'utilisateurs, puis configuration de `sudo` via `/etc/sudoers` :

```bash
sudo groupadd stronk_admins
sudo useradd -m -s /bin/bash imbob
sudo passwd imbob
sudo usermod -aG stronk_admins imbob
```

```
# dans sudoers
%stronk_admins ALL=(ALL:ALL) ALL
```

Cet exercice met en évidence un risque classique : des **permissions de dossiers incohérentes** (un répertoire personnel appartenant au mauvais utilisateur) peuvent ouvrir une porte à un autre compte.

## Processus et paquets

```bash
# Lancer et tuer un processus
sleep 1000 &
jobs -l
kill <pid>

# Trouver le chemin d'un binaire
command -v sleep
which firefox

# Gestion de paquets
sudo apt install firefox
cat /etc/apt/sources.list
```

## Analyse « façon investigation »

Petit exercice de forensic sur sa propre machine Windows (PowerShell) : lister les connexions réseau établies, remonter au processus qui les a ouvertes, puis à l'utilisateur et au programme.

```powershell
# Connexions actives et processus associé
Get-NetTCPConnection -State Established | ForEach-Object {
    $p = Get-Process -Id $_.OwningProcess
    [PSCustomObject]@{
        "Remote IP"   = $_.RemoteAddress
        "Remote Port" = $_.RemotePort
        "Process"     = $p.ProcessName
        "PID"         = $_.OwningProcess
    }
} | Format-Table -AutoSize

# En savoir plus sur une IP distante
Invoke-RestMethod -Uri http://ip-api.com/json/<IP>
```

## Ce que j'en retiens

Savoir qui a quels droits et quel processus parle à quelle IP, c'est la base aussi bien de l'administration que de l'analyse d'un incident. Une permission mal posée suffit à casser l'isolation entre deux comptes.

## Outils

Linux (passwd/shadow/group) · sudo · systemd · PowerShell · ps, ss, find
