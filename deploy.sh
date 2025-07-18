#!/bin/bash

# Script de déploiement automatique pour AutoSupervise
# Usage: ./deploy.sh [ip_du_serveur] [utilisateur_ssh]

set -e

# Couleurs pour une meilleure lisibilité
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration par défaut des ports
ELASTICSEARCH_PORT=9200
KIBANA_PORT=5601
LOGSTASH_PORT=5044
KAFKA_PORT=9092
USE_PASSWORD=false
SSH_PASSWORD=""

# Vérification des arguments
if [ "$#" -lt 2 ]; then
    log_error "Usage: ./deploy.sh [ip_du_serveur] [utilisateur_ssh] [options]"
    log_error "Exemple: ./deploy.sh 192.168.1.100 ubuntu"
    log_error "Options disponibles:"
    log_error "  --elasticsearch-port=PORT  (défaut: 9200)"
    log_error "  --kibana-port=PORT         (défaut: 5601)"
    log_error "  --logstash-port=PORT       (défaut: 5044)"
    log_error "  --kafka-port=PORT          (défaut: 9092)"
    log_error "  --use-password             Active l'authentification par mot de passe"
    exit 1
fi

SERVER_IP=$1
SSH_USER=$2
REMOTE_DIR="/opt/autosupervise"

# Traitement des options de port
shift 2
for i in "$@"; do
  case $i in
    --elasticsearch-port=*)
      ELASTICSEARCH_PORT="${i#*=}"
      shift
      ;;
    --kibana-port=*)
      KIBANA_PORT="${i#*=}"
      shift
      ;;
    --logstash-port=*)
      LOGSTASH_PORT="${i#*=}"
      shift
      ;;
    --kafka-port=*)
      KAFKA_PORT="${i#*=}"
      shift
      ;;
    --use-password)
      USE_PASSWORD=true
      shift
      ;;
    *)
      # option inconnue
      ;;
  esac
done

# Demande de mot de passe SSH si l'option est activée
if [ "$USE_PASSWORD" = true ]; then
  read -sp "Entrez le mot de passe SSH pour ${SSH_USER}@${SERVER_IP}: " SSH_PASSWORD
  echo ""
fi

log_info "Début du déploiement d'AutoSupervise sur $SERVER_IP..."
log_info "Ports configurés: Elasticsearch=$ELASTICSEARCH_PORT, Kibana=$KIBANA_PORT, Logstash=$LOGSTASH_PORT, Kafka=$KAFKA_PORT"

# Vérification de la connexion SSH
log_info "Vérification de la connexion SSH..."

if [ "$USE_PASSWORD" = true ]; then
    # Utiliser sshpass pour l'authentification par mot de passe
    # Vérifier si sshpass est installé
    if ! command -v sshpass &> /dev/null; then
        log_error "sshpass n'est pas installé. Veuillez l'installer avec: sudo apt-get install sshpass"
        exit 1
    fi
    
    sshpass -p "$SSH_PASSWORD" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} echo "Connexion SSH réussie" || {
        log_error "Impossible de se connecter au serveur. Vérifiez l'IP, l'utilisateur et le mot de passe SSH."
        exit 1
    }
else
    # Authentification par clé
    ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} echo "Connexion SSH réussie" || {
        log_error "Impossible de se connecter au serveur. Vérifiez l'IP et les informations SSH."
        log_error "Si vous utilisez un mot de passe, ajoutez l'option --use-password"
        exit 1
    }
fi

# Préparation du serveur
log_info "Préparation du serveur..."

# Utiliser sshpass si l'option mot de passe est activée
if [ "$USE_PASSWORD" = true ]; then
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} << 'EOF'
    # Mise à jour des paquets
    sudo apt update && sudo apt upgrade -y
    
    # Installation des dépendances
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Vérification si Docker est déjà installé
    if ! command -v docker &> /dev/null; then
        echo "Installation de Docker..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update && sudo apt install -y docker-ce
        sudo systemctl enable docker
        sudo systemctl start docker
    else
        echo "Docker est déjà installé."
    fi

    # Vérification si Docker Compose est déjà installé
    if ! command -v docker-compose &> /dev/null; then
        echo "Installation de Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker Compose est déjà installé."
    fi

    # Création du répertoire de projet
    sudo mkdir -p /opt/autosupervise
    sudo chown $(whoami):$(whoami) /opt/autosupervise
EOF
else
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} << 'EOF'
    # Mise à jour des paquets
    sudo apt update && sudo apt upgrade -y
    
    # Installation des dépendances
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Vérification si Docker est déjà installé
    if ! command -v docker &> /dev/null; then
        echo "Installation de Docker..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update && sudo apt install -y docker-ce
        sudo systemctl enable docker
        sudo systemctl start docker
    else
        echo "Docker est déjà installé."
    fi

    # Vérification si Docker Compose est déjà installé
    if ! command -v docker-compose &> /dev/null; then
        echo "Installation de Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker Compose est déjà installé."
    fi

    # Création du répertoire de projet
    sudo mkdir -p /opt/autosupervise
    sudo chown $(whoami):$(whoami) /opt/autosupervise
EOF
fi

# Transfert des fichiers du projet
log_info "Transfert des fichiers du projet..."

if [ "$USE_PASSWORD" = true ]; then
    # Utiliser sshpass avec rsync directement avec l'option -p
    sshpass -p "$SSH_PASSWORD" rsync -avz --exclude 'node_modules' --exclude '.git' --progress /home/chater/Bureau/AutoSupervise/ ${SSH_USER}@${SERVER_IP}:${REMOTE_DIR}/
else
    rsync -avz --exclude 'node_modules' --exclude '.git' --progress /home/chater/Bureau/AutoSupervise/ ${SSH_USER}@${SERVER_IP}:${REMOTE_DIR}/
fi

# Déploiement du projet
log_info "Déploiement du projet..."
if [ "$USE_PASSWORD" = true ]; then
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} << EOF
    cd ${REMOTE_DIR}
    
    # Vérification des fichiers nécessaires
    if [ ! -f "docker-compose.yml" ]; then
        echo "Erreur: docker-compose.yml introuvable!"
        exit 1
    fi
    
    # Vérification et création des répertoires de données si nécessaire
    mkdir -p data
    
    # Modification des ports dans docker-compose.yml
    sed -i "s/9200:9200/${ELASTICSEARCH_PORT}:9200/g" docker-compose.yml
    sed -i "s/5601:5601/${KIBANA_PORT}:5601/g" docker-compose.yml
    sed -i "s/9092:9092/${KAFKA_PORT}:9092/g" docker-compose.yml
    sed -i "s/5044:5044/${LOGSTASH_PORT}:5044/g" docker-compose.yml
    
    # Lancement des conteneurs
    docker-compose down || true  # Arrêt des anciens conteneurs s'ils existent
    docker-compose up -d
    
    # Vérification du statut des conteneurs
    echo "Statut des conteneurs:"
    docker-compose ps
    
    # Affichage des ports utilisés
    echo "Ports utilisés:"
    docker-compose ps | grep -o '0.0.0.0:[0-9]*' || echo "Aucun port exposé"
EOF
else
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} << EOF
    cd ${REMOTE_DIR}
    
    # Vérification des fichiers nécessaires
    if [ ! -f "docker-compose.yml" ]; then
        echo "Erreur: docker-compose.yml introuvable!"
        exit 1
    fi
    
    # Vérification et création des répertoires de données si nécessaire
    mkdir -p data
    
    # Modification des ports dans docker-compose.yml
    sed -i "s/9200:9200/${ELASTICSEARCH_PORT}:9200/g" docker-compose.yml
    sed -i "s/5601:5601/${KIBANA_PORT}:5601/g" docker-compose.yml
    sed -i "s/9092:9092/${KAFKA_PORT}:9092/g" docker-compose.yml
    sed -i "s/5044:5044/${LOGSTASH_PORT}:5044/g" docker-compose.yml
    
    # Lancement des conteneurs
    docker-compose down || true  # Arrêt des anciens conteneurs s'ils existent
    docker-compose up -d
    
    # Vérification du statut des conteneurs
    echo "Statut des conteneurs:"
    docker-compose ps
    
    # Affichage des ports utilisés
    echo "Ports utilisés:"
    docker-compose ps | grep -o '0.0.0.0:[0-9]*' || echo "Aucun port exposé"
EOF
fi

# Configuration du pare-feu
log_info "Configuration du pare-feu..."
if [ "$USE_PASSWORD" = true ]; then
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} << ENDSSH
    # Vérification si UFW est installé
    if command -v ufw &> /dev/null; then
        # Ouverture des ports nécessaires
        sudo ufw allow ${KIBANA_PORT}/tcp  # Kibana
        sudo ufw allow ${ELASTICSEARCH_PORT}/tcp  # Elasticsearch
        sudo ufw allow ${KAFKA_PORT}/tcp  # Kafka
        sudo ufw allow ${LOGSTASH_PORT}/tcp  # Logstash
        
        # Activation du pare-feu s'il n'est pas déjà actif
        sudo ufw --force enable
    else
        echo "UFW n'est pas installé. Vous devrez configurer le pare-feu manuellement."
    fi
ENDSSH
else
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SERVER_IP} << ENDSSH
    # Vérification si UFW est installé
    if command -v ufw &> /dev/null; then
        # Ouverture des ports nécessaires
        sudo ufw allow ${KIBANA_PORT}/tcp  # Kibana
        sudo ufw allow ${ELASTICSEARCH_PORT}/tcp  # Elasticsearch
        sudo ufw allow ${KAFKA_PORT}/tcp  # Kafka
        sudo ufw allow ${LOGSTASH_PORT}/tcp  # Logstash
        
        # Activation du pare-feu s'il n'est pas déjà actif
        sudo ufw --force enable
    else
        echo "UFW n'est pas installé. Vous devrez configurer le pare-feu manuellement."
    fi
ENDSSH
fi

log_info "✅ Déploiement terminé avec succès!"
log_info "Vous pouvez accéder à Kibana via: http://${SERVER_IP}:${KIBANA_PORT}"
log_info "Vous pouvez accéder à Elasticsearch via: http://${SERVER_IP}:${ELASTICSEARCH_PORT}"
log_warning "IMPORTANT: Pour un environnement de production, configurez la sécurité (HTTPS, authentification) pour protéger vos services."