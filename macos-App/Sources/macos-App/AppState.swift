import Foundation
import ServiceManagement
import SwiftUI
import Combine
@preconcurrency import UserNotifications

@MainActor
class AppState: ObservableObject {
    @Published var streamKeyType: String = "random" { didSet { saveSettings() } }
    @Published var fixedStreamKey: String = "mystreamkey" { didSet { saveSettings() } }
    @Published var randomStreamKey: String = ""
    @Published var appMode: String = "menubar" { didSet { saveSettings() } }
    @Published var language: String = "system" { didSet { saveSettings() } }
    @Published var rtmpPort: Int = 1935 { didSet { saveSettings() } }
    @Published var httpPort: Int = 8000 { didSet { saveSettings() } }
    @Published var launchAtLogin: Bool = false { didSet { saveSettings(); updateLaunchAtLogin(enabled: launchAtLogin) } }
    
    @Published var isServerRunning: Bool = false
    @Published var isStreaming: Bool = false
    @Published var errorMessage: String? = nil
    @Published var activeStreamName: String = ""
    
    private var process: Process?
    private var stdoutPipe: Pipe?
    private var stdinPipe: Pipe?
    private var outputQueue = DispatchQueue(label: "com.localrtmp.server.output")
    
    init() {
        loadSettings()
        generateRandomKey()
    }
    
    func generateRandomKey() {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        randomStreamKey = String((0..<8).map { _ in chars.randomElement()! })
    }
    
    var currentStreamKey: String {
        return streamKeyType == "fixed" ? fixedStreamKey : randomStreamKey
    }
    
    var rtmpURL: String {
        let portStr = rtmpPort == 1935 ? "" : ":\(rtmpPort)"
        return "rtmp://127.0.0.1\(portStr)/live/\(currentStreamKey)"
    }
    
    var hlsURL: String {
        return "http://127.0.0.1:\(httpPort)/live/\(currentStreamKey)/index.m3u8"
    }
    
    // Load Settings from UserDefaults
    func loadSettings() {
        let defaults = UserDefaults.standard
        if let type = defaults.string(forKey: "streamKeyType") { streamKeyType = type }
        if let key = defaults.string(forKey: "fixedStreamKey") { fixedStreamKey = key }
        if let mode = defaults.string(forKey: "appMode") { appMode = mode }
        if let lang = defaults.string(forKey: "language") { language = lang }
        let savedRtmpPort = defaults.integer(forKey: "rtmpPort")
        if savedRtmpPort > 0 { rtmpPort = savedRtmpPort }
        let savedHttpPort = defaults.integer(forKey: "httpPort")
        if savedHttpPort > 0 { httpPort = savedHttpPort }
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
    }
    
    // Save Settings to UserDefaults
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(streamKeyType, forKey: "streamKeyType")
        defaults.set(fixedStreamKey, forKey: "fixedStreamKey")
        defaults.set(appMode, forKey: "appMode")
        defaults.set(language, forKey: "language")
        defaults.set(rtmpPort, forKey: "rtmpPort")
        defaults.set(httpPort, forKey: "httpPort")
        defaults.set(launchAtLogin, forKey: "launchAtLogin")
    }
    
    // Start backend process
    func startServer() {
        guard !isServerRunning else { return }
        errorMessage = nil
        
        // Find backend binary
        let fm = FileManager.default
        var binaryPath: String? = nil
        
        if let execURL = Bundle.main.executableURL {
            let backendURL = execURL.deletingLastPathComponent().appendingPathComponent("server-backend")
            if fm.fileExists(atPath: backendURL.path) {
                binaryPath = backendURL.path
            }
        }
        
        if binaryPath == nil {
            if let resourcePath = Bundle.main.path(forResource: "server-backend", ofType: nil) {
                if fm.fileExists(atPath: resourcePath) {
                    binaryPath = resourcePath
                }
            }
        }
        
        if binaryPath == nil {
            let possiblePaths = [
                "./build/server-backend",
                "../build/server-backend",
                "./server-backend",
                "../../build/server-backend"
            ]
            for path in possiblePaths {
                let absolute = URL(fileURLWithPath: path).path
                if fm.fileExists(atPath: absolute) {
                    binaryPath = absolute
                    break
                }
            }
        }
        
        guard let finalBinaryPath = binaryPath else {
            errorMessage = "Cannot find server-backend binary!"
            return
        }
        
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: finalBinaryPath)
        proc.arguments = [
            "--rtmp-port=\(rtmpPort)",
            "--http-port=\(httpPort)",
            "--key=\(currentStreamKey)",
            "--type=\(streamKeyType)"
        ]
        
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = pipe
        self.stdoutPipe = pipe
        
        let inPipe = Pipe()
        proc.standardInput = inPipe
        self.stdinPipe = inPipe
        
        self.process = proc
        
        // Handle process output
        let outHandle = pipe.fileHandleForReading
        outHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            if let output = String(data: data, encoding: .utf8) {
                Task { @MainActor in
                    self?.parseServerOutput(output)
                }
            }
        }
        
        proc.terminationHandler = { [weak self] p in
            Task { @MainActor in
                self?.isServerRunning = false
                self?.isStreaming = false
                self?.process = nil
                self?.stdoutPipe = nil
                self?.stdinPipe = nil
            }
        }
        
        do {
            try proc.run()
            isServerRunning = true
        } catch {
            errorMessage = "Failed to launch server-backend: \(error.localizedDescription)"
            isServerRunning = false
        }
    }
    
    // Stop backend process
    func stopServer() {
        if let proc = process, proc.isRunning {
            proc.terminate()
        }
        process = nil
        stdoutPipe = nil
        stdinPipe = nil
        isServerRunning = false
        isStreaming = false
    }
    
    private func parseServerOutput(_ output: String) {
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            print("[Backend Log] \(line)")
            
            // Check for port conflicts or startup errors
            if line.contains("EADDRINUSE") || line.contains("Address already in use") {
                DispatchQueue.main.async {
                    self.errorMessage = "Port conflict detected! RTMP or HTTP Port already in use."
                    self.stopServer()
                }
            }
            
            // Parse streaming status
            // Format: [STATUS] prePublish:id:/live/key
            if line.contains("[STATUS] prePublish:") {
                let parts = line.components(separatedBy: ":")
                if parts.count >= 3 {
                    let streamPath = parts[2]
                    let streamName = streamPath.components(separatedBy: "/").last ?? ""
                    DispatchQueue.main.async {
                        self.isStreaming = true
                        self.activeStreamName = streamName
                        self.sendNotification(title: "Stream Started", body: "Live stream '\(streamName)' is now active.")
                    }
                }
            }
            
            if line.contains("[STATUS] donePublish:") {
                let parts = line.components(separatedBy: ":")
                if parts.count >= 3 {
                    let streamPath = parts[2]
                    let streamName = streamPath.components(separatedBy: "/").last ?? ""
                    DispatchQueue.main.async {
                        self.isStreaming = false
                        self.activeStreamName = ""
                        self.sendNotification(title: "Stream Ended", body: "Live stream '\(streamName)' has stopped.")
                    }
                }
            }
        }
    }
    
    private func sendNotification(title: String, body: String) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    private func updateLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            if enabled {
                if service.status != .enabled {
                    try? service.register()
                }
            } else {
                if service.status == .enabled {
                    try? service.unregister()
                }
            }
        }
    }
}
