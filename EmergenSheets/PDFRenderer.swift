//
//  PDFRenderer.swift
//  EmergenSheets
//
//  Created by Aaron on 3/31/26.
//

import Foundation
import PDFKit
import UIKit

func renderCropToImage(url: URL, crop: CropSection, viewWidth: CGFloat) -> UIImage? {
    guard let document = PDFDocument(url: url), let page = document.page(at: crop.pageIndex) else { return nil }
    let pageRect = page.bounds(for: .mediaBox)
    
    let scaledOffset: CGFloat
    let scaledCropHeight: CGFloat
    
    // Check if we have normalization data from the new SheetCropView logic
    if crop.viewHeight > 0 {
        // FOR NORMALIZED CALCULATION
        // Find the ratio of where the crop was on the screen and apply it to the PDF height
        let offsetRatio = crop.offset / crop.viewHeight
        let heightRatio = crop.height / crop.viewHeight
        
        scaledOffset = offsetRatio * pageRect.height
        scaledCropHeight = heightRatio * pageRect.height
    } else {
        // FOR LEGACY FALLBACK
        // Uses the width-based scale factor logic used previously
        let scaleFactor = pageRect.width / viewWidth
        scaledOffset = crop.offset * scaleFactor
        scaledCropHeight = crop.height * scaleFactor
    }
    let yInPDFCoordinates = pageRect.height - scaledOffset - scaledCropHeight
    
    let extractRect = CGRect(x: 0, y: yInPDFCoordinates, width: pageRect.width, height: scaledCropHeight)
    
    // Drawing Logic
    let renderer = UIGraphicsImageRenderer(size: extractRect.size)
    return renderer.image { ctx in
        UIColor.white.setFill()
        ctx.fill(CGRect(origin: .zero, size: extractRect.size))
        
        let cgContext = ctx.cgContext
        cgContext.saveGState()
        // Fix upside-down
        cgContext.translateBy(x: 0, y: extractRect.size.height)
        cgContext.scaleBy(x: 1.0, y: -1.0)
        cgContext.translateBy(x: -extractRect.origin.x, y: -extractRect.origin.y)
        
        page.draw(with: .mediaBox, to: cgContext)
        cgContext.restoreGState()
    }
}
