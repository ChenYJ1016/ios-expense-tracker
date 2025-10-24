//
//  Expense.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//
import UIKit

nonisolated enum ExpenseType: String, CaseIterable, Codable, Hashable{
    case bills = "🧾"
    case food = "🥘"
    case grocery = "🛒"
    case savings = "🏦"
    case transport = "🚌"
    case miscellaneous = "😍"
    
    
    
}

nonisolated struct Expense: Identifiable, Codable, Hashable{
    let id = UUID()
    var name: String
    var date: Date
    var type: ExpenseType
    var amount: Decimal
    
}
