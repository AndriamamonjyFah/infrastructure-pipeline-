#!/bin/bash

IP=$(hostname -I | awk '{print $2}')
echo "START - install registry - $IP"

echo "[1]: Mise à jour du système et installation des dépendances"
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y git wget curl vim openssl

echo "[2]: Installation de Docker"
curl -fsSL https://get.docker.com | sh

# Ajout de l'utilisateur vagrant au groupe docker (utile pour les tests)
usermod -aG docker vagrant

echo "[3]: Installation de Docker Compose (version récente)"
curl -sL "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "[4]: Configuration et installation du Docker Registry avec TLS"

# Création des dossiers
mkdir -p certs passwd data

# Génération du certificat auto-signé (valable 1 an)
openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout certs/myregistry.key \
  -out certs/myregistry.crt \
  -days 365 \
  -subj "/CN=$IP" \
  -addext "subjectAltName = IP:$IP"

# Création du fichier htpasswd (utilisateur: fahendrena / mot de passe: password)
docker run --entrypoint htpasswd registry:2 -Bbn fahendrena password > passwd/htpasswd

# Création du docker-compose.yml (version moderne)
cat > docker-compose-registry.yml << 'EOF'
version: '3.8'

services:
  registry:
    restart: always
    image: registry:2
    container_name: registry
    ports:
      - "5000:5000"
    environment:
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/myregistry.crt
      REGISTRY_HTTP_TLS_KEY: /certs/myregistry.key
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
      REGISTRY_STORAGE_DELETE_ENABLED: 'true'
    volumes:
      - ./data:/var/lib/registry
      - ./certs:/certs
      - ./passwd:/auth
EOF

echo "[5]: Démarrage du Registry"
docker-compose -f docker-compose-registry.yml up -d

echo "=================================================="
echo "Docker Registry installé avec succès !"
echo "Adresse : https://$IP:5000"
echo "Utilisateur : fahendrena"
echo "Mot de passe : password"
echo ""
echo "Pour tester la connexion :"
echo "docker login https://$IP:5000"
echo "   Username: fahendrena"
echo "   Password: password"
echo "=================================================="

echo "END - install registry"
