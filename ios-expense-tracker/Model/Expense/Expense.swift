//
//  Expense.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//
import UIKit

nonisolated enum ExpenseType: String, CaseIterable, Codable, Hashable{
    case bills = "Bills"
    case food = "Food"
    case grocery = "Groceries"
    case savings = "Savings"
    case transport = "Transportation"
    case misc = "Misc."
    
    var iconName: String {
            switch self {
            case .bills:
                return "newspaper"
            case .food:
                return "fork.knife"
            case .grocery:
                return "cart"
            case .savings:
                return "banknote"
            case .transport:
                return "bus"
            case .misc:
                return "giftcard"
            }
        }
}

nonisolated struct Expense: Identifiable, Codable, Hashable{
    let id: UUID
    var goalID: UUID?
    var name: String
    var date: Date
    var type: ExpenseType
    var amount: Decimal
    
    
    init(id: UUID = UUID(), name: String, date: Date, type: ExpenseType, amount: Decimal, goalID: UUID? = nil){
        self.id = id
        self.name = name
        self.date = date
        self.type = type
        self.amount = amount
        self.goalID = goalID
    }
}
