# Pipeline DevOps – Infrastructure Vagrant

Infrastructure DevOps demo provisionnée avec **Vagrant** et **VirtualBox** sur Debian 12 (Bookworm).  
Elle simule un cycle de vie applicatif complet : développement → staging → production, avec intégration continue (Jenkins), gestion de source (GitLab), base de données (PostgreSQL) et registre Docker privé.

---

## Architecture

```
+------------------+       +----------------+       +-----------------+
|  p1jenkins       | ----> |  srvdev        | ----> |  srvstage       |
|  192.168.56.10   |       |  192.168.5.3   |       |  192.168.5.7    |
|  Jenkins + Docker|       |  Dev env       |       |  Staging env    |
+------------------+       +----------------+       +-----------------+
         |                                                    |
         v                                                    v
+------------------+       +----------------+       +-----------------+
|  registry        |       |  srvbdd        |       |  srvprod        |
|  192.168.5.5     |       |  192.168.5.6   |       |  192.168.5.4    |
|  Docker Registry |       |  PostgreSQL 15 |       |  Production env |
+------------------+       +----------------+       +-----------------+
                           +----------------+
                           |  gitlab        |
                           |  192.168.5.10  |
                           |  GitLab CE     |
                           +----------------+
```

| VM | IP | RAM | Rôle |
|---|---|---|---|
| `p1jenkins-pipeline` | 192.168.56.10 | 4 Go | Jenkins CI/CD + Docker + Ansible |
| `srvdev-pipeline` | 192.168.5.3 | 1 Go | Environnement de développement |
| `srvstage-pipeline` | 192.168.5.7 | 1 Go | Environnement de staging |
| `srvprod-pipeline` | 192.168.5.4 | 1 Go | Environnement de production |
| `srvbdd-pipeline` | 192.168.5.6 | 1 Go | Base de données PostgreSQL 15 |
| `registry-pipeline` | 192.168.5.5 | 1 Go | Docker Registry privé (TLS + htpasswd) |
| `gitlab-pipeline` | 192.168.5.10 | 4 Go | GitLab CE |

---

## Prérequis

- [Vagrant](https://www.vagrantup.com/) >= 2.3
- [VirtualBox](https://www.virtualbox.org/) >= 7.0
- **~13 Go de RAM** disponibles (toutes VMs actives simultanément)
- Plugin recommandé : `vagrant plugin install vagrant-vbguest`

---

## Lancement

```bash
# Cloner le dépôt
git clone https://github.com/AndriamamonjyFah/infrastructure-pipeline.git
cd Pipeline_DevOps

# Démarrer toutes les VMs
vagrant up

# Démarrer une VM spécifique
vagrant up p1jenkins-pipeline
vagrant up gitlab-pipeline

# Accéder à une VM en SSH
vagrant ssh p1jenkins-pipeline

# Arrêter toutes les VMs
vagrant halt

# Détruire l'environnement
vagrant destroy -f
```

---

## Accès aux services

| Service | URL | Identifiants par défaut |
|---|---|---|
| Jenkins | http://192.168.56.10:8080 | Voir `/var/lib/jenkins/secrets/initialAdminPassword` |
| GitLab | http://192.168.5.10 | `root` / voir `/etc/gitlab/initial_root_password` |
| Docker Registry | https://192.168.5.5:5000 | Voir `.env` (à configurer) |
| PostgreSQL | 192.168.5.6:5432 | Voir `.env` (à configurer) |

> ⚠️ Les identifiants par défaut sont à modifier immédiatement après la première connexion.

---

## Variables d'environnement sensibles

Avant de lancer l'infrastructure, créez un fichier `.env` (non versionné) à la racine :

```env
REGISTRY_USER=your_registry_user
REGISTRY_PASSWORD=your_secure_password
POSTGRES_USER=your_pg_user
POSTGRES_PASSWORD=your_secure_password
```

Les scripts de provisioning peuvent être adaptés pour lire ces variables.

---

## Stack technique

| Outil | Usage |
|---|---|
| **Vagrant** | Orchestration des VMs |
| **VirtualBox** | Hyperviseur |
| **Jenkins** | CI/CD (pipelines, jobs) |
| **GitLab CE** | Gestion de code source |
| **Docker + Compose** | Conteneurisation |
| **Ansible** | Déploiement automatisé |
| **PostgreSQL 15** | Base de données relationnelle |
| **Docker Registry** | Registre d'images privé (TLS) |
| **Debian 12 (Bookworm)** | OS de base |

---

## Structure du projet

```
Pipeline_DevOps/
├── Vagrantfile                  # Définition des 7 VMs
├── install_p1jenkins.sh         # Provisioning Jenkins + Docker + Ansible
├── install_gitlab.sh            # Provisioning GitLab CE
├── install_registry.sh          # Provisioning Docker Registry (TLS)
├── install_srvpostgres.sh       # Provisioning PostgreSQL 15
├── .gitignore
└── README.md
```

---


