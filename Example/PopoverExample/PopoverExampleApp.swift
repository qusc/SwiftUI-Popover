//
//  PopoverExampleApp.swift
//  PopoverExample
//
//  Created by Quirin Schweigert on 21.11.25.
//

import SwiftUI

@main
struct PopoverExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
