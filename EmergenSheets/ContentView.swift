//
//  ContentView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/24/26.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("hasSeenTutorial") var hasSeenTutorial: Bool = false
    @State private var selectedTab: Int = 0
    @State private var isImporting: Bool = false
    @State private var selectedFileURL: URL?
    @State private var showConfigurator: Bool = false
    
    var body: some View {
        NavigationStack {
//            if hasSeenTutorial {
//                //enter main view
//            } else {
//                GetStartedView()
//            }
        TabView(selection: $selectedTab){
            LibraryView()
                .tabItem{
                    Label(title:{ Text("Sheet Music")}, icon:{Image(systemName: "music.note.list")})
                }
                .tag(0)
            NewSheetView()
                .tabItem{
                    Label(title:{ Text("New")}, icon:{Image(systemName: "plus")})
                }
                .tag(1)
            SettingsView()
                .tabItem{
                    Label(title:{ Text("Settings")}, icon:{Image(systemName: "gearshape")})
                }
                .tag(2)
            SupportView()
                .tabItem{
                    Label(title:{ Text("Support")}, icon:{Image(systemName: "person")})
                }
                .tag(3)
            }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 1 {
                isImporting = true
                selectedTab = 0
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    if url.startAccessingSecurityScopedResource() {
                        self.selectedFileURL = url
                        self.showConfigurator = true
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
        .navigationDestination(isPresented: $showConfigurator) {
            if let url = selectedFileURL {
                SheetCropView(fileURL: url)
            }
        }
        }
    }
}
#Preview {
    ContentView()
}
struct LibraryView: View {
    var body: some View {
        Text("Library Screen")
            .font(.largeTitle)
    }
}
struct NewSheetView: View {
    var body: some View {
        Text("Add New Sheet Music")
            .font(.largeTitle)
    }
}
struct SettingsView: View {
    var body: some View {
        Text("Settings Screen")
            .font(.largeTitle)
    }
}
struct SupportView: View {
    var body: some View {
        Text("Support the creator")
            .font(.largeTitle)
    }
}
