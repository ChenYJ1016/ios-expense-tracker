//
//  Expense.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//
import UIKit

nonisolated enum ExpenseType: String, CaseIterable, Codable, Hashable{
    case transport = "Transport"
    case grocery = "Grocery"
    case miscellaneous = "Miscellaneous"
    case bills = "Bills"
    case savings = "savings"
    case food = "Food"
}

nonisolated struct Expense: Identifiable, Codable, Hashable{
    let id = UUID()
    var name: String
    var date: Date
    var type: ExpenseType
    var amount: Decimal
    
}
