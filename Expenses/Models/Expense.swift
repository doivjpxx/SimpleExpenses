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
    var title: String
    var value: Double
    var timestamp: Date
    var category: String
    var note: String?
    
    init(title: String, value: Double, timestamp: Date?, category: String = "Other", note: String? = nil) {
        self.title = title
        self.value = value
        self.timestamp = timestamp ?? Date()
        self.category = category
        self.note = note
    }
}
