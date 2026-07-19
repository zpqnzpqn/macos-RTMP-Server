# Servidor RTMP local para macOS (Apple Silicon)

Un servidor de transmisión RTMP nativo y ligero para macOS, diseñado específicamente para Macs con **Apple Silicon (M1/M2/M3/M4)**. Transmita desde OBS, dispositivos móviles o cualquier fuente compatible con RTMP a su máquina local.

> **Nota sobre el Fork:** Este es un fork activamente mantenido de [sallar/mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) (archivado), reconstruido para Apple Silicon con nuevas funciones y correcciones de errores.

[English](README.md) | [繁體中文](README_zh-TW.md) | [日本語](README_ja.md) | **Español** | [Français](README_fr.md)

## ✨ Características

- **Soporte nativo de Apple Silicon** — Funciona de forma nativa en Macs con M1/M2/M3/M4 (ARM64)
- **Servidor RTMP con un solo clic** — Inicie un servidor RTMP local instantáneamente en el puerto 1935
- **Autodetección de IPs de red** — Descubre automáticamente todas las direcciones IPv4 locales (Wi-Fi, Ethernet, etc.) y muestra URLs de RTMP completas listas para copiar
- **Gestión de claves de transmisión** — Elija entre claves de transmisión aleatorias (generadas automáticamente) o fijas personalizadas
- **Vista previa en vivo HLS** — Previsualice las transmisiones activas directamente dentro de la aplicación mediante el reproductor HLS integrado
- **Modo Barra de menú o Dock** — Ejecútelo como una aplicación ligera en la barra de menú o como una aplicación estándar de Dock
- **Soporte de transmisión múltiple** — Maneje múltiples transmisiones RTMP simultáneas
- **Información de transmisión en tiempo real** — Ver códec, resolución, velocidad de fotogramas, tráfico y recuento de clientes para cada transmisión activa

## 📋 Requisitos

- **macOS** 11.0 (Big Sur) o posterior
- **Apple Silicon** Mac (M1/M2/M3/M4) — o Mac Intel con Rosetta
- **FFmpeg** (requerido para la transcodificación HLS)

### Instalar FFmpeg

```bash
brew install ffmpeg
```

## 📦 Instalación

### Opción 1: Descargar DMG (Recomendado)

1. Descargue el último `.dmg` de la página de [Lanzamientos](https://github.com/zpqnzpqn/Local-RTMP-Server/releases).
2. Abra el DMG y arrastre la aplicación a su carpeta de Aplicaciones.
3. Inicie **Local RTMP Server**.

> **Nota:** Dado que la aplicación no está firmada con código, es posible que deba hacer clic derecho → Abrir en el primer lanzamiento, o ir a Ajustes del sistema → Privacidad y seguridad → Abrir de todos modos.

### Opción 2: Construir desde el código fuente

```bash
git clone https://github.com/zpqnzpqn/Local-RTMP-Server.git
cd Local-RTMP-Server
npm install
npm start        # Ejecutar en modo de desarrollo
npm run dist     # Construir DMG para ARM64
```

## 🚀 Uso

### Transmisión básica

1. Inicie la aplicación — comenzará el servidor RTMP automáticamente en el puerto `1935`.
2. Copie una de las URLs de RTMP mostradas (por ejemplo, `rtmp://192.168.1.100/live/abc123`).
3. En su software de transmisión (OBS, Streamlabs, etc.):
   - Establezca **Servidor** a la URL copiada
   - No se necesita una clave de transmisión separada — ya está incluida en la URL
4. Inicie la transmisión — la aplicación mostrará estadísticas de la transmisión en tiempo real.

### Transmisión desde otro dispositivo

Para transmitir desde otro dispositivo en la misma red (por ejemplo, un teléfono usando [Larix Broadcaster](https://wmspanel.com/larix_broadcaster)):

1. Use la URL de RTMP con la dirección IP local de su Mac (mostrada en la aplicación).
2. Asegúrese de que ambos dispositivos estén en la misma red Wi-Fi/LAN.

### Previsualizar una transmisión

Haga clic en el botón **Vista previa (Stream Preview)** para ver la transmisión HLS en vivo directamente en la aplicación.

### Cámara virtual (a través de OBS)

Si necesita usar la transmisión RTMP como una cámara web virtual en aplicaciones como Zoom o Google Meet:

1. Abra **OBS Studio** ([descárguelo aquí](https://obsproject.com/))
2. Añada una **Fuente de medios** → Ingrese la URL de RTMP
3. Haga clic en **Iniciar cámara virtual** en OBS
4. En Zoom/Meet, seleccione **OBS Virtual Camera** como su cámara

La aplicación incluye un enlace directo a la [Guía de cámara virtual de OBS](https://obsproject.com/kb/virtual-camera-guide) en la parte inferior de la interfaz.

## ⚙️ Configuración

Haga clic en el **icono de engranaje** (⚙️) para acceder a la configuración:

| Configuración | Opciones | Descripción |
|---------------|----------|-------------|
| Clave de transmisión | Aleatoria / Fija | Aleatoria genera una nueva clave en cada inicio; Fija le permite establecer una clave persistente |
| Ubicación de la aplicación | Barra de menú / Dock | Elija dónde aparece la aplicación — icono ligero en la barra de menú o ventana estándar de Dock |
| Idioma | Predeterminado del sistema / Inglés / Chino tradicional / Japonés / Español / Francés | Cambia el idioma de visualización de la interfaz |

> Cambiar el modo de ubicación de la aplicación o el idioma requiere reiniciar la aplicación (se maneja automáticamente al guardar).

## 🔒 Notas de seguridad

- **Solo red local** — El servidor RTMP está destinado a ser utilizado únicamente en redes locales de confianza. No hay autenticación en el puerto RTMP.
- **Sin exposición a Internet** — No exponga el puerto 1935 a Internet sin medidas de seguridad adicionales (cortafuegos, VPN, etc.).
- **Claves de transmisión** — Las claves de transmisión proporcionan una identificación básica de la transmisión, pero no son un mecanismo de seguridad. Cualquier persona en la misma red puede conectarse si conoce la URL.

## 🛠 Detalles técnicos

| Componente | Tecnología |
|------------|------------|
| Framework | Electron 30 |
| Motor RTMP | Node-Media-Server |
| Transcodificación | FFmpeg (HLS) |
| Interfaz de usuario | HTML/CSS/JS nativo |
| Plataforma | macOS ARM64 (Apple Silicon) |

## 📝 Historial de cambios

### v2.0.0 (Actual)
- ✅ Portado a Apple Silicon (ARM64) de forma nativa
- ✅ Electron actualizado a v30, electron-builder a v24
- ✅ Autodetección de todas las IPs locales
- ✅ Visualización de URLs RTMP completas (IP + clave de transmisión combinadas)
- ✅ Añadida la gestión de claves de transmisión (aleatoria/fija)
- ✅ Añadida la selección del modo Barra de menú / Dock
- ✅ Añadida la vista previa de transmisión en vivo HLS
- ✅ Añadida la guía de cámara virtual OBS
- ✅ Corregidos múltiples errores de código y fugas de memoria
- ✅ Seguridad mejorada (restricciones de CORS)
- ✅ Parcheados problemas de compatibilidad de node-media-server

## 📄 Licencia

Este proyecto está bajo la [Licencia MIT](LICENSE).

Creado originalmente por [Sallar Kaboli](https://github.com/sallar). Este fork es mantenido de forma independiente con soporte para Apple Silicon y características adicionales.

## 🔗 Recursos relacionados

- [OBS Studio](https://obsproject.com/) — Software de grabación y transmisión de código abierto
- [Guía de cámara virtual de OBS](https://obsproject.com/kb/virtual-camera-guide) — Use OBS como una cámara web virtual
- [Larix Broadcaster](https://wmspanel.com/larix_broadcaster) — Aplicación móvil de transmisión RTMP
- [VLC Media Player](https://www.videolan.org/) — Reproduzca transmisiones RTMP con la URL `rtmp://`
