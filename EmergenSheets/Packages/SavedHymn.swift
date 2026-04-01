//
//  SavedHymn.swift
//  EmergenSheets
//
//  Created by Aaron on 3/31/26.
//

import Foundation

struct SavedHymn: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let fileName: String
    let dateSaved: Date
    let crops: [CropSection]
    var performanceOrder: [Int]
    let bpm: Double
    var beatsPerMeasure: Int
    var beatUnit: Int
    
    init(id: UUID = UUID(), title: String, fileName: String, dateSaved: Date, crops: [CropSection], performanceOrder: [Int], bpm: Double, beatsPerMeasure: Int, beatUnit: Int) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.dateSaved = dateSaved
        self.crops = crops
        self.performanceOrder = performanceOrder
        self.bpm = bpm
        self.beatsPerMeasure = beatsPerMeasure
        self.beatUnit = beatUnit
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SavedHymn, rhs: SavedHymn) -> Bool {
        lhs.id == rhs.id
    }
}
