//
//  Item.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
