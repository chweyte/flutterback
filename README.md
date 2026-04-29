# Nokta 📱

Bienvenue dans le dépôt du projet **Nokta**, une application mobile développée dans le cadre du module de Développement Mobile (Semestre 4). 

Ce projet a été rigoureusement conçu pour respecter l'ensemble des consignes académiques, en mettant l'accent sur la qualité du code, l'interactivité, et les standards de l'industrie mobile.

---

## 🎯 Objectifs et Fonctionnalités Principales

Le projet **Nokta** intègre les fonctionnalités interactives attendues pour une expérience utilisateur moderne et dynamique :
*   **Navigation Multi-écrans :** Flux logique entre les pages Visiteur, Client, Commerçant et Administrateur.
*   **Formulaires et Validations :** Formulaires robustes pour la gestion des utilisateurs et des processus internes.
*   **Opérations CRUD Complètes :** Ajout, modification, affichage et suppression de données en temps réel via des boutons d'actions interactifs.

## 🏗️ Architecture Technique

### 1. Modèle - Vue - Contrôleur (MVC) et Core
Le code source est organisé pour assurer une excellente séparation entre l'interface, la logique métier et la donnée, tout en isolant les configurations globales :
*   `lib/models/` : Structure des entités (Data objects et sérialisation).
*   `lib/views/` : Interfaces graphiques, composants visuels (écrans et widgets).
*   `lib/controllers/` : Logique métier de l'application, gestion des requêtes et communication avec l'état.
*   `lib/core/` : **L'infrastructure globale**. Ce dossier contient les éléments partagés par toute l'application et indépendants du MVC métier, comme le thème de l'application (`app_theme.dart`), les constantes, ou les modèles génériques ou d'infrastructure.

### 2. Gestion d'État Centrée (Provider)
Nous utilisons le package `Provider` (avec `ChangeNotifier`) pour optimiser les performances de l'application. Cette gestion globale permet de :
*   Partager l'état entre les différentes _Views_ sans utiliser de callbacks passés de widget en widget.
*   Reconstruire de manière chirurgicale uniquement les portions d'écran nécessitant une mise à jour suite à une modification des données.

### 3. Connexion Évoluée aux Données (Supabase & API)
L'application ne se repose pas sur des données locales statiques :
*   **Base de données distante :** Intégration de Supabase (Database / Auth) pour conserver les données de façon sécurisée et persistante.
*   **Gestion Asynchrone :** Les appels API transitent par nos _Controllers_ permettant de maintenir l'interface fluide durant les chargements.

### 4. Internationalisation (Multilingue)
Afin d'offrir une accessibilité accrue, l'application prend en charge un basculement dynamique de la langue grâce au package `easy_localization` (Français, Anglais, Arabe). Le changement s'effectue dynamiquement en temps réel.

---

## 🚀 Installation & Exécution

1.  **Cloner le dépôt :**
    ```bash
    git clone [lien_du_depot]
    cd flutterback
    ```
2.  **Installer les dépendances :**
    ```bash
    flutter pub get
    ```
3.  **Générer les traductions (si nécessaire) :**
    ```bash
    flutter pub run easy_localization:generate -S assets/translations -O lib/core -o locale_keys.g.dart
    ```
4.  **Lancer l'application :**
    ```bash
    flutter run
    ```

---

*Projet réalisé de manière collaborative. Chaque membre du groupe a contribué activement à la conception (Vues), au développement (Contrôleurs et Modèles) et à cette présentation finale.*
