//
//  Expense.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//
import UIKit

enum ExpenseType: String, CaseIterable, Codable{
    case transport = "Transport"
    case grocery = "Grocery"
    case miscellaneous = "Miscellaneous"
    case bills = "Bills"
    case savings = "savings"
    case food = "Food"
}

struct Expense: Identifiable, Codable{
    let id = UUID()
    var name: String
    var date: DateComponents
    var type: ExpenseType
    var amount: Decimal
    
}
