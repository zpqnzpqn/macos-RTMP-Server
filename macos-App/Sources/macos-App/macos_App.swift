import SwiftUI
import AppKit

@main
struct LocalRTMPServerApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Set the activation policy on start based on saved settings
        let defaults = UserDefaults.standard
        let mode = defaults.string(forKey: "appMode") ?? "menubar"
        DispatchQueue.main.async {
            if mode == "menubar" {
                NSApp.setActivationPolicy(.accessory)
            } else {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    var body: some Scene {
        // Main window
        Window("Local RTMP Server", id: "main") {
            ContentView()
                .environmentObject(appState)
                .onDisappear {
                    // Quit app when window closed if running in dock mode
                    if appState.appMode == "dock" {
                        appState.stopServer()
                        NSApplication.shared.terminate(nil)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        
        // Menu Bar Extra (displays custom popover view)
        MenuBarExtra {
            VStack(spacing: 0) {
                ContentView()
                    .environmentObject(appState)
                
                Divider()
                
                HStack {
                    Spacer()
                    Button("Quit") {
                        appState.stopServer()
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.primary.opacity(0.04))
            }
            .frame(width: 480, height: 530)
        } label: {
            Image(systemName: appState.isStreaming ? "video.circle.fill" : "video.circle")
        }
        .menuBarExtraStyle(.window)
    }
}
