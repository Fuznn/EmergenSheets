//
//  SheetConfigurationView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/27/26.
//

import SwiftUI

struct SheetConfigurationView: View {
    let fileURL: URL
    @State private var tempo: Double = 100
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Configure \(fileURL.lastPathComponent)")
                .font(.headline)
            
            Text("BPM: \(Int(tempo))")
            
            Slider(value: $tempo, in: 40...200)
            
            Button("Finish Setup") {
                print("Starting viewer...")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Setup Music")
    }
}

#Preview {
    // dummy URL so the preview works
    SheetConfigurationView(fileURL: URL(string: "about:blank")!)
}
