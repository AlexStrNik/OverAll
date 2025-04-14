//
//  PromptView.swift
//  OverAll
//
//  Created by Aleksandr Strizhnev on 05.04.2025.
//

import SwiftUI

extension WindowManagement.SLSWindow: Identifiable {
    var id: UInt32 {
        self.wid
    }
}

struct PromptView: View {
    @State private var allWindows: [WindowManagement.SLSWindow] = []
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible()),
                        count: 4
                    )
                ) {
                    ForEach(allWindows) { window in
                        Button(action: {
                            if window.isPinned {
                                WindowManagement.default.unpin(window: window)
                            } else {
                                WindowManagement.default.pin(window: window)
                            }
                            allWindows = WindowManagement.default.allWindows()
                        }) {
                            VStack {
                                if let preview = window.preview {
                                    Image(nsImage: preview)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 100)
                                        .clipShape(RoundedRectangle(cornerSize: .init(width: 5, height: 5)))
                                }
                                
                                Text(window.title)
                                    .lineLimit(1)
                                    .frame(maxWidth: 150)
                            }
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: window.isPinned ? "pin.slash.fill" : "pin.fill")
                                    .padding(5)
                                    .foregroundStyle(Color.white)
                                    .background(Color.accentColor)
                                    .clipShape(.circle)
                                    .padding(10)
                            }
                            .padding(5)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            HStack {
                Image(nsImage: NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath))
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text(
                    "OverAll v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
                )
            }
            .padding(10)
        }
        .frame(minWidth: 700)
        .task {
            allWindows = WindowManagement.default.allWindows()
        }
    }
}
