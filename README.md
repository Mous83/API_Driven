# Atelier API-Driven Infrastructure

## Description du projet
Ce projet simule une architecture **Serverless** sur AWS grâce à l'outil **LocalStack**.
L'objectif est de piloter une infrastructure (démarrer ou arrêter une instance EC2) via une simple requête Web (API), sans utiliser de console graphique.

## Architecture Technique
Le projet repose sur le flux suivant :
1. **API Gateway** : Reçoit la requête HTTP de l'utilisateur.
2. **Lambda (Python)** : Fonction "Serverless" qui analyse la demande et communique avec AWS via `boto3`.
3. **EC2 (Instance)** : La machine virtuelle qui est démarrée ou arrêtée selon l'ordre reçu.

Tout ceci s'exécute localement dans un conteneur Docker via LocalStack.

## Guide d'installation
Le déploiement est entièrement automatisé.

1. **Démarrer l'environnement LocalStack :**
   ```bash
   localstack start -d
   ```

2. **Lancer le script d'installation :**
    ```chmod +x install.sh
    ./install.sh
    ```

Ce script va automatiquement :

Créer une instance EC2 de test.

Déployer la fonction Lambda et créer l'API Gateway.

Configurer les permissions IAM.

Utilisation
Une fois le script terminé, il vous fournira une URL. Copiez cette URL à la suite de l'adresse de votre Codespace (port 4566).

Exemple d'action : Pour arrêter l'instance, ajoutez ?action=stop&id=i-xxxxx à la fin de l'URL.
