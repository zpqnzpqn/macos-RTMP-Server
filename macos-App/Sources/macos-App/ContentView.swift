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
    
    @State private var isBreathing = false
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            Circle()
                .fill(statusColor.opacity(0.15))
                .blur(radius: 60)
                .frame(width: 300, height: 300)
                .offset(x: 100, y: -100)
                .animation(.easeInOut(duration: 2.0), value: statusColor)
            
            VStack(spacing: 20) {
                StatusBarView(
                    appState: appState,
                    showSettings: $showSettings,
                    isBreathing: $isBreathing,
                    statusColor: statusColor,
                    statusText: statusText
                )
                
                ServerDetailsCard(
                    appState: appState,
                    showQRCode: $showQRCode,
                    qrCodeUrl: $qrCodeUrl,
                    qrCodeTitle: $qrCodeTitle,
                    copiedRtmp: $copiedRtmp,
                    copiedHls: $copiedHls
                )
                
                StatusMonitorCard(
                    appState: appState,
                    showPreview: $showPreview
                )
                
                if let error = appState.errorMessage {
                    ErrorBannerView(error: error)
                }
                
                Spacer()
                
                FooterGuideView(language: appState.language)
            }
        }
        .frame(width: 460, height: 520)
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
    
    private var statusColor: Color {
        if appState.isStreaming { return .green }
        if appState.isServerRunning { return .blue }
        return .gray
    }
    
    private var statusText: String {
        if appState.isStreaming { return Localization.get("streaming", lang: appState.language) }
        if appState.isServerRunning { return Localization.get("serverRunning", lang: appState.language) }
        return Localization.get("serverStopped", lang: appState.language)
    }
}

// MARK: - Subcomponents

struct StatusBarView: View {
    @ObservedObject var appState: AppState
    @Binding var showSettings: Bool
    @Binding var isBreathing: Bool
    var statusColor: Color
    var statusText: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .shadow(color: statusColor.opacity(0.8), radius: isBreathing ? 4 : 1)
                    .scaleEffect(isBreathing ? 1.1 : 1.0)
                    .animation(appState.isServerRunning ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true) : .default, value: isBreathing)
                    .onAppear { isBreathing = true }
                
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Material.regular)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        if appState.isServerRunning { appState.stopServer() }
                        else { appState.startServer() }
                    }
                }) {
                    HStack {
                        Image(systemName: appState.isServerRunning ? "stop.fill" : "play.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.title3)
                        Text(appState.isServerRunning ? Localization.get("stopServer", lang: appState.language) : Localization.get("startServer", lang: appState.language))
                            .font(.body)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(appState.isServerRunning ? .red : .accentColor)
                .shadow(color: (appState.isServerRunning ? Color.red : Color.accentColor).opacity(0.3), radius: 4, y: 2)
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(8)
                .background(Material.regular)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

struct ServerDetailsCard: View {
    @ObservedObject var appState: AppState
    @Binding var showQRCode: Bool
    @Binding var qrCodeUrl: String
    @Binding var qrCodeTitle: String
    @Binding var copiedRtmp: Bool
    @Binding var copiedHls: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(Localization.get("rtmpPublishUrl", lang: appState.language))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if appState.rtmpURLs.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text(Localization.get("noNetwork", lang: appState.language))
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    ForEach(appState.rtmpURLs, id: \.self) { url in
                        HStack {
                            Text(url)
                                .font(.callout)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(url, forType: .string)
                                    withAnimation { copiedRtmp = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { copiedRtmp = false } }
                                }) {
                                    Image(systemName: copiedRtmp ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                        .symbolRenderingMode(copiedRtmp ? .multicolor : .hierarchical)
                                        .foregroundColor(copiedRtmp ? .green : .secondary)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: {
                                    qrCodeUrl = url
                                    qrCodeTitle = "RTMP URL"
                                    showQRCode = true
                                }) {
                                    Image(systemName: "qrcode")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.secondary)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(Localization.get("fixedStreamKey", lang: appState.language))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if appState.streamKeyType == "random" {
                        Button(action: {
                            withAnimation { appState.generateRandomKey() }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.2.circlepath")
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
                        .font(.callout)
                    
                    Spacer()
                    
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(appState.currentStreamKey, forType: .string)
                        withAnimation { copiedHls = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { copiedHls = false } }
                    }) {
                        Image(systemName: copiedHls ? "checkmark.circle.fill" : "doc.on.doc.fill")
                            .symbolRenderingMode(copiedHls ? .multicolor : .hierarchical)
                            .foregroundColor(copiedHls ? .green : .secondary)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(10)
            }
        }
        .padding(20)
        .background(Material.ultraThin)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
        .padding(.horizontal)
    }
}

struct StatusMonitorCard: View {
    @ObservedObject var appState: AppState
    @Binding var showPreview: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if appState.isStreaming {
                ActiveMonitorCard(appState: appState, showPreview: $showPreview)
            } else {
                IdleMonitorCard(appState: appState)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: appState.isStreaming)
    }
}

struct ActiveMonitorCard: View {
    @ObservedObject var appState: AppState
    @Binding var showPreview: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .symbolRenderingMode(.multicolor)
                    .font(.title2)
                Text(Localization.get("previewActive", lang: appState.language))
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text(Localization.get("streamName", lang: appState.language) + ":")
                    .foregroundColor(.secondary)
                Text(appState.activeStreamName)
                    .font(.body)
            }
            .font(.subheadline)
            
            Button(action: { showPreview.toggle() }) {
                HStack {
                    if showPreview {
                        Image(systemName: "eye.slash.fill")
                        Text(Localization.get("previewBtnStop", lang: appState.language))
                            .font(.body)
                    } else {
                        Image(systemName: "play.tv.fill")
                        Text(Localization.get("previewBtnStart", lang: appState.language))
                            .font(.body)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .shadow(color: Color.green.opacity(0.3), radius: 4, y: 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Material.ultraThin)
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: Color.green.opacity(0.15), radius: 15, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.3), lineWidth: 1))
    }
}

struct IdleMonitorCard: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "video.slash")
                .font(.system(size: 36))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(Localization.get("noLiveStreams", lang: appState.language))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(Localization.get("waiting", lang: appState.language))
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Material.ultraThin)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.05), lineWidth: 1))
    }
}

struct ErrorBannerView: View {
    var error: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.title2)
            Text(error)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(2)
            Spacer()
        }
        .padding(12)
        .background(Material.regular)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.yellow.opacity(0.5), lineWidth: 1))
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct FooterGuideView: View {
    var language: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(Localization.get("obsGuide", lang: language))
                .foregroundColor(.secondary)
            Link(Localization.get("obsGuideLink", lang: language), destination: URL(string: "https://obsproject.com/forum/resources/obs-mac-virtual-camera.1595/")!)
                .foregroundColor(.accentColor)
        }
        .font(.caption)
        .padding(.bottom, 20)
    }
}

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

struct QRCodeView: View {
    @Environment(\.dismiss) var dismiss
    var title: String
    var url: String
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(title)
                    .font(.title3)
                    .padding(.top, 10)
                
                if let qrImage = generateQRCode(from: url) {
                    Image(nsImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 220, height: 220)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                } else {
                    Text("Failed to generate QR Code")
                        .foregroundColor(.red)
                }
                
                Text(url)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineLimit(2)
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.body)
                        .frame(width: 100)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 10)
            }
            .padding()
        }
        .frame(width: 340, height: 420)
    }
    
    private func generateQRCode(from string: String) -> NSImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return NSImage(cgImage: cgImage, size: NSSize(width: 220, height: 220))
            }
        }
        return nil
    }
}


struct CustomVideoPlayer: NSViewRepresentable {
    var player: AVPlayer
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .floating
        view.videoGravity = .resizeAspect
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = player
    }
}

struct PreviewPlayerView: View {
    @Environment(\.dismiss) var dismiss
    var urlStr: String
    @State private var player: AVPlayer?
    @State private var isReady = false
    @State private var checkTimer: Timer?
    @State private var retries = 0
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
                .ignoresSafeArea()
                
            VStack(spacing: 20) {
                HStack {
                    Text("Live Preview")
                        .font(.title3)
                    Spacer()
                    Button(action: {
                        stopAndDismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
                
                if isReady, let player = player {
                    CustomVideoPlayer(player: player)
                        .frame(width: 440, height: 250)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 440, height: 250)
                        .cornerRadius(12)
                        .overlay(
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text(retries > 10 ? "Stream not responding..." : "Generating stream...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                Text(urlStr)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
        .frame(width: 480, height: 380)
        .onAppear {
            checkStreamAvailability()
        }
        .onDisappear {
            stopAndDismiss()
        }
    }
    
    private func checkStreamAvailability() {
        guard let url = URL(string: urlStr) else { return }
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            URLSession.shared.dataTask(with: request) { _, response, _ in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.checkTimer?.invalidate()
                        self.checkTimer = nil
                        let p = AVPlayer(url: url)
                        self.player = p
                        self.isReady = true
                        p.play()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.retries += 1
                        if self.retries > 20 {
                            self.checkTimer?.invalidate()
                        }
                    }
                }
            }.resume()
        }
    }
    
    private func stopAndDismiss() {
        checkTimer?.invalidate()
        checkTimer = nil
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        dismiss()
    }
}