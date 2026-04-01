//
//  ContentView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/24/26.
//

import SwiftUI
import PDFKit
internal import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("hasSeenTutorial") var hasSeenTutorial: Bool = false
    @State private var selectedTab: Int = 0
    @State private var isImporting: Bool = false
    @State private var selectedFileURL: URL?
    @State private var navPath = NavigationPath()
    @State private var showPageSelection: Bool = false
    @State private var finalProcessedURL: URL?
    @State private var showConfigurator: Bool = false
    
    var body: some View {
        NavigationStack(path: $navPath) {
            TabView(selection: $selectedTab) {
                LibraryView()
                    .navigationTitle("Library")
                    .tabItem {
                        Label("Sheet Music", systemImage: "music.note.list")
                    }
                    .tag(0)
                
                Text("Loading...")
                    .tabItem {
                        Label("New", systemImage: "plus")
                    }
                    .tag(1)
                
                SettingsView()
                    .navigationTitle("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(2)
                
                SupportView()
                    .navigationTitle("Support")
                    .tabItem {
                        Label("Support", systemImage: "person")
                    }
                    .tag(3)
            }
            .navigationTitle({
                switch selectedTab {
                case 0: return "Library"
                case 2: return "Settings"
                case 3: return "Support"
                default: return ""
                }
            }())
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == 1 {
                    isImporting = true
                    selectedTab = 0
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        handlePickedFile(at: url)
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            .sheet(isPresented: $showPageSelection, onDismiss: {
                selectedFileURL?.stopAccessingSecurityScopedResource()
            }) {
                if let url = selectedFileURL {
                    PageSelectionView(url: url) { trimmedDoc in
                        saveTrimmedPDF(doc: trimmedDoc)
                    }
                }
            }
            .navigationDestination(for: URL.self) { url in
                SheetCropView(fileURL: url, navigationPath: $navPath)
            }
            .navigationDestination(for: SavedHymn.self) { hymn in
                SheetPlayerView(hymn: hymn) {
                    navPath = NavigationPath()
                }
            }
        }
    }
    
    private func handlePickedFile(at url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        self.selectedFileURL = url
        
        if let pdf = PDFDocument(url: url) {
            if pdf.pageCount > 1 {
                self.showPageSelection = true
            } else {
                copySinglePagePDF(at: url)
            }
        }
    }
    
    private func copySinglePagePDF(at url: URL) {
        let fileName = "single_\(UUID().uuidString.prefix(6)).pdf"
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: destinationURL)
        
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            navPath.append(destinationURL)
            url.stopAccessingSecurityScopedResource()
        } catch {
            print("Copy failed: \(error)")
        }
    }

    private func saveTrimmedPDF(doc: PDFDocument) {
        let fileName = "trimmed_\(UUID().uuidString.prefix(6)).pdf"
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        if doc.write(to: destinationURL) {
            self.showPageSelection = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navPath.append(destinationURL)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HymnStore())
}

struct NewSheetView: View {
    var body: some View {
        Text("Add New Sheet Music")
            .font(.largeTitle)
    }
}
struct SettingsView: View {
    var body: some View {
        Form {
            Section() {
                NavigationLink("Future Plans") {
                    FutureVisionView()
                }
            }
        }
    }
}
