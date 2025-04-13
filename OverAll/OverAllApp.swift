//
//  OverAllApp.swift
//  OverAll
//
//  Created by Aleksandr Strizhnev on 28.03.2025.
//

import AppKit
import SwiftUI

class OverAllAppDelegate: NSObject, NSApplicationDelegate {
    var statusMenu: NSMenu!
    var statusBarItem: NSStatusItem!
    
    var promptWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let statusButton = statusBarItem!.button
        statusButton?.image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: "OverAll")
        
        let manageWindows = NSMenuItem(
            title: "Manage Windows",
            action: #selector(manageWindows), keyEquivalent: ""
        )
        let quit = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        
        statusMenu = NSMenu()
        
        statusMenu!.addItem(manageWindows)
        statusMenu!.addItem(.separator())
        statusMenu!.addItem(quit)
        
        statusBarItem!.menu = statusMenu!
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        WindowManagement.default.unpinAll()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func manageWindows() {
        self.promptWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 500),
            styleMask: [.closable, .resizable, .titled],
            backing: .buffered,
            defer: false
        )
        self.promptWindow?.isReleasedWhenClosed = false
        self.promptWindow?.titlebarAppearsTransparent = true
        self.promptWindow?.title = "Manage Windows"
        self.promptWindow?.level = NSWindow.Level(
            rawValue: NSWindow.Level.floating.rawValue + 1
        )
        self.promptWindow?.contentView = NSHostingView(
            rootView: PromptView()
        )
        self.promptWindow?.center()
        
        self.promptWindow?.makeKeyAndOrderFront(nil)
    }
}
