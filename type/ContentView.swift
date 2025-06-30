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
    @State private var showPreview: Bool = true
    @State private var showHelp: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var fountainParser = FountainParser()
    
    // A4 proportions (width:height ratio of 1:√2 or approximately 1:1.414)
    private let a4AspectRatio: CGFloat = 1 / 1.414
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .edgesIgnoringSafeArea(.all)
                
                HStack(spacing: 0) {
                    // Editor Panel
                    VStack {
                        // Toolbar
                        HStack {
                            Text("Editor")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Help button
                            Button(action: {
                                showHelp = true
                            }) {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Preview toggle
                            Button(action: {
                                showPreview.toggle()
                            }) {
                                Image(systemName: showPreview ? "eye.slash" : "eye")
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        // Editor
                        ZStack(alignment: .topLeading) {
                            // Paper background
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // Fountain Text Editor with syntax highlighting
                            FountainTextEditor(
                                text: $text,
                                placeholder: "Just write..."
                            )
                            .onChange(of: text) { oldValue, newValue in
                                showPlaceholder = newValue.isEmpty
                                // Parse Fountain syntax in real-time
                                fountainParser.parse(newValue)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(width: showPreview ? geometry.size.width * 0.5 : geometry.size.width)
                    
                    // Preview Panel
                    if showPreview {
                        VStack {
                            // Toolbar
                            HStack {
                                Text("Preview")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Element count
                                Text("\(fountainParser.elements.count) elements")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            
                            // Preview content
                            ScreenplayPreview(
                                elements: fountainParser.elements,
                                titlePage: fountainParser.titlePage
                            )
                            .background(Color.white)
                            .cornerRadius(2)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .frame(width: geometry.size.width * 0.5)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
                
                // Load sample Fountain content
                text = """
                Title: The Great Screenplay
                Author: John Doe
                Draft: First Draft
                :

                # ACT ONE

                = This is the beginning of our story

                INT. COFFEE SHOP - DAY

                Sarah sits at a corner table, typing furiously on her laptop. The coffee shop is bustling with activity.

                SARAH
                (without looking up)
                I can't believe I'm finally writing this screenplay.

                She takes a sip of her coffee and continues typing.

                MIKE
                (approaching)
                Hey, Sarah! How's the writing going?

                SARAH
                (looking up, surprised)
                Mike! I didn't expect to see you here.

                > THE END <
                """
            }
            .sheet(isPresented: $showHelp) {
                FountainHelpView(isPresented: $showHelp)
            }
        }
    }
}

#Preview {
    ContentView()
}
