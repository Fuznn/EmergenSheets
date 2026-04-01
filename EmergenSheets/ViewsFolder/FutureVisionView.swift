//
//  FutureVisionView.swift
//  EmergenSheets
//
//  Created by Aaron on 3/31/26.
//

import SwiftUI

struct FutureVisionView: View {
    var body: some View {
        VStack {
            Text("Future Plans")
                .font(.headline)
            Toggle("Machine Vision Auto Setup", isOn: .constant(false))
                .disabled(true)
                .padding([.top,.horizontal],30)
            Toggle("Blink to next page", isOn: .constant(false))
                .disabled(true)
                .padding(.horizontal, 30)
                .padding(.top, 5)
            Spacer()
        }
    }
}

#Preview {
    FutureVisionView()
}
