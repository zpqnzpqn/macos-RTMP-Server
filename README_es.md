# Local RTMP Server (macOS) v3.0

Un servidor RTMP nativo, ligero y de alto rendimiento para macOS. Construido con SwiftUI y Node Media Server, proporciona una manera sencilla de poner en marcha un servidor de transmisión en su red local, ideal para transmitir su pantalla, probar configuraciones de transmisión (como OBS) o enrutar señales de video en su red de área local.

## ✨ Novedades en v3.0

- **Interfaz nativa de macOS**: Totalmente reescrito en Swift y SwiftUI. Disfrute de una interfaz nativa hermosa, moderna y extremadamente fluida con efectos de cristal translúcido (macOS 13+).
- **Soporte dinámico para múltiples IPs**: Detecta automáticamente y muestra todas las interfaces de red IPv4 activas en su máquina. Puede ver y copiar al instante las URLs RTMP exactas para diferentes redes (Wi-Fi, Ethernet).
- **Vista previa en vivo HLS**: Ventana de vista previa nativa integrada sin latencia mediante AVPlayer. Al iniciar la transmisión desde OBS, puede monitorear su señal instantáneamente dentro de la aplicación.
- **Motor de configuración inteligente**: Cambie su clave de transmisión o puertos de forma segura sobre la marcha. Si actualmente está transmitiendo, el servidor retrasará de forma inteligente el reinicio de la red hasta que finalice su transmisión, evitando desconexiones accidentales.
- **Modos de Barra de menús y Dock**: Ejecute el servidor silenciosamente en segundo plano desde su barra de menús o manténgalo en su Dock como una aplicación estándar.
- **Inicio automático**: Configure opcionalmente el servidor para que se inicie automáticamente y comience a alojar el servidor RTMP al arrancar el sistema.
- **Soporte multilingüe**: Totalmente localizado en inglés, chino tradicional (繁體中文), japonés (日本語), español (Español) y francés (Français).

## 🚀 Instalación

1. Descargue el último archivo `Local RTMP Server 3.0.dmg` desde la página de Releases.
2. Haga doble clic en el archivo DMG para montarlo.
3. Arrastre el ícono de la aplicación **Local RTMP Server** a la carpeta de **Aplicaciones (Applications)**.
4. Inicie la aplicación desde Launchpad o la carpeta de Aplicaciones.

> **Nota**: Si macOS muestra una advertencia de seguridad indicando que no puede abrir una aplicación de un desarrollador no identificado, vaya a **Configuración del Sistema > Privacidad y seguridad** y haga clic en **Abrir de todos modos**.

## 📖 Instrucciones de uso

1. **Iniciar el servidor**: Haga clic en el botón de reproducción (Play) en la aplicación. La luz de estado se pondrá verde.
2. **Copiar la URL de RTMP**: La aplicación mostrará sus direcciones IP locales. Copie la URL (por ejemplo: `rtmp://192.168.1.100/live/mystreamkey`).
3. **Configurar OBS**:
   - Vaya a Configuración de OBS -> Emisión.
   - Servicio: `Personalizado (Custom)`
   - Servidor: `rtmp://192.168.1.100/live`
   - Clave de retransmisión: `mystreamkey`
4. **Comenzar a transmitir**: Haga clic en "Iniciar transmisión" en OBS.
5. **Vista previa**: Haga clic en el botón "Vista previa en vivo" en la aplicación para monitorear su transmisión en tiempo real.

## 🛠 Configuración avanzada
Presione `Cmd + ,` o haga clic en el ícono del engranaje para abrir la Configuración.
- **Tipo de clave de transmisión**: Elija entre una clave fija y fácil de recordar, o deje que la aplicación genere automáticamente una clave aleatoria segura cada vez.
- **Puertos personalizados**: Cambie el puerto RTMP predeterminado (1935) o el puerto HTTP HLS (8000) si entran en conflicto con otros servicios.
- **Modo de visualización de la aplicación**: Alterne entre ejecutar la aplicación completamente en segundo plano (modo Barra de menús) o como una aplicación estándar en su Dock.

## ⚖️ Licencia y créditos

Partes de este software se derivan o están inspiradas en los siguientes proyectos de código abierto, utilizados bajo la Licencia MIT:

1. [mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) por Sallar Kaboli (Copyright (c) 2018)
2. [macos-RTMP-Server](https://github.com/zpqnzpqn/macos-RTMP-Server) por zpqnzpqn (Copyright (c) 2026)

Este proyecto está bajo la Licencia MIT.
