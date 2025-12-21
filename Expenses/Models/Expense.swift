//
//  Item.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import Foundation
import SwiftData

@Model
final class Expense {
    @Attribute(.unique) var title: String
    var value: Double
    var timestamp: Date
    
    init(title: String, value: Double, timestamp: Date?) {
        self.title = title
        self.value = value
        self.timestamp = timestamp ?? Date()
    }
}
