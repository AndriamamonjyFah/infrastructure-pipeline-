#!/bin/bash

IP=$(hostname -I | awk '{print $2}')
echo "START - install jenkins - $IP"

echo "[1]: install utils & ansible"
apt-get update -qq
apt-get install -y git sshpass wget curl gnupg2 ansible

echo "[2]: install java & jenkins"
# Nouvelle clé GPG Jenkins 2026 (obligatoire)
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Ajout du dépôt avec signed-by
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update -qq
apt-get install -y fontconfig openjdk-17-jre jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "Jenkins installé et démarré"

echo "[3]: ansible custom"
# Création du fichier s'il n'existe pas
mkdir -p /etc/ansible
if [ ! -f /etc/ansible/ansible.cfg ]; then
    cp /usr/share/doc/ansible/examples/ansible.cfg /etc/ansible/ansible.cfg 2>/dev/null || true
fi

sed -i 's/.*pipelining.*/pipelining = True/' /etc/ansible/ansible.cfg
sed -i 's/.*allow_world_readable_tmpfiles.*/allow_world_readable_tmpfiles = True/' /etc/ansible/ansible.cfg

echo "[4]: install docker & docker-compose"
# Installation officielle Docker
curl -fsSL https://get.docker.com | sh

# Ajout de l'utilisateur jenkins au groupe docker
usermod -aG docker jenkins

# Docker Compose (version plus récente recommandée)
curl -sL "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "[5]: use registry without ssl"
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries" : ["192.168.5.5:5000"]
}
EOF

systemctl daemon-reload
systemctl restart docker

echo "END - install jenkins"
