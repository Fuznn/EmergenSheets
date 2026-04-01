//
//  PDFPageRepresentable.swift
//  EmergenSheets
//
//  Created by Aaron on 3/27/26.
//

import SwiftUI
import PDFKit

struct PDFPageRepresentable: UIViewRepresentable {
    let url: URL
    let pageIndex: Int

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.isUserInteractionEnabled = false
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = uiView.document, let page = document.page(at: pageIndex) {
            uiView.go(to: page)
        }
    }
}
