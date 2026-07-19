import SwiftUI
import AVKit
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    @State private var showQRCode = false
    @State private var showPreview = false
    @State private var qrCodeUrl = ""
    @State private var qrCodeTitle = ""
    @State private var copiedRtmp = false
    @State private var copiedHls = false
    
    var body: some View {
        ZStack {
            // macOS Vibrant Background (MACOS27 style glassmorphism)
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header Status Bar
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 10, height: 10)
                            .shadow(color: statusColor, radius: 4)
                        
                        Text(statusText)
                            .font(.system(.subheadline, design: .rounded))
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    // Control Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            if appState.isServerRunning {
                                appState.stopServer()
                            } else {
                                appState.startServer()
                            }
                        }) {
                            HStack {
                                Image(systemName: appState.isServerRunning ? "stop.fill" : "play.fill")
                                Text(appState.isServerRunning ? Localization.get("stopServer", lang: appState.language) : Localization.get("startServer", lang: appState.language))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(appState.isServerRunning ? .red : .green)
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Server Details Card
                VStack(alignment: .leading, spacing: 14) {
                    // RTMP URL Row
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Localization.get("rtmpPublishUrl", lang: appState.language))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(appState.rtmpURL)
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Spacer()
                            
                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(appState.rtmpURL, forType: .string)
                                copiedRtmp = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    copiedRtmp = false
                                }
                            }) {
                                Image(systemName: copiedRtmp ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                    .foregroundColor(copiedRtmp ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                qrCodeUrl = appState.rtmpURL
                                qrCodeTitle = "RTMP URL"
                                showQRCode = true
                            }) {
                                Image(systemName: "qrcode")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(10)
                        .background(Color.black.opacity(0.15))
                        .cornerRadius(8)
                    }
                    
                    // Stream Key Row
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(Localization.get("fixedStreamKey", lang: appState.language))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            if appState.streamKeyType == "random" {
                                Button(action: {
                                    appState.generateRandomKey()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text(Localization.get("regenerate", lang: appState.language))
                                    }
                                    .font(.caption)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.accentColor)
                            }
                        }
                        
                        HStack {
                            Text(appState.currentStreamKey.isEmpty ? "—" : appState.currentStreamKey)
                                .font(.system(.body, design: .monospaced))
                                .bold()
                            
                            Spacer()
                            
                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(appState.currentStreamKey, forType: .string)
                                copiedHls = true // just generic copy check
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    copiedHls = false
                                }
                            }) {
                                Image(systemName: copiedHls ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                    .foregroundColor(copiedHls ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(10)
                        .background(Color.black.opacity(0.15))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Status Monitor / Stream Info View
                VStack(spacing: 12) {
                    if appState.isStreaming {
                        VStack(spacing: 8) {
                            Text(Localization.get("previewActive", lang: appState.language))
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            HStack {
                                Text("\(Localization.get("streamName", lang: appState.language)):")
                                    .foregroundColor(.secondary)
                                Text(appState.activeStreamName)
                                    .font(.system(.body, design: .monospaced))
                                    .bold()
                            }
                            .font(.subheadline)
                            
                            Button(action: {
                                showPreview.toggle()
                            }) {
                                HStack {
                                    Image(systemName: showPreview ? "eye.slash.fill" : "eye.fill")
                                    Text(showPreview ? Localization.get("previewBtnStop", lang: appState.language) : Localization.get("previewBtnStart", lang: appState.language))
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.08))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "video.slash")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text(Localization.get("noLiveStreams", lang: appState.language))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(Localization.get("waiting", lang: appState.language))
                                .font(.caption)
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Error Alert Banner
                if let error = appState.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Footer OBS Guide
                HStack(spacing: 4) {
                    Text(Localization.get("obsGuide", lang: appState.language))
                        .foregroundColor(.secondary)
                    Link(Localization.get("obsGuideLink", lang: appState.language), destination: URL(string: "https://obsproject.com/forum/resources/obs-mac-virtual-camera.1595/")!)
                        .foregroundColor(.accentColor)
                }
                .font(.caption)
                .padding(.bottom, 15)
            }
        }
        .frame(width: 480, height: 480)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showQRCode) {
            QRCodeView(title: qrCodeTitle, url: qrCodeUrl)
        }
        .sheet(isPresented: $showPreview) {
            PreviewPlayerView(urlStr: appState.hlsURL)
        }
    }
    
    // UI computed variables
    private var statusColor: Color {
        if appState.isStreaming { return .red }
        if appState.isServerRunning { return .green }
        return .gray
    }
    
    private var statusText: String {
        if appState.isStreaming { return Localization.get("streaming", lang: appState.language) }
        if appState.isServerRunning { return Localization.get("serverRunning", lang: appState.language) }
        return Localization.get("serverStopped", lang: appState.language)
    }
}

// SwiftUI NSVisualEffectView wrapper for premium glassmorphism
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// QR Code Sheet View
struct QRCodeView: View {
    @Environment(\.dismiss) var dismiss
    var title: String
    var url: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            if let qrImage = generateQRCode(from: url) {
                Image(nsImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } else {
                Text("Failed to generate QR Code")
                    .foregroundColor(.red)
            }
            
            Text(url)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineLimit(2)
            
            Button("OK") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .frame(width: 320, height: 380)
    }
    
    private func generateQRCode(from string: String) -> NSImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return NSImage(cgImage: cgImage, size: NSSize(width: 200, height: 200))
            }
        }
        return nil
    }
}

// HLS Stream Video Player View
struct PreviewPlayerView: View {
    @Environment(\.dismiss) var dismiss
    var urlStr: String
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Live Preview")
                    .font(.headline)
                Spacer()
                Button(action: {
                    player?.pause()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding([.top, .horizontal])
            
            if let player = player {
                VideoPlayer(player: player)
                    .frame(width: 440, height: 250)
                    .cornerRadius(10)
                    .onAppear {
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                VStack {
                    ProgressView()
                    Text("Loading Stream...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
                .frame(width: 440, height: 250)
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
            }
            
            Text(urlStr)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: 480, height: 350)
        .onAppear {
            if let url = URL(string: urlStr) {
                // Configure AVPlayer with quick startup params
                let asset = AVURLAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                // Minimizes HLS latency/buffering wait
                item.preferredForwardBufferDuration = 1.0
                let avPlayer = AVPlayer(playerItem: item)
                self.player = avPlayer
            }
        }
    }
}
