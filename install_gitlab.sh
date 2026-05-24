#!/bin/bash

IP=$(hostname -I | awk '{print $2}')
echo "START - install gitlab - $IP"

echo "[1]: Mise à jour du système et installation des dépendances"
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y curl wget vim git openssh-server ca-certificates tzdata locales

# Configuration des locales (évite les warnings)
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "[2]: Ajout du dépôt officiel GitLab"
curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

echo "[3]: Installation de GitLab CE"
# IMPORTANT : EXTERNAL_URL doit être défini avant l'installation
export EXTERNAL_URL="http://$IP"

apt-get update -qq
apt-get install -y gitlab-ce

echo "[4]: Reconfiguration de GitLab"
gitlab-ctl reconfigure

echo "=================================================="
echo "GitLab installé avec succès !"
echo "Accédez à GitLab via : http://$IP"
echo "Le mot de passe root initial est disponible dans : sudo cat /etc/gitlab/initial_root_password"
echo "=================================================="

echo "END - install gitlab"
