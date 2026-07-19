# Local RTMP Server (macOS) v3.0

Un serveur RTMP natif, léger et performant spécialement conçu pour macOS. Construit avec SwiftUI et Node Media Server, il offre un moyen transparent de lancer un serveur de streaming sur votre réseau local, idéal pour diffuser votre écran, tester des configurations de streaming (comme OBS) ou router des flux vidéo sur votre réseau local.

## ✨ Nouveautés de la v3.0

- **Interface native macOS** : Entièrement réécrit en Swift et SwiftUI. Profitez d'une interface native magnifique, moderne et extrêmement fluide avec des effets de verre dépoli (macOS 13+).
- **Prise en charge IP dynamique multiple** : Détecte et affiche automatiquement toutes les interfaces réseau IPv4 actives sur votre machine. Vous pouvez voir et copier instantanément les URL RTMP exactes pour différents réseaux (Wi-Fi, Ethernet).
- **Aperçu en direct HLS** : Fenêtre d'aperçu native intégrée sans latence via AVPlayer. Lorsque vous démarrez le streaming depuis OBS, vous pouvez surveiller votre flux instantanément dans l'application.
- **Moteur de paramètres intelligent** : Modifiez votre clé de flux ou vos ports en toute sécurité à la volée. Si vous êtes en train de streamer, le serveur retardera intelligemment le redémarrage du réseau jusqu'à la fin de votre diffusion, évitant ainsi les déconnexions accidentelles.
- **Modes Barre des menus et Dock** : Exécutez le serveur silencieusement en arrière-plan depuis votre barre des menus, ou gardez-le dans votre Dock comme une application standard.
- **Démarrage automatique** : Configurez en option le serveur pour qu'il se lance automatiquement et héberge le serveur RTMP au démarrage du système.
- **Support multilingue** : Entièrement traduit en anglais, chinois traditionnel (繁體中文), japonais (日本語), espagnol (Español) et français (Français).

## 🚀 Installation

1. Téléchargez le dernier fichier `Local RTMP Server 3.0.dmg` depuis la page Releases.
2. Double-cliquez sur le fichier DMG pour le monter.
3. Faites glisser l'icône de l'application **Local RTMP Server** dans le dossier **Applications**.
4. Lancez l'application depuis Launchpad ou le dossier Applications.

> **Remarque** : Si macOS affiche un avertissement de sécurité indiquant qu'il ne peut pas ouvrir une application provenant d'un développeur non identifié, accédez à **Réglages Système > Confidentialité et sécurité** et cliquez sur **Ouvrir quand même**.

## 📖 Mode d'emploi

1. **Démarrer le serveur** : Cliquez sur le bouton de lecture (Play) dans l'application. Le voyant d'état deviendra vert.
2. **Copier l'URL RTMP** : L'application affichera vos adresses IP locales. Copiez l'URL (par exemple : `rtmp://192.168.1.100/live/mystreamkey`).
3. **Configurer OBS** :
   - Allez dans les Paramètres d'OBS -> Flux.
   - Service : `Personnalisé (Custom)`
   - Serveur : `rtmp://192.168.1.100/live`
   - Clé de flux : `mystreamkey`
4. **Commencer le streaming** : Cliquez sur « Commencer le streaming » dans OBS.
5. **Aperçu** : Cliquez sur le bouton « Aperçu en direct » dans l'application pour surveiller votre flux en temps réel.

## 🛠 Paramètres avancés
Appuyez sur `Cmd + ,` ou cliquez sur l'icône d'engrenage pour ouvrir les Paramètres.
- **Type de clé de flux** : Choisissez entre une clé fixe facile à mémoriser, ou laissez l'application générer automatiquement une clé aléatoire sécurisée à chaque fois.
- **Ports personnalisés** : Modifiez le port RTMP par défaut (1935) ou le port HTTP HLS (8000) s'ils entrent en conflit avec d'autres services.
- **Mode d'affichage de l'application** : Basculez entre l'exécution de l'application entièrement en arrière-plan (mode Barre des menus) ou comme une application standard dans votre Dock.

## ⚖️ Licence et crédits

Certaines parties de ce logiciel sont dérivées ou inspirées des projets open source suivants, utilisés sous la licence MIT :

1. [mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) par Sallar Kaboli (Copyright (c) 2018)
2. [macos-RTMP-Server](https://github.com/zpqnzpqn/macos-RTMP-Server) par zpqnzpqn (Copyright (c) 2026)

Ce projet est sous licence MIT.
