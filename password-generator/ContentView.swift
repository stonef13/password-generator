//
//  ContentView.swift
//  password-generator
//
//  Created by Stone Fuglaar on 7/28/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPassword = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("PasswordGen")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(currentPassword)
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

            Button {
                currentPassword = PasswordGenerator.generate()
            } label: {
                Text("Generate")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .onAppear {
            currentPassword = PasswordGenerator.generate()
        }
    }
}

#Preview {
    ContentView()
}
