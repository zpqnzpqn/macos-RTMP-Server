import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // Local copy of states for editing
    @State private var streamKeyType: String = "random"
    @State private var fixedStreamKey: String = ""
    @State private var appMode: String = "menubar"
    @State private var language: String = "system"
    @State private var rtmpPort: Int = 1935
    @State private var httpPort: Int = 8000
    @State private var launchAtLogin: Bool = false
    
    var body: some View {
        ZStack {
            // Modern macOS glass background
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title Bar
                HStack {
                    Image(systemName: "gearshape.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                        .font(.title2)
                    Text(Localization.get("settings", lang: language))
                        .font(.headline)
                                        
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Material.ultraThin)
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                
                // Settings Form
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Port Configuration
                        GroupBox {
                            HStack(spacing: 30) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label("RTMP Port", systemImage: "network")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("", value: $rtmpPort, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 120)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Label("HTTP HLS Port", systemImage: "play.tv")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("", value: $httpPort, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 120)
                                }
                                Spacer()
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        } label: {
                            Text("Port Configuration")
                                .font(.subheadline)
                                        
                                .foregroundColor(.accentColor)
                        }
                        
                        // Key settings
                        GroupBox {
                            VStack(alignment: .leading, spacing: 12) {
                                Picker("", selection: $streamKeyType) {
                                    Text(Localization.get("random", lang: language)).tag("random")
                                    Text(Localization.get("fixed", lang: language)).tag("fixed")
                                }
                                .pickerStyle(.radioGroup)
                                .horizontalRadioGroup() // custom helper
                                .onChange(of: streamKeyType) { newValue in
                                    if newValue == "fixed" && fixedStreamKey.isEmpty {
                                        fixedStreamKey = UUID().uuidString.prefix(8).lowercased()
                                    }
                                }
                                
                                if streamKeyType == "fixed" {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Label(Localization.get("fixedStreamKey", lang: language), systemImage: "key.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        HStack {
                                            TextField("", text: $fixedStreamKey)
                                                .textFieldStyle(.roundedBorder)
                                                .frame(maxWidth: .infinity)
                                            Button(action: {
                                                withAnimation {
                                                    fixedStreamKey = UUID().uuidString.prefix(8).lowercased()
                                                }
                                            }) {
                                                Image(systemName: "arrow.2.circlepath")
                                                Text(Localization.get("regenerate", lang: language))
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                    .padding(.top, 8)
                                    .transition(.opacity)
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        } label: {
                            Text(Localization.get("streamKeyType", lang: language))
                                .font(.subheadline)
                                        
                                .foregroundColor(.accentColor)
                        }
                        
                        // Appearance & Behavior
                        GroupBox {
                            VStack(alignment: .leading, spacing: 16) {
                                // App Mode
                                VStack(alignment: .leading, spacing: 6) {
                                    Label(Localization.get("appResidence", lang: language), systemImage: "macwindow")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Picker("", selection: $appMode) {
                                        Text(Localization.get("menubar", lang: language)).tag("menubar")
                                        Text(Localization.get("dock", lang: language)).tag("dock")
                                    }
                                    .pickerStyle(.radioGroup)
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                // Language
                                VStack(alignment: .leading, spacing: 6) {
                                    Label(Localization.get("language", lang: language), systemImage: "globe")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Picker("", selection: $language) {
                                        Text(Localization.get("systemLang", lang: language)).tag("system")
                                        Text("English").tag("en")
                                        Text("繁體中文").tag("zh")
                                        Text("日本語").tag("ja")
                                        Text("Español").tag("es")
                                        Text("Français").tag("fr")
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 220)
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                // Launch at Login
                                Toggle("Launch at Login (Start Server automatically)", isOn: $launchAtLogin)
                                    .toggleStyle(.checkbox)
                                    .font(.subheadline)
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        } label: {
                            Text("Application Behavior")
                                .font(.subheadline)
                                        
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(24)
                }
                
                // Bottom Action Buttons & About
                VStack(spacing: 16) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text(Localization.get("close", lang: language))
                                .font(.body)
                                        
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button(action: {
                            saveAndApply()
                        }) {
                            Text(Localization.get("saveAndApply", lang: language))
                                .font(.body)
                                        
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                    .padding(.horizontal, 24)
                    
                    // About & Copyright Section
                    VStack(alignment: .center, spacing: 4) {
                        Text("Local RTMP Server v3.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            Text("""
Portions of this software are derived from and inspired by the following open-source projects, used under the MIT License:

1. mac-local-rtmp-server
Copyright (c) 2018 Sallar Kaboli
Source: https://github.com/sallar/mac-local-rtmp-server

2. macos-RTMP-Server
Copyright (c) 2026 zpqnzpqn
Source: https://github.com/zpqnzpqn/macos-RTMP-Server

MIT License 全文 (以下條款必須完整保留)：
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
""")
                                .font(.system(size: 9, design: .rounded))
                                .foregroundColor(.secondary.opacity(0.7))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 24)
                        }
                        .frame(height: 80)
                    }
                    .padding(.bottom, 16)
                }
                .background(Material.ultraThin)
            }
        }
        .frame(width: 480, height: 600)
        .onAppear {
            streamKeyType = appState.streamKeyType
            fixedStreamKey = appState.fixedStreamKey
            appMode = appState.appMode
            language = appState.language
            rtmpPort = appState.rtmpPort
            httpPort = appState.httpPort
            launchAtLogin = appState.launchAtLogin
        }
    }
    
    private func saveAndApply() {
        appState.streamKeyType = streamKeyType
        appState.fixedStreamKey = fixedStreamKey
        appState.appMode = appMode
        appState.language = language
        appState.rtmpPort = rtmpPort
        appState.httpPort = httpPort
        appState.launchAtLogin = launchAtLogin
        
        // Save settings to UserDefaults
        appState.saveSettings()
        
        // Update dock/menubar mode dynamically
        updateActivationPolicy(mode: appMode)
        
        // Stop server and restart it to apply new ports/keys (skip if currently streaming)
        if appState.isServerRunning && !appState.isStreaming {
            appState.stopServer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.appState.startServer()
            }
        }
        
        dismiss()
    }
    
    private func updateActivationPolicy(mode: String) {
        DispatchQueue.main.async {
            if mode == "menubar" {
                NSApp.setActivationPolicy(.accessory)
            } else {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

// SwiftUI picker horizontal layout extension helper
extension View {
    func horizontalRadioGroup() -> some View {
        #if os(macOS)
        return self.pickerStyle(.radioGroup)
        #else
        return self
        #endif
    }
}
