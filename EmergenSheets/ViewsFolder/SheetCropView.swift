//
//  SheetCropView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/27/26.
//
import SwiftUI
import PDFKit

struct SheetCropView: View {
    let fileURL: URL
    @Binding var navigationPath: NavigationPath
    
    @State private var numberOfCrops: Int = 4
    @State private var currentIndex: Int = 0
    @State private var crops: [CropSection] = []
    @State private var dragOffset: CGFloat = 0
    @State private var showConfig = false
    @State private var showBeatSettings = false
    @State private var totalPages: Int = 1

    var body: some View {
        VStack(spacing: 0) {
            // Navigation and Page Selection Header
            VStack(spacing: 12) {
                HStack {
                    Text("Total Systems:")
                    Stepper("\(numberOfCrops)", value: $numberOfCrops, in: 1...30)
                        .onChange(of: numberOfCrops) { _, newValue in
                            updateCropArray(to: newValue)
                        }
                }
                
                if !crops.isEmpty {
                    HStack {
                        Label("Source Page:", systemImage: "doc.on.doc")
                            .font(.subheadline)
                        Spacer()
                        Picker("Page", selection: $crops[currentIndex].pageIndex) {
                            ForEach(0..<totalPages, id: \.self) { i in
                                Text("Page \(i + 1)").tag(i)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal, 4)
                }

                HStack {
                    Button(action: { if currentIndex > 0 { currentIndex -= 1 } }) {
                        Image(systemName: "chevron.left.circle.fill").font(.title)
                    }
                    .disabled(currentIndex == 0)
                    
                    Spacer()
                    VStack {
                        Text("System \(currentIndex + 1) of \(numberOfCrops)")
                            .font(.headline)
                        if !crops.isEmpty {
                            Text("Stored on PDF Page \(crops[currentIndex].pageIndex + 1)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    
                    Button(action: { if currentIndex < numberOfCrops - 1 { currentIndex += 1 } }) {
                        Image(systemName: "chevron.right.circle.fill").font(.title)
                    }
                    .disabled(currentIndex == numberOfCrops - 1)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))

            // Cropping Canvas
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    Color.white
                    
                    if !crops.isEmpty {
                        PDFPageRepresentable(url: fileURL, pageIndex: crops[currentIndex].pageIndex)
                    }
                    
                    if !crops.isEmpty {
                        Group {
                            Rectangle()
                                .fill(Color.blue.opacity(0.15))
                                .stroke(Color.blue, lineWidth: 3)
                                .overlay(metronomeButtonOverlay)
                        }
                        .frame(height: crops[currentIndex].height)
                        .offset(y: crops[currentIndex].offset + dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in dragOffset = value.translation.height }
                                .onEnded { value in
                                    crops[currentIndex].viewHeight = geo.size.height
                                    crops[currentIndex].offset += value.translation.height
                                    dragOffset = 0
                                }
                        )
                    }
                }
            }
            .clipped()

            // Bottom Controls
            VStack {
                HStack {
                    Image(systemName: "arrow.up.and.down.text.horizontal")
                    Slider(value: Binding(
                        get: { crops.isEmpty ? 120 : crops[currentIndex].height },
                        set: { if !crops.isEmpty { crops[currentIndex].height = $0 } }
                    ), in: 50...400)
                }
                .padding(.bottom, 8)

                Button("Confirm All \(numberOfCrops) Systems") {
                    showConfig = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showBeatSettings) {
            if !crops.isEmpty {
                BeatSettingsPopup(totalBeats: $crops[currentIndex].totalBeats)
                    .presentationDetents([.height(220)])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear { initializeCrops() }
        .navigationDestination(isPresented: $showConfig) {
            ArrangementView(fileURL: fileURL, savedCrops: crops, navigationPath: $navigationPath)
        }
    }
    
    private func initializeCrops() {
        if let doc = PDFDocument(url: fileURL) {
            self.totalPages = doc.pageCount
        }
        
        if crops.isEmpty {
            crops = (0..<numberOfCrops).map { _ in CropSection() }
        }
    }

    private var metronomeButtonOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showBeatSettings = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "metronome.fill")
                        Text("\(String(format: "%.2g", crops[currentIndex].totalBeats))")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.blue).foregroundColor(.white).cornerRadius(20)
                }
                .padding(8)
            }
        }
    }
    
    private func updateCropArray(to newValue: Int) {
        if newValue > crops.count {
            let lastPageIndex = crops.last?.pageIndex ?? 0
            let difference = newValue - crops.count
            
            let newSections = (0..<difference).map { _ in
                var section = CropSection()
                section.pageIndex = lastPageIndex
                return section
            }
            
            crops.append(contentsOf: newSections)
        } else if newValue < crops.count {
            crops.removeLast(crops.count - newValue)
            if currentIndex >= newValue { currentIndex = newValue - 1 }
        }
    }
}
#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        SheetCropView(fileURL: URL(string: "about:blank")!, navigationPath: $path)
    }
}
struct BeatSettingsPopup: View {
    @Binding var totalBeats: Double
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Duration")
                        .font(.headline)
                    Text("Total beats in this crop")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .fontWeight(.bold)
            }
            .padding([.horizontal, .top])
            .padding(.bottom, 10)

            Divider()
            HStack(spacing: 0) {
                // Whole Beats Column
                Picker("Beats", selection: Binding(
                    get: { Int(floor(totalBeats)) },
                    set: { totalBeats = Double($0) + (totalBeats.truncatingRemainder(dividingBy: 1)) }
                )) {
                    ForEach(0...32, id: \.self) { num in
                        Text("\(num)").tag(num)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Text("and")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Picker("Fraction", selection: Binding(
                    get: { totalBeats.truncatingRemainder(dividingBy: 1) },
                    set: { totalBeats = floor(totalBeats) + $0 }
                )) {
                    Text(".0").tag(0.0)
                    Text(".25").tag(0.25)
                    Text(".5").tag(0.5)
                    Text(".75").tag(0.75)
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 150)
            
            Spacer()
        }
    }
}
