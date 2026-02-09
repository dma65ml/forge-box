# 📦 forge-box

**Stack Homelab : Forgejo + Runner + Docker-in-Docker (dind)**

Ce dépôt permet de déployer une forge logicielle complète. Il inclut le serveur Forgejo, PostgreSQL, et un exécuteur de jobs capable de construire et déployer des images Docker (CD) via une architecture isolée.

**[WARNING !]**

USAGE INTERNE UNIQUEMENT > Cette stack est configurée pour un usage en réseau local (Homelab).

En l'état, elle utilise des protocoles non sécurisés (HTTP, Docker Socket sans TLS) pour faciliter le déploiement initial. Ne pas exposer cette application directement sur Internet sans la mise en place préalable d'un Reverse Proxy sécurisé (type Traefik ou Nginx) et d'un durcissement des configurations.

# 🚀 Installation Rapide
## 1. Préparer l'environnement
Le runner a besoin de droits spécifiques sur son répertoire de travail pour persister son enregistrement.

```Bash
chmod +x init-data.sh
sudo ./init-data.sh
```

## 2. Configuration initiale du Docker Compose
Avant de lancer la stack, assurez-vous que le service runner est configuré pour rester en attente (et non pour lancer le démon immédiatement).

Dans docker-compose.yaml :

```YAML
# 1. Commenter la commande daemon
# command: '/bin/sh -c "sleep 5; forgejo-runner daemon --config config.yml"'

# 2. Décommenter la commande de mise en veille
command: '/bin/sh -c "while : ; do sleep 1 ; done ;"'
```
## 3. Lancer la stack
```Bash
docker-compose up -d
```

Accès à l'interface : http://localhost:3000

# 🛠 Enregistrement du Runner
Une fois Forgejo configuré (compte admin créé) :

## 1. Récupérer le Token :

Administration du site > Actions > Runners > Créer un nouveau Runner.

Copie le Registration Token.

## 2. Lancer l'enregistrement :
Connectez-vous au conteneur et lancez la commande interactive :

```Bash
docker exec -it runner forgejo-runner register
```
- Instance URL : http://forgejo:3000/
- Runner Name : forge-box-runner
- Labels : docker,linux,local

## 3. Activer le mode Démon :
Modifiez à nouveau le docker-compose.yaml pour activer le service de façon permanente :

```Bash
# 1. Décommenter la commande daemon
command: '/bin/sh -c "sleep 5; forgejo-runner daemon --config config.yml"'

# 2. Commenter la commande de mise en veille
# command: '/bin/sh -c "while : ; do sleep 1 ; done ;"'
```
## 4. Redémarrer pour appliquer :

```Bash
docker-compose up -d
````

# 🏗 Structure du Projet
- docker-compose.yaml : Orchestration (Forgejo, DB, Dind, Runner).
- config.yml : Configuration fine du runner et accès au démon Docker.
- init-data.sh : Script de gestion des permissions et initialisation du cache.
- /data : Volume persistant contenant le fichier d'enregistrement .runner.

# 🧹 Maintenance (Nettoyage Dind)
Le moteur Docker interne (dind) accumule des caches de build au fil du temps. Pour libérer de l'espace :

```Bash
docker exec -it docker_dind docker system prune -af --volumes
````

# 📝 To-do List / Évolutions à venir

Cette section liste les améliorations prévues pour faire évoluer la **forge-box** d'un environnement de test vers une infrastructure de production domestique solide.

- [ ] **Gestion du Registre d'Images (CD)**
    - [ ] Créer un jeton d'accès (PAT) dans Forgejo pour le Runner.
    - [ ] Configurer les secrets du dépôt (`REGISTRY_TOKEN`).
    - [ ] Mettre en place un workflow de nettoyage automatique des anciennes images (retention policy).
- [ ] **Sécurisation avec Traefik**
    - [ ] Ajouter un service Traefik au `docker-compose.yaml` pour le reverse-proxy.
    - [ ] Configurer la génération automatique de certificats SSL via Let's Encrypt.
    - [ ] Isoler Forgejo derrière un nom de domaine (ex: forge.homelab.local).
    - [ ] Sécuriser l'accès au démon Docker (dind) via un réseau interne non exposé.
- [ ] **Optimisation & Monitoring**
    - [ ] Configurer Buildx pour le build multi-architecture (ARM/x64).
    - [ ] Ajouter un exportateur de métriques pour surveiller l'état du Runner.
