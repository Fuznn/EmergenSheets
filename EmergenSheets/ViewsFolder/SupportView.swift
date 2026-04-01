//
//  SupportView.swift
//  EmergenSheets
//
//  Created by Aaron on 4/1/26.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .padding(.top)
                    
                    Text("Support EmergenSheets")
                        .font(.headline)
                    
                    Text("EmergenSheets is built for musicians, by a musician. If it helps your performance, consider supporting its development!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom)
            }
            
            Section("Support Options") {
                // KO-FI OPTION
                Link(destination: URL(string: "https://ko-fi.com/fuznn")!) {
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.blue)
                        Text("Support on Ko-fi")
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                NavigationLink(destination: QRDonationView()) {
                    Label("GCash / Maya QR", systemImage: "qrcode")
                }
            }
            
            Section {
                Text("Your support helps cover hosting costs and future feature development!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct QRDonationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Scan to Support Aaron")
                .font(.title3.bold())
            Image("PaymentQR")
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)
                .cornerRadius(15)
                .shadow(radius: 5)
            
            Text("Thank you for your generosity!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("QR Code")
    }
}
#Preview {
    SupportView()
}
