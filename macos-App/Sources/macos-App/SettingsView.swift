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
        VStack(spacing: 0) {
            // Title Bar
            HStack {
                Text(Localization.get("settings", lang: language))
                    .font(.headline)
                    .bold()
                Spacer()
            }
            .padding()
            .background(Color.primary.opacity(0.04))
            
            Divider()
            
            // Settings Form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Port Configuration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Port Configuration")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.accentColor)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("RTMP Port")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("", value: $rtmpPort, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("HTTP HLS Port")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("", value: $httpPort, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Key settings
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Localization.get("streamKeyType", lang: language))
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.accentColor)
                        
                        Picker("", selection: $streamKeyType) {
                            Text(Localization.get("random", lang: language)).tag("random")
                            Text(Localization.get("fixed", lang: language)).tag("fixed")
                        }
                        .pickerStyle(.radioGroup)
                        .horizontalRadioGroup() // custom helper
                        
                        if streamKeyType == "fixed" {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Localization.get("fixedStreamKey", lang: language))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("", text: $fixedStreamKey)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.top, 5)
                            .transition(.opacity)
                        }
                    }
                    
                    Divider()
                    
                    // Residence / Location settings
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Localization.get("appResidence", lang: language))
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.accentColor)
                        
                        Picker("", selection: $appMode) {
                            Text(Localization.get("menubar", lang: language)).tag("menubar")
                            Text(Localization.get("dock", lang: language)).tag("dock")
                        }
                        .pickerStyle(.radioGroup)
                    }
                    
                    Divider()
                    
                    // Language selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Localization.get("language", lang: language))
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.accentColor)
                        
                        Picker("", selection: $language) {
                            Text(Localization.get("systemLang", lang: language)).tag("system")
                            Text("English").tag("en")
                            Text("繁體中文").tag("zh")
                            Text("日本語").tag("ja")
                            Text("Español").tag("es")
                            Text("Français").tag("fr")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 200)
                    }
                    
                    Divider()
                    
                    // Launch at Login
                    Toggle("Launch at Login (Start Server automatically)", isOn: $launchAtLogin)
                        .toggleStyle(.checkbox)
                        .font(.subheadline)
                    
                }
                .padding()
            }
            
            Divider()
            
            // Bottom Action Buttons
            HStack(spacing: 12) {
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text(Localization.get("close", lang: language))
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    saveAndApply()
                }) {
                    Text(Localization.get("saveAndApply", lang: language))
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
            .padding()
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 440, height: 500)
        .onAppear {
            // Initialize local states from AppState
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
        
        // Stop server and restart it to apply new ports/keys
        if appState.isServerRunning {
            appState.stopServer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                appState.startServer()
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
