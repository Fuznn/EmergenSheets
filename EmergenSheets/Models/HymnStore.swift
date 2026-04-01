//
//  HymnStore.swift
//  EmergenSheets
//
//  Created by Aaron on 3/31/26.
//
import SwiftUI
import Combine

class HymnStore: ObservableObject {
    @Published var hymns: [SavedHymn] = [] {
        didSet {
            saveToDisk()
        }
    }
    private let saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("hymns.json")
    
    init() {
        loadFromDisk()
    }
    
    func addHymn(title: String, fileName: String, crops: [CropSection], performanceOrder: [Int], bpm: Double, beats: Int, beatUnit: Int) {
        let newHymn = SavedHymn(
            title: title,
            fileName: fileName,
            dateSaved: Date(),
            crops: crops,
            performanceOrder: performanceOrder,
            bpm: bpm,
            beatsPerMeasure: beats,
            beatUnit: beatUnit
        )
        hymns.append(newHymn)
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(hymns)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("Save failed: \(error.localizedDescription)")
        }
    }
    
    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: saveURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: saveURL)
            let decodedHymns = try JSONDecoder().decode([SavedHymn].self, from: data)
            self.hymns = decodedHymns
        } catch {
            print("Load failed: \(error.localizedDescription)")
        }
    }
    
    func removeHymns(at offsets: IndexSet) {
        hymns.remove(atOffsets: offsets)
    }
    
    func copyFileToLocalDocuments(from sourceURL: URL, pageCount: Int) -> String? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }

        let finalFileName: String
        if pageCount == 1 {
            finalFileName = sourceURL.lastPathComponent
        } else {
            // If multiple pages, use trimmed_code naming scheme
            let randomCode = Int.random(in: 1000...9999)
            let baseName = sourceURL.deletingPathExtension().lastPathComponent
            finalFileName = "trimmed_\(baseName)_\(randomCode).pdf"
        }
        
        let destinationURL = documentsURL.appendingPathComponent(finalFileName)
        
        // Start accessing the external file
        let shouldStopAccessing = sourceURL.startAccessingSecurityScopedResource()
        defer { if shouldStopAccessing { sourceURL.stopAccessingSecurityScopedResource() } }
        
        do {
            // If single page and already exists, don't copy again
            if fileManager.fileExists(atPath: destinationURL.path) && pageCount == 1 {
                return finalFileName
            }
            
            // For multi-page, or if file doesn't exist, perform copy
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            return finalFileName
        } catch {
            print("Copy failed: \(error.localizedDescription)")
            return nil
        }
    }
}
