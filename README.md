# Cht'i Face Bouc

Réseau social développé en Flutter pour le projet mobile de l'IMT.

## Description

Application de réseau social permettant aux utilisateurs de partager des posts, liker, commenter et gérer leur profil. L'interface a été conçue avec un design moderne utilisant des dégradés et des polices personnalisées.

## Fonctionnalités

- **Authentification** : Inscription et connexion avec Firebase Auth
- **Fil d'actualité** : Affichage des posts en temps réel
- **Publications** : Création de posts avec texte et images
- **Interactions** : Système de likes et commentaires
- **Profil utilisateur** : Page de profil personnalisable
- **Notifications** : Suivi des interactions

## Technologies utilisées

- **Framework** : Flutter 3.29
- **Backend** : Firebase (Auth, Firestore, Storage)
- **Fonts** : Google Fonts (Inter, Poppins)
- **Gestion d'images** : image_picker, image_picker_web
- **Internationalisation** : intl

## Installation

### Prérequis

- Flutter SDK (version 3.6.0 ou supérieure)
- Un IDE (VS Code ou Android Studio)
- Un navigateur web (Chrome recommandé) ou un émulateur mobile

### Étapes

1. Cloner le projet
```bash
git clone <url-du-repo>
cd chti_face_bouc
```

2. Installer les dépendances
```bash
flutter pub get
```

3. Lancer l'application
```bash
# Sur Chrome
flutter run -d chrome

# Sur un émulateur Android
flutter run -d android

# Sur un émulateur iOS (macOS uniquement)
flutter run -d ios
```

## Configuration Firebase

Le projet utilise Firebase pour l'authentification et le stockage des données. La configuration est déjà incluse dans `lib/firebase_options.dart`.


## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── firebase_options.dart        # Configuration Firebase
├── modeles/                     # Modèles de données
│   ├── app_theme.dart          # Thème et couleurs
│   ├── membre.dart             # Modèle utilisateur
│   ├── post.dart               # Modèle post
│   └── comment.dart            # Modèle commentaire
├── pages/                       # Pages de l'application
│   ├── page_accueil.dart       # Navigation principale
│   ├── page_authentification.dart
│   ├── page_fil_actualite.dart
│   ├── page_profil.dart
│   └── page_notifications.dart
├── widgets/                     # Composants réutilisables
│   ├── post_card.dart
│   ├── create_post_dialog.dart
│   └── comments_sheet.dart
└── services_firebase/           # Services Firebase
    ├── service_authentification.dart
    ├── service_firestore.dart
    └── service_storage.dart
```

## Design

L'application utilise un design moderne avec :
- Palette de couleurs : dégradés violet-bleu et rose
- Typographie : Inter (corps de texte) et Poppins (titres)
- Effets visuels : glassmorphism, ombres, bordures en dégradé

## Auteur

Projet réalisé dans le cadre du cours de développement mobile à l'IMT.

## Licence

Projet Mikaël VIVIER
