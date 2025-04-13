//
//  main.swift
//  OverAll
//
//  Created by Aleksandr Strizhnev on 05.04.2025.
//

import Foundation
import AppKit

let app = NSApplication.shared
let delegate = OverAllAppDelegate()

app.delegate = delegate
app.setActivationPolicy(.accessory)

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
