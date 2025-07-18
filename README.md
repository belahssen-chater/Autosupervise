# AutoSupervise

## Présentation

AutoSupervise est une solution de monitoring et d'analyse de logs basée sur la stack ELK (Elasticsearch, Logstash, Kibana) avec Kafka pour le traitement des données en temps réel.

## Architecture

Le projet utilise les composants suivants:

- **Zookeeper**: Coordonnateur pour Kafka
- **Kafka**: Système de messagerie distribué pour le traitement des flux de données
- **Elasticsearch**: Moteur de recherche et d'analyse pour stocker les logs
- **Logstash**: Pipeline de traitement des données pour collecter, transformer et envoyer les logs
- **Kibana**: Interface utilisateur pour visualiser et explorer les données

## Installation

Pour démarrer l'environnement:

```bash
docker-compose up -d
```

## Configuration

- Elasticsearch est accessible sur le port 9200
- Kibana est disponible sur le port 5601
- Logstash ingère les logs depuis le fichier test.json

## Formats de logs supportés

Le système prend en charge les formats de logs suivants:
- JSON simple (un objet JSON par ligne)
- Format de log d'accès Web (avec champs comme timestamp, remote_addr, request_method, etc.)
- Logs d'application avec niveau de sévérité (INFO, WARN, ERROR)

## Visualisation des données

Accédez à Kibana via http://localhost:5601 pour:
- Créer des tableaux de bord personnalisés
- Configurer des alertes
- Visualiser les tendances et anomalies
- Analyser les performances

## Structure du projet

```
/home/chater/Bureau/AutoSupervise/
├── docker-compose.yml    # Configuration des services Docker
├── logstash/
│   └── logstash.conf     # Configuration du pipeline Logstash
├── test.json             # Exemple de données de logs
└── README.md             # Documentation du projet
```

## Fonctionnalités

- Ingestion de logs en temps réel
- Traitement et normalisation des données
- Stockage efficace et indexation pour recherche rapide
- Visualisation interactive des métriques
- Alertes configurables basées sur les seuils définis

## Déploiement automatique

Un script de déploiement automatique est disponible pour faciliter l'installation sur un VPS:

```bash
# Rendre le script exécutable
chmod +x deploy.sh

# Exécuter le script avec l'adresse IP et l'utilisateur SSH du serveur
./deploy.sh 192.168.1.100 ubuntu

# Option: spécifier des ports personnalisés pour éviter les conflits
./deploy.sh 192.168.1.100 ubuntu --elasticsearch-port=9201 --kibana-port=5602 --kafka-port=9093 --logstash-port=5045

# Pour se connecter avec un mot de passe SSH
./deploy.sh 192.168.1.100 ubuntu --use-password
```

Le script réalise automatiquement les actions suivantes:
1. Vérification de la connexion SSH
2. Installation de Docker et Docker Compose sur le serveur
3. Transfert des fichiers du projet
4. Configuration des ports dans docker-compose.yml
5. Démarrage des services
6. Configuration du pare-feu
7. Affichage des informations d'accès

Pour plus de détails, consultez le fichier `deploy.sh`.


MDP: SM_$2m=gtE?Jdn
