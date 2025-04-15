//
//  ContentView.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Text("Text Editor")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "gear")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Main Content
            TextEditor(text: $text)
                .padding()
                .border(Color.gray, width: 1)
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "folder")
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "trash")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
