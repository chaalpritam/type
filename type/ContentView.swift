//
//  ContentView.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @State private var showPlaceholder: Bool = true
    @FocusState private var isTextFieldFocused: Bool
    
    // A4 proportions (width:height ratio of 1:√2 or approximately 1:1.414)
    private let a4AspectRatio: CGFloat = 1 / 1.414
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Paper
                    ZStack(alignment: .topLeading) {
                        // Paper background
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .frame(width: min(geometry.size.width * 0.85, 595), height: min(geometry.size.width * 0.85, 595) / a4AspectRatio)
                        
                        VStack(alignment: .leading) {
                            // Title
                            if showPlaceholder {
                                Text("Just write...")
                                    .font(.system(size: 20, weight: .regular, design: .serif))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                    .padding(.top, 40)
                                    .padding(.leading, 40)
                            }
                            
                            // Text editor
                            TextEditor(text: $text)
                                .font(.system(size: 18, weight: .regular, design: .serif))
                                .foregroundColor(.black)
                                .background(Color.clear)
                                .focused($isTextFieldFocused)
                                .scrollContentBackground(.hidden)
                                .padding(EdgeInsets(top: showPlaceholder ? 10 : 40, leading: 40, bottom: 40, trailing: 40))
                                .onChange(of: text) { newValue in
                                    showPlaceholder = newValue.isEmpty
                                }
                        }
                        .frame(width: min(geometry.size.width * 0.85, 595), height: min(geometry.size.width * 0.85, 595) / a4AspectRatio)
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    ContentView()
}
