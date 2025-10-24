
//
//  MockExpenseData.swift
//  ios-expense-tracker
//
//  Created by James Chen on 24/10/25.
//

import Foundation
import UIKit // Keep this import if ExpenseDataStore needs it, otherwise Foundation is fine.

// MARK: - Mock Data Generation

struct MockExpenseData {

    /// A reusable helper to make creating dates easier.
    /// Note: This force-unwraps '!' for simplicity in mock data.
    /// In production code, you would handle the optional more gracefully.
    private static func date(year: Int, month: Int, day: Int, hour: Int = 10, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }

    /// The static dataset of mock expenses.
    static let sampleExpenses: [Expense] = [
        Expense(name: "Morning Coffee",
                date: date(year: 2025, month: 10, day: 1),
                type: .food,
                amount: 5.50),
        
        Expense(name: "Train Fare",
                date: date(year: 2025, month: 10, day: 1),
                type: .transport,
                amount: 2.80),
        
        Expense(name: "Weekly Groceries",
                date: date(year: 2025, month: 10, day: 3),
                type: .grocery,
                amount: 120.75),
        
        Expense(name: "Phone Bill",
                date: date(year: 2025, month: 10, day: 5),
                type: .bills,
                amount: 65.00),
        
        Expense(name: "Lunch with Team",
                date: date(year: 2025, month: 10, day: 7),
                type: .food,
                amount: 22.50),
        
        Expense(name: "Cinema Tickets",
                date: date(year: 2025, month: 10, day: 10),
                type: .miscellaneous,
                amount: 32.00),
        
        Expense(name: "Bus to City",
                date: date(year: 2025, month: 10, day: 12),
                type: .transport,
                amount: 1.90),
        
        Expense(name: "Monthly Savings",
                date: date(year: 2025, month: 10, day: 15),
                type: .savings,
                amount: 500.00),
        
        Expense(name: "Dinner Takeaway",
                date: date(year: 2025, month: 10, day: 18),
                type: .food,
                amount: 45.20),
        
        Expense(name: "Electricity Bill",
                date: date(year: 2025, month: 10, day: 20),
                type: .bills,
                amount: 85.40),
        
        Expense(name: "Supermarket Run",
                date: date(year: 2025, month: 10, day: 22),
                type: .grocery,
                amount: 78.30),
        
        Expense(name: "New Notebook",
                date: date(year: 2025, month: 10, day: 23),
                type: .miscellaneous,
                amount: 15.00)
    ]
}

// MARK: - ExpenseDataStore Extension

extension ExpenseDataStore {
    
    /// Saves the mock dataset to the JSON file.
    /// This will overwrite any existing data.
    func saveMockData() {
        print("Saving mock data...")
        saveExpenses(MockExpenseData.sampleExpenses)
        print("Mock data saved.")
    }
    
    /// Checks if any expenses are saved. If not, it loads the mock data.
    /// This is a safe way to populate data only on the first launch.
    func loadMockDataIfEmpty() {
        let existingExpenses = loadExpenses()
        if existingExpenses.isEmpty {
            print("No expenses found. Loading mock data.")
            saveMockData()
        } else {
            print("\(existingExpenses.count) expenses already exist. No mock data loaded.")
        }
    }
}
