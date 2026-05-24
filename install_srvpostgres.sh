#!/bin/bash

IP=$(hostname -I | awk '{print $2}')
echo "START - install postgres - $IP"

echo "[1]: Mise à jour du système et installation des dépendances"
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y vim git wget curl locales

# Configuration des locales
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

echo "[2]: Installation de PostgreSQL 15"
apt-get install -y postgresql postgresql-contrib

echo "[3]: Configuration de PostgreSQL"
# Création de l'utilisateur vagrant avec mot de passe
sudo -u postgres psql -c "CREATE USER vagrant WITH PASSWORD 'vagrant' CREATEDB;"

# Création des bases de données
sudo -u postgres psql -c "CREATE DATABASE dev OWNER vagrant;"
sudo -u postgres psql -c "CREATE DATABASE stage OWNER vagrant;"
sudo -u postgres psql -c "CREATE DATABASE prod OWNER vagrant;"

# Autoriser l'écoute sur toutes les interfaces
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/15/main/postgresql.conf

# Autoriser les connexions distantes (IPv4)
sed -i "s/127.0.0.1\/32/0.0.0.0\/0/g" /etc/postgresql/15/main/pg_hba.conf

# Ajouter une règle pour permettre la connexion avec mot de passe (plus sécurisé que trust)
echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/15/main/pg_hba.conf

echo "[4]: Redémarrage de PostgreSQL"
systemctl restart postgresql
systemctl enable postgresql

echo "=================================================="
echo "PostgreSQL installé avec succès !"
echo "Serveur : $IP:5432"
echo "Utilisateur : vagrant / mot de passe : vagrant"
echo "Bases de données créées : dev, stage, prod"
echo "Accès distant autorisé"
echo "=================================================="

echo "END - install postgres"
