# Serveur RTMP local pour macOS (Apple Silicon)

Un serveur de diffusion RTMP natif et léger pour macOS, conçu spécifiquement pour les Mac **Apple Silicon (M1/M2/M3/M4)**. Diffusez depuis OBS, des appareils mobiles ou toute source compatible RTMP vers votre machine locale.

> **Note sur le Fork :** Il s'agit d'un fork activement maintenu de [sallar/mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) (archivé), reconstruit pour Apple Silicon avec de nouvelles fonctionnalités et des corrections de bugs.

[English](README.md) | [繁體中文](README_zh-TW.md) | [日本語](README_ja.md) | [Español](README_es.md) | **Français**

## ✨ Fonctionnalités

- **Support natif Apple Silicon** — Fonctionne nativement sur les Mac M1/M2/M3/M4 (ARM64)
- **Serveur RTMP en un clic** — Lancez instantanément un serveur RTMP local sur le port 1935
- **Détection automatique des adresses IP** — Découvre automatiquement toutes les adresses IPv4 locales (Wi-Fi, Ethernet, etc.) et affiche les URL RTMP complètes prêtes à copier
- **Gestion de la clé de flux** — Choisissez entre des clés de flux aléatoires (générées automatiquement) ou fixes personnalisées
- **Aperçu HLS en direct** — Prévisualisez les flux actifs directement dans l'application à l'aide du lecteur HLS intégré
- **Mode Barre des menus ou Dock** — Exécutez l'application en tant qu'icône légère dans la barre des menus ou sous forme de fenêtre standard dans le Dock
- **Support multi-flux** — Gérez plusieurs flux RTMP simultanés
- **Informations en temps réel sur le flux** — Affichez le codec, la résolution, la fréquence d'images, le trafic et le nombre de clients pour chaque flux actif

## 📋 Prérequis

- **macOS** 11.0 (Big Sur) ou version ultérieure
- **Apple Silicon** Mac (M1/M2/M3/M4) — ou Mac Intel avec Rosetta
- **FFmpeg** (requis pour le transcodage HLS)

### Installer FFmpeg

```bash
brew install ffmpeg
```

## 📦 Installation

### Option 1 : Télécharger le DMG (Recommandé)

1. Téléchargez le dernier fichier `.dmg` depuis la page des [Releases](https://github.com/zpqnzpqn/macos-RTMP-Server/releases).
2. Ouvrez le DMG et glissez-déposez l'application dans votre dossier Applications.
3. Lancez **Local RTMP Server**.

> **Note :** L'application n'étant pas signée, vous devrez peut-être faire un clic droit → Ouvrir lors du premier lancement, ou aller dans Réglages Système → Confidentialité et sécurité → Ouvrir quand même.

### Option 2 : Build depuis les sources

```bash
git clone https://github.com/zpqnzpqn/macos-RTMP-Server.git
cd macos-RTMP-Server
npm install
npm start        # Exécuter en mode développement
npm run dist     # Créer le DMG pour ARM64
```

## 🚀 Utilisation

### Diffusion de base

1. Lancez l'application — elle démarrera automatiquement le serveur RTMP sur le port `1935`.
2. Copiez l'une des URL RTMP affichées (par exemple, `rtmp://192.168.1.100/live/abc123`).
3. Dans votre logiciel de diffusion (OBS, Streamlabs, etc.) :
   - Configurez le **Serveur** avec l'URL copiée
   - Aucune clé de flux séparée n'est nécessaire — elle est déjà incluse dans l'URL
4. Lancez la diffusion — l'application affichera les statistiques du flux en temps réel.

### Diffusion depuis un autre appareil

Pour diffuser depuis un autre appareil sur le même réseau (par exemple, un téléphone avec [Larix Broadcaster](https://wmspanel.com/larix_broadcaster)) :

1. Utilisez l'URL RTMP contenant l'adresse IP locale de votre Mac (affichée dans l'application).
2. Assurez-vous que les deux appareils sont sur le même réseau Wi-Fi/LAN.

### Prévisualiser un flux

Cliquez sur le bouton **Aperçu du flux (Stream Preview)** pour visionner le flux HLS en direct directement dans l'application.

### Caméra virtuelle (via OBS)

Si vous devez utiliser le flux RTMP comme webcam virtuelle dans des applications comme Zoom ou Google Meet :

1. Ouvrez **OBS Studio** ([télécharger ici](https://obsproject.com/))
2. Ajoutez une **Source média** → Entrez l'URL RTMP
3. Cliquez sur **Démarrer la caméra virtuelle** dans OBS
4. Dans Zoom/Meet, sélectionnez **OBS Virtual Camera** comme caméra

L'application comprend un lien direct vers le [Guide de la caméra virtuelle OBS](https://obsproject.com/kb/virtual-camera-guide) en bas de l'interface.

## ⚙️ Paramètres

Cliquez sur l'**icône d'engrenage** (⚙️) pour accéder aux paramètres :

| Paramètre | Options | Description |
|-----------|---------|-------------|
| Clé de flux | Aléatoire / Fixe | Aléatoire génère une nouvelle clé à chaque lancement ; Fixe vous permet de définir une clé persistante |
| Emplacement de l'application | Barre des menus / Dock | Choisissez où l'application apparaît — barre des menus ou fenêtre standard dans le Dock |
| Langue | Par défaut du système / Anglais / Chinois traditionnel / Japonais / Espagnol / Français | Modifie la langue d'affichage de l'interface |

> Modifier l'emplacement de l'application ou la langue nécessite un redémarrage de l'application (géré automatiquement lors de l'enregistrement).

## 🔒 Notes de sécurité

- **Réseau local uniquement** — Le serveur RTMP est conçu pour être utilisé exclusivement sur des réseaux locaux de confiance. Il n'y a pas d'authentification sur le port RTMP.
- **Pas d'exposition à Internet** — N'exposez pas le port 1935 à Internet sans mesures de sécurité supplémentaires (pare-feu, VPN, etc.).
- **Clés de flux** — Les clés de flux fournissent une identification de base du flux mais ne constituent pas un mécanisme de sécurité. Toute personne sur le même réseau peut s'y connecter si elle connaît l'URL.

## 🛠 Détails techniques

| Composant | Technologie |
|-----------|-------------|
| Framework | Electron 30 |
| Moteur RTMP | Node-Media-Server |
| Transcodage | FFmpeg (HLS) |
| Interface | HTML/CSS/JS natif |
| Plateforme | macOS ARM64 (Apple Silicon) |

## 📝 Journal des modifications

### v2.0.0 (Actuelle)
- ✅ Porté nativement sur Apple Silicon (ARM64)
- ✅ Electron mis à jour vers v30, electron-builder vers v24
- ✅ Détection automatique de toutes les IP réseau locales
- ✅ Affichage des URL RTMP complètes (IP + clé de flux combinées)
- ✅ Ajout de la gestion de la clé de flux (aléatoire/fixe)
- ✅ Ajout de la sélection du mode Barre des menus / Dock
- ✅ Ajout de l'aperçu du flux HLS en direct
- ✅ Ajout du guide de la caméra virtuelle OBS
- ✅ Correction de plusieurs bugs de code et fuites de mémoire
- ✅ Sécurité renforcée (restrictions CORS)
- ✅ Correction des problèmes de compatibilité avec node-media-server

## 📄 Licence

Ce projet est publié sous la [Licence MIT](LICENSE).

Créé à l'origine par [Sallar Kaboli](https://github.com/sallar). Ce fork est maintenu indépendamment avec le support d'Apple Silicon et des fonctionnalités supplémentaires.

## 🔗 Ressources connexes

- [OBS Studio](https://obsproject.com/) — Logiciel libre d'enregistrement et de diffusion
- [Guide de la caméra virtuelle OBS](https://obsproject.com/kb/virtual-camera-guide) — Utiliser OBS comme webcam virtuelle
- [Larix Broadcaster](https://wmspanel.com/larix_broadcaster) — Application mobile de diffusion RTMP
- [VLC Media Player](https://www.videolan.org/) — Lire les flux RTMP avec l'URL `rtmp://`
