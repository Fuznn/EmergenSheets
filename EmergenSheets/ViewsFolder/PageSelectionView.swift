//
//  PageSelectionView.swift
//  EmergenSheets
//
//  Created by Aaron on 4/1/26.
//

import SwiftUI
import PDFKit

struct PageSelectionView: View {
    let url: URL
    @State private var selectedPages: Set<Int> = []
    @State private var pdfDocument: PDFDocument?
    @Environment(\.dismiss) var dismiss

    var onImport: (PDFDocument) -> Void

    let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        NavigationView {
            ScrollView {
                if let doc = pdfDocument {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(0..<doc.pageCount, id: \.self) { index in
                            PageThumbnailTile(
                                doc: doc,
                                index: index,
                                isSelected: selectedPages.contains(index)
                            )
                            .onTapGesture {
                                if selectedPages.contains(index) {
                                    selectedPages.remove(index)
                                } else {
                                    selectedPages.insert(index)
                                }
                            }
                        }
                    }
                    .padding()
                } else {
                    ProgressView("Loading Hymnal...")
                }
            }
            .navigationTitle("Select Pages")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import (\(selectedPages.count))") {
                        extractAndProcess()
                    }
                    .disabled(selectedPages.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            // Load document on background thread for large files
            DispatchQueue.global(qos: .userInitiated).async {
                let doc = PDFDocument(url: url)
                DispatchQueue.main.async { self.pdfDocument = doc }
            }
        }
    }

    func extractAndProcess() {
        let newDoc = PDFDocument()
        let sortedIndices = selectedPages.sorted()
        
        for index in sortedIndices {
            if let page = pdfDocument?.page(at: index) {
                newDoc.insert(page, at: newDoc.pageCount)
            }
        }
        onImport(newDoc)
        dismiss()
    }
}

// Sub-view to handle individual page previews efficiently
struct PageThumbnailTile: View {
    let doc: PDFDocument
    let index: Int
    let isSelected: Bool
    
    var body: some View {
        VStack {
            if let image = generateThumbnail(for: index) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 140)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 4)
                    )
            }
            Text("Page \(index + 1)")
                .font(.caption2)
        }
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }

    func generateThumbnail(for index: Int) -> UIImage? {
        guard let page = doc.page(at: index) else { return nil }
        // We render a small thumbnail (300px) instead of the full page
        return page.thumbnail(of: CGSize(width: 300, height: 400), for: .mediaBox)
    }
}
#Preview {
    // Blank URL to pass errors
    PageSelectionView(
        url: URL(string: "https://www.google.com")!,
        onImport: { trimmedDoc in
            print("Imported document with \(trimmedDoc.pageCount) pages")
        }
    )
}
