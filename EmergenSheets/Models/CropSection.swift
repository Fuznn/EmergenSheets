//
//  CropSection.swift
//  EmergenSheets
//
//  Created by Aaron on 4/1/26.
//

import Foundation
struct CropSection: Identifiable, Codable, Hashable {
    var id = UUID()
    var pageIndex: Int = 0
    var offset: CGFloat = 0
    var height: CGFloat = 120
    var viewHeight: CGFloat = 1.0
    var totalBeats: Double = 8.0
}
