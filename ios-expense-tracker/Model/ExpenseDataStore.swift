//
//  ExpenseDataStore.swift
//  ios-expense-tracker
//
//  Created by James Chen on 15/10/25.
//

import UIKit

class ExpenseDataStore {
    static let shared = ExpenseDataStore() // 1. singleton

    private init() {}

    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documentsPath.appendingPathComponent("expenses.json")
    }

    func loadExpenses() -> [Expense] {
        guard let data = try? Data(contentsOf: fileURL),
              let expenses = try? JSONDecoder().decode([Expense].self, from: data) else {
            return []
        }
        return expenses
    }

    func saveExpenses(_ expenses: [Expense]) {
        guard let data = try? JSONEncoder().encode(expenses) else {
            print("Error: Could not encode expenses.")
            return
        }

        do {
            try data.write(to: fileURL)
        } catch {
            // This 'catch' block will run if the write operation fails
            print("Error saving expenses: \(error.localizedDescription)")
        }
    }
    
    func addExpense(_ expense: Expense) throws {
        var allExpenses = try loadExpenses()
        allExpenses.append(expense)
        try saveExpenses(allExpenses)
    }
    
    func updateExpense(_ expense: Expense) throws {
        var allExpenses = try loadExpenses()
        if let index = allExpenses.firstIndex(where: {$0.id == expense.id}){
            allExpenses[index] = expense
        }
        
        try saveExpenses(allExpenses)
    }
    
    func deleteExpense(_ expense: Expense) throws {
        var allExpenses = try loadExpenses()
        allExpenses.removeAll(where: {$0.id == expense.id})
        try saveExpenses(allExpenses)
    }
    
    func deleteExpense(at index: Int) throws {
        var allExpenses = try loadExpenses()
        allExpenses.remove(at: index)
        try saveExpenses(allExpenses)
    }
}
