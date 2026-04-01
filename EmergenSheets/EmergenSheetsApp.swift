//
//  EmergenSheetsApp.swift
//  EmergenSheets
//
//  Created by Aaron on 3/24/26.
//

import SwiftUI

@main
struct EmergenSheetsApp: App {
    @StateObject var hymnStore = HymnStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hymnStore)
        }
    }
}
