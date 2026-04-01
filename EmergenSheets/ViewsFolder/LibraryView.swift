//
//  LibraryView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/31/26.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var library: HymnStore
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            if library.hymns.isEmpty {
                emptyStateView
            } else {
                hymnGridView
            }
        }
        .navigationTitle("Library")
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Nothing here yet")
                .font(.title3)
                .bold()
            
            Text("Tap the '+' tab to add your sheet music")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var hymnGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(library.hymns) { hymn in
                    NavigationLink(destination: SheetPlayerView(hymn: hymn, onDismiss: {})) {
                        SheetMusicCard(title: hymn.title, lastPlayed: hymn.dateSaved)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            if let index = library.hymns.firstIndex(where: { $0.id == hymn.id }) {
                                withAnimation {
                                    library.hymns.remove(at: index)
                                }
                            }
                        } label: {
                            Label("Remove from Library", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(HymnStore())
}
