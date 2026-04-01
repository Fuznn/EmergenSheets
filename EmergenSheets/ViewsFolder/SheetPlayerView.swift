//
//  SheetPlayerView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/31/26.
//

import SwiftUI
import PDFKit

struct SheetPlayerView: View {
    let hymn: SavedHymn
    var onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStepIndex = 0
    @State private var isPlaying = false
    @State private var timer: Timer? = nil
    @State private var showControls = true
    
    var currentCropIndex: Int {
        hymn.performanceOrder[currentStepIndex]
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fullURL = docsUrl.appendingPathComponent(hymn.fileName)
                
                if FileManager.default.fileExists(atPath: fullURL.path) {
                    GeometryReader { geo in
                        ZStack {
                            if let stripImage = renderCropToImage(url: fullURL, crop: hymn.crops[currentCropIndex], viewWidth: geo.size.width) {
                                Image(uiImage: stripImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width)
                                    .background(Color.white)
                            }
                            
                            HStack(spacing: 0) {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { navigate(direction: -1) }
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { navigate(direction: 1) }
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showControls.toggle() }
                    }
                }
            }
            
            VStack {
                // Header (Back Button)
                HStack {
                    Button(action: {
                        onDismiss()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    Spacer()
                }
                .opacity(showControls ? 1 : 0)
                
                Spacer()
                
                // Footer Controls
                HStack(spacing: 15) {
                    Button(action: toggleTimer) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .bold))
                            .padding(12)
                            .background(isPlaying ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    HStack(spacing: 8) {
                        Text("Section \(currentStepIndex + 1) of \(hymn.performanceOrder.count)")
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.bold)
                        Circle()
                            .fill(isPlaying ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.bottom, 30)
                .opacity(showControls ? 1 : 0)
            }
        }
        .navigationBarHidden(true)
    }
    
    func navigate(direction: Int) {
        timer?.invalidate()
        withAnimation(.easeInOut(duration: 0.4)) {
            let newIndex = currentStepIndex + direction
            if newIndex >= 0 && newIndex < hymn.performanceOrder.count {
                currentStepIndex = newIndex
            }
        }
        if isPlaying { startTimer() }
    }
    
    func toggleTimer() {
        isPlaying.toggle()
        if isPlaying { startTimer() } else { timer?.invalidate() }
    }

    func startTimer() {
        timer?.invalidate()
        
        let crop = hymn.crops[currentCropIndex]
        let mathMultiplier = 4.0 / Double(hymn.beatUnit)
        let normalizedBeats = crop.totalBeats * mathMultiplier
        let currentDuration = normalizedBeats / (hymn.bpm / 60.0)
        
        timer = Timer.scheduledTimer(withTimeInterval: currentDuration, repeats: false) { _ in
            guard isPlaying else { return }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                if currentStepIndex < hymn.performanceOrder.count - 1 {
                    currentStepIndex += 1
                    startTimer()
                } else {
                    isPlaying = false
                    timer?.invalidate()
                }
            }
        }
    }
}

#Preview {
    SheetPlayerView(hymn: SavedHymn(
        title: "Sample Hymn",
        fileName: "sample",
        dateSaved: Date(),
        crops: [CropSection(offset: 0, height: 200)],
        performanceOrder: [0],
        bpm: 100,
        beatsPerMeasure: 4,
        beatUnit: 4
    ), onDismiss: {
        print("Preview Dismiss Triggered")
    })
}
