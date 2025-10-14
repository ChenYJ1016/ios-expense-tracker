//
//  Expense.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//
import UIKit

enum ExpenseType: String, CaseIterable{
    case transport = "Transport"
    case grocery = "Grocery"
    case miscellaneous = "Miscellaneous"
    case bills = "Bills"
    case savings = "savings"
    case food = "Food"
}

class Expense{
    var name: String
    var date: DateComponents
    var type: ExpenseType
    var amount: Decimal
    
    init(name: String, date: DateComponents, type: ExpenseType, amount: Decimal) {
        self.name = name
        self.date = date
        self.type = type
        self.amount = amount
    }
}
