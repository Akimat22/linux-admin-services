#!/bin/bash

log_message() {
    local log_level="$1"
    local message="$2"
    echo "$(date "+%H:%M:%S") [$log_level] $message"
}

if [ "$(id -u)" -ne 0 ]; then
    log_message "ERROR" "Ce script doit être exécuté en root."
    exit 1
fi

log_message "INFO" "Le script d'autoconfiguration a démarré."

if [ -z "$1" ]; then
    log_message "ERROR" "Veuillez fournir un nom d'hôte en argument."
    exit 1
fi

current_hostname=$(hostnamectl --static)
current_user=$(whoami)


current_mode=$(sestatus | grep "Current mode" | awk '{print $3}')
if [ "$current_mode" != "permissive" ]; then
    log_message "WARN" "SELinux est toujours activé !"
    log_message "INFO" "Désactivation de SELinux temporaire (setenforce)."
    setenforce 0
    log_message "INFO" "SELinux est maintenant temporairement en mode permissive."
else
    log_message "INFO" "SELinux est déjà en mode permissive (temporaire)."
fi


config_file="/etc/selinux/config"
if grep -q "^SELINUX=enforcing" "$config_file"; then
    log_message "INFO" "Désactivation de SELinux définitive (fichier de config)."
    sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' "$config_file"
    log_message "INFO" "Le fichier de configuration a été mis à jour."
else
    log_message "INFO" "Le fichier de configuration est déjà en mode permissive."
fi

log_message "INFO" "Configuration de SELinux terminée."


if ! systemctl is-active --quiet firewalld; then
    log_message "ERROR" "Le pare-feu (firewalld) n'est pas activé. Activez-le avec 'systemctl start firewalld'."
    exit 1
fi

log_message "INFO" "Le pare-feu (firewalld) est actif. Tout est bon !"


ssh_config="/etc/ssh/sshd_config"
if ss -tuln | grep -q ':22 '; then
    log_message "WARN" "Le service SSH tourne toujours sur le port 22/TCP"

    
    new_port=$((RANDOM % 64511 + 1025))
    log_message "INFO" "Modification du fichier de configuration SSH pour écouter sur le port $new_port."

    
    sed -i "s/^Port 22/Port $new_port/" "$ssh_config"
    log_message "INFO" "Fichier de configuration SSH mis à jour."

    systemctl restart sshd
    log_message "INFO" "Redémarrage du service SSH."

    # Maj du firewall
    firewall-cmd --permanent --add-port=$new_port/tcp
    firewall-cmd --permanent --remove-port=22/tcp
    firewall-cmd --reload
    log_message "INFO" "Ouverture du port $new_port dans firewalld et fermeture du port 22."
else
    log_message "INFO" "Le serveur SSH ne tourne pas sur le port 22. Tout est bon !"
fi


if [ "$current_hostname" == "localhost" ]; then
    log_message "WARN" "La machine s'appelle toujours localhost !"
    log_message "INFO" "Changement du nom pour $1."

    
    hostnamectl set-hostname "$1"
    if [ $? -eq 0 ]; then
        log_message "INFO" "Nom d'hôte changé avec succès en $1."
    else
        log_message "ERROR" "Erreur : Impossible de changer le nom d'hôte."
        exit 2
    fi
else
    log_message "INFO" "Le nom d'hôte actuel est déjà $current_hostname. Aucun changement nécessaire."
fi

# wheel check ;p
if ! groups "$current_user" | grep -q "\bwheel\b"; then
    log_message "WARN" "L'utilisateur '$current_user' ne fait pas partie du groupe 'wheel'."
else
    log_message "INFO" "L'utilisateur '$current_user' fait bien partie du groupe 'wheel'."
fi

log_message "INFO" "Le script d'autoconfiguration s'est correctement déroulé."
