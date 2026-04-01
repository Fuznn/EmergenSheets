//
//  ArrangementView.swift
//  EmergenSheets
//
//  Created by Aaron on 4/1/26.
//

import SwiftUI

struct ArrangementView: View {
    let fileURL: URL
    let savedCrops: [CropSection]
    @Binding var navigationPath: NavigationPath
    
    @State private var performanceOrder: [Int] = []
    @State private var showFinalConfig = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Build Your Arrangement")
                .font(.title2.bold())
            // Arrangement
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if performanceOrder.isEmpty {
                        Text("Tap staves below to add to sequence")
                            .foregroundColor(.secondary)
                            .frame(height: 100)
                    }
                    
                    ForEach(0..<performanceOrder.count, id: \.self) { index in
                        let cropIndex = performanceOrder[index]
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 100, height: 60)
                                    .overlay(Text("Staff \(cropIndex + 1)").bold())
                                
                                // Remove button
                                Button(action: { performanceOrder.remove(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .offset(x: 5, y: -5)
                            }
                            Text("\(index + 1)") // Sequence number
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)

            Divider()

            // Available Cropped Staves
            Text("Available Staves")
                .font(.headline)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(0..<savedCrops.count, id: \.self) { index in
                        Button(action: { performanceOrder.append(index) }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(height: 80)
                                    .overlay(
                                        VStack {
                                            Text("Staff \(index + 1)")
                                            Text("\(String(format: "%.2g", savedCrops[index].totalBeats)) Beats")
                                                .font(.caption2)
                                        }
                                    )
                                Text("Add to Roadmap")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }

            Button("Next: Set Tempo") {
                showFinalConfig = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(performanceOrder.isEmpty)
        }
        .navigationDestination(isPresented: $showFinalConfig) {
            SheetConfigurationView(
                fileURL: fileURL,
                savedCrops: savedCrops,
                performanceOrder: performanceOrder,
                navigationPath: $navigationPath
            )
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        ArrangementView(
            fileURL: URL(string: "about:blank")!,
            savedCrops: [CropSection(), CropSection()],
            navigationPath: $path
        )
    }
}
