//
//  SheetMusicCard.swift
//  EmergenSheets
//
//  Created by Aaron on 3/31/26.
//

import SwiftUI

struct SheetMusicCard: View {
    let title: String
    let lastPlayed: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    Image(systemName: "doc.text.fill")
                        .font(.system(size:40))
                        .foregroundColor(.blue)
                )
            VStack(alignment: .leading, spacing: 4 ){
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Text("Last played: \(lastPlayed.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    SheetMusicCard(title: "Test pdf 1", lastPlayed: Date() )
}
