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

    func loadExpenses()  -> [Expense]  {
        guard let data = try? Data(contentsOf: fileURL),
              let expenses = try? JSONDecoder().decode([Expense].self, from: data) else {
            return []
        }
        return expenses
    }
    
    func loadExpenses(by category: ExpenseType) ->  [Expense] {
        let allExpenses = self.loadExpenses()
        return allExpenses.filter { $0.type == category }
    }
    
    func saveExpenses(_ expenses: [Expense]) {
        guard let data = try? JSONEncoder().encode(expenses) else {
            print("Error: Could not encode expenses.")
            return
        }

        do {
            try data.write(to: fileURL)
            NotificationCenter.default.post(name: .didUpdateExpenses, object: nil)
        } catch {
           
            print("Error saving expenses: \(error.localizedDescription)")
        }
    }
    
    func addExpense(_ expense: Expense)  {
        var allExpenses = loadExpenses()
        
        if expense.type == .savings, let goalToUpdate = findGoal(for: expense.goalID){
            SavingGoalDataStore.shared.add(amount: expense.amount, to: goalToUpdate)
        }
        allExpenses.append(expense)
        saveExpenses(allExpenses)
    }
    
    func updateExpense(_ expense: Expense)  {
        var allExpenses = loadExpenses()
        if let index = allExpenses.firstIndex(where: {$0.id == expense.id}){
            allExpenses[index] = expense
        }
        
        saveExpenses(allExpenses)
    }
    
    func updateExpense(_ updatedExpense: Expense, originalAmount: Decimal, originalGoalID: UUID?){
        if let oldGoalID = originalGoalID{
            SavingGoalDataStore.shared.subtract(amount: originalAmount, from: oldGoalID)
        }
        
        if updatedExpense.type == .savings, let newGoal = findGoal(for: updatedExpense.goalID){
            SavingGoalDataStore.shared.add(amount: updatedExpense.amount, to: newGoal)
        }
        
        var allExpenses = loadExpenses()
        if let index = allExpenses.firstIndex(where: {$0.id == updatedExpense.id}){
            allExpenses[index] = updatedExpense
        }
        
        saveExpenses(allExpenses)
    }
    
    func deleteExpense(_ expense: Expense)  {
        
        var allExpenses = loadExpenses()
        
        allExpenses.removeAll(where: {$0.id == expense.id})
        
        if expense.type == .savings, let goalID = expense.goalID {
            SavingGoalDataStore.shared.subtract(amount: expense.amount, from: goalID)
        }
        
        saveExpenses(allExpenses)
    }
    
    func deleteExpense(at index: Int)  {
        var allExpenses = loadExpenses()
        allExpenses.remove(at: index)
        saveExpenses(allExpenses)
    }
    
    private func findGoal(for goalID: UUID?) -> SavingGoal? {
            guard let goalID = goalID else { return nil }
            return SavingGoalDataStore.shared.loadSavingGoals().first(where: { $0.id == goalID })
        }
}
