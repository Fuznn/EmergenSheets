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
    @State private var cropHeight: CGFloat = 120
    @State private var cropOffset: CGFloat = 0
    @State private var showVisionStep = false

    var body: some View {
        VStack(spacing: 0) {
            Text("Align the box to the first staff")
                .font(.caption)
                .padding(.top)

            ZStack(alignment: .top) {
                // PDF View
                Group {
                    PDFPageRepresentable(url: fileURL)
                }
                .clipped()

                // Selection Overlay
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.15))
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(height: cropHeight)
                        .offset(y: cropOffset)
                        // Drag to move the whole box
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    cropOffset = value.location.y - (cropHeight / 2)
                                }
                        )
                    
                    // Resize Handle (Circle at the bottom)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .offset(y: cropOffset - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newHeight = value.location.y - cropOffset
                                    cropHeight = max(50, newHeight) // Min height of 50
                                }
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button("Confirm Zoom Area") {
                showVisionStep = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Step 1: Zoom Setup")
    }
}

// dummy URL
#Preview {
    NavigationStack {
        SheetCropView(fileURL: URL(string: "about:blank")!)
    }
}

