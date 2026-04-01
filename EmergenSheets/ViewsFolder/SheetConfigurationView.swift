//
//  SheetConfigurationView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/27/26.
//

import SwiftUI

struct SheetConfigurationView: View {
    let fileURL: URL
    let savedCrops: [CropSection]
    let performanceOrder: [Int]
    @EnvironmentObject var library: HymnStore
    @Environment(\.dismiss) var dismiss
    @Binding var navigationPath: NavigationPath
    @State private var customTitle: String = ""
    @State private var tempo: Double = 100
    @State private var beatsPerMeasure: Int = 4
    @State private var beatUnit: Int = 4
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Finalize Sheet Settings")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Hymn Title")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Enter name...", text: $customTitle)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Time Signature & Layout")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    HStack(spacing: 12) {
                        Stepper("\(beatsPerMeasure)", value: $beatsPerMeasure, in: 1...16)
                            .fixedSize()
                        
                        Text("/")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Picker("Unit", selection: $beatUnit) {
                            Text("2").tag(2)
                            Text("4").tag(4)
                            Text("8").tag(8)
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Text("\(beatsPerMeasure)/\(beatUnit)")
                        .font(.system(.headline, design: .monospaced))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Tempo")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(tempo)) BPM")
                        .font(.title3.monospacedDigit())
                        .bold()
                        .foregroundColor(.blue)
                }
                
                Slider(value: $tempo, in: 40...240, step: 1)
                    .tint(.blue)
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 5) {
                let rawBeatsInRoadmap = performanceOrder.reduce(0.0) { sum, index in
                    sum + (index < savedCrops.count ? savedCrops[index].totalBeats : 0.0)
                }
                let mathMultiplier = 4.0 / Double(beatUnit)
                let normalizedBeats = rawBeatsInRoadmap * mathMultiplier
                let totalSeconds = normalizedBeats / (tempo / 60.0)
                
                Text("Total Performance Time: \(String(format: "%.1f", totalSeconds))s")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("Roadmap: \(performanceOrder.count) systems")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button("Start Playing") {
                finalizeAndPlay()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(customTitle.isEmpty || savedCrops.isEmpty || performanceOrder.isEmpty)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Setup Music")
        .onAppear {
            if customTitle.isEmpty {
                customTitle = fileURL.deletingPathExtension().lastPathComponent
            }
        }
    }
    
    private func finalizeAndPlay() {
        let uniquePages = Set(savedCrops.map { $0.pageIndex }).count
        if let savedFileName = library.copyFileToLocalDocuments(from: fileURL, pageCount: uniquePages) {
            let newHymn = SavedHymn(
                title: customTitle,
                fileName: savedFileName,
                dateSaved: Date(),
                crops: savedCrops,
                performanceOrder: performanceOrder,
                bpm: tempo,
                beatsPerMeasure: beatsPerMeasure,
                beatUnit: beatUnit
            )
            library.addHymn(
                title: newHymn.title,
                fileName: newHymn.fileName,
                crops: newHymn.crops,
                performanceOrder: newHymn.performanceOrder,
                bpm: newHymn.bpm,
                beats: newHymn.beatsPerMeasure,
                beatUnit: newHymn.beatUnit
            )
            navigationPath = NavigationPath()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                navigationPath.append(newHymn)
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        SheetConfigurationView(
            fileURL: URL(string: "about:blank")!,
            savedCrops: [CropSection()],
            performanceOrder: [0],
            navigationPath: $path
        )
        .environmentObject(HymnStore())
    }
}
