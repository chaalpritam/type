//
//  typeApp.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import SwiftUI
import UI.ModularAppView

@main
struct typeApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            ModularAppView()
                .preferredColorScheme(.light)
        }
    }
}
