import SwiftUI
import AppKit
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaults = UserDefaults.standard
        let mode = defaults.string(forKey: "appMode") ?? "menubar"
        
        if mode == "menubar" {
            // Hide the main window if in menubar mode
            for window in NSApplication.shared.windows {
                if window.title == "Local RTMP Server" || window.title == "" {
                    window.close()
                }
            }
        }
        
        let event = NSAppleEventManager.shared().currentAppleEvent
        let isAutoDown = event?.eventID == kAEOpenApplication && event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == 1635087460
        
        if !isAutoDown {
            appState.startServer()
        }
    }
}

@main
struct LocalRTMPServerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
                .environmentObject(appDelegate.appState)
                .onDisappear {
                    // Quit app when window closed if running in dock mode
                    if appDelegate.appState.appMode == "dock" {
                        appDelegate.appState.stopServer()
                        NSApplication.shared.terminate(nil)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        
        // Menu Bar Extra (displays custom popover view)
        MenuBarExtra {
            VStack(spacing: 0) {
                ContentView()
                    .environmentObject(appDelegate.appState)
                
                Divider()
                
                HStack {
                    Spacer()
                    Button("Quit") {
                        appDelegate.appState.stopServer()
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
            Image(systemName: appDelegate.appState.isStreaming ? "video.circle.fill" : "video.circle")
        }
        .menuBarExtraStyle(.window)
    }
}
