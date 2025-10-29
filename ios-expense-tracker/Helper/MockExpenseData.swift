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
        
        // --- August 2025 ---
        
        Expense(name: "Monthly Train Pass",
                date: date(year: 2025, month: 8, day: 1, hour: 8),
                type: .transport,
                amount: 85.00),
                
        Expense(name: "Rent Payment",
                date: date(year: 2025, month: 8, day: 1, hour: 9),
                type: .bills,
                amount: 1200.00),
                
        Expense(name: "Weekly Groceries",
                date: date(year: 2025, month: 8, day: 3),
                type: .grocery,
                amount: 130.10),
                
        Expense(name: "Phone Bill",
                date: date(year: 2025, month: 8, day: 5),
                type: .bills,
                amount: 65.00),
                
        Expense(name: "Internet Bill",
                date: date(year: 2025, month: 8, day: 5, hour: 11),
                type: .bills,
                amount: 49.99),
                
        Expense(name: "Coffee",
                date: date(year: 2025, month: 8, day: 6),
                type: .food,
                amount: 5.50),
                
        Expense(name: "Bus Fare",
                date: date(year: 2025, month: 8, day: 8),
                type: .transport,
                amount: 1.90),
                
        Expense(name: "Cinema Tickets",
                date: date(year: 2025, month: 8, day: 9, hour: 20),
                type: .misc,
                amount: 32.00),
                
        Expense(name: "Weekly Groceries",
                date: date(year: 2025, month: 8, day: 10),
                type: .grocery,
                amount: 88.50),
                
        Expense(name: "Monthly Savings",
                date: date(year: 2025, month: 8, day: 15),
                type: .savings,
                amount: 500.00),
                
        Expense(name: "Dinner Takeaway",
                date: date(year: 2025, month: 8, day: 17, hour: 19),
                type: .food,
                amount: 42.00),
                
        Expense(name: "Electricity Bill",
                date: date(year: 2025, month: 8, day: 20),
                type: .bills,
                amount: 88.20),
                
        Expense(name: "Gym Membership",
                date: date(year: 2025, month: 8, day: 22),
                type: .misc,
                amount: 75.00),
                
        Expense(name: "Weekly Groceries",
                date: date(year: 2025, month: 8, day: 24),
                type: .grocery,
                amount: 105.00),
                
        Expense(name: "Birthday Gift",
                date: date(year: 2025, month: 8, day: 27),
                type: .misc,
                amount: 50.00),
                
        Expense(name: "Weekend Brunch",
                date: date(year: 2025, month: 8, day: 30, hour: 11),
                type: .food,
                amount: 65.70),

        // --- September 2025 ---
        
        Expense(name: "Monthly Train Pass",
                date: date(year: 2025, month: 9, day: 1, hour: 8),
                type: .transport,
                amount: 85.00),
                
        Expense(name: "Morning Coffee",
                date: date(year: 2025, month: 9, day: 1, hour: 9),
                type: .food,
                amount: 5.50),
                
        Expense(name: "Weekly Groceries",
                date: date(year: 2025, month: 9, day: 4),
                type: .grocery,
                amount: 115.20),
                
        Expense(name: "Phone Bill",
                date: date(year: 2025, month: 9, day: 5),
                type: .bills,
                amount: 65.00),
                
        Expense(name: "Internet Bill",
                date: date(year: 2025, month: 9, day: 5, hour: 11),
                type: .bills,
                amount: 49.99),
                
        Expense(name: "Dinner Out",
                date: date(year: 2025, month: 9, day: 7, hour: 19),
                type: .food,
                amount: 78.50),
                
        Expense(name: "Supermarket Top-up",
                date: date(year: 2025, month: 9, day: 11),
                type: .grocery,
                amount: 42.10),
                
        Expense(name: "Train Fare",
                date: date(year: 2025, month: 9, day: 12),
                type: .transport,
                amount: 2.80),
                
        Expense(name: "Monthly Savings",
                date: date(year: 2025, month: 9, day: 15),
                type: .savings,
                amount: 500.00),
                
        Expense(name: "New Book",
                date: date(year: 2025, month: 9, day: 18),
                type: .misc,
                amount: 24.99),
                
        Expense(name: "Electricity Bill",
                date: date(year: 2025, month: 9, day: 20),
                type: .bills,
                amount: 79.80),
                
        Expense(name: "Weekly Groceries",
                date: date(year: 2025, month: 9, day: 21),
                type: .grocery,
                amount: 95.00),
                
        Expense(name: "Lunch with Colleagues",
                date: date(year: 2025, month: 9, day: 24),
                type: .food,
                amount: 31.00),
                
        Expense(name: "Rent Payment",
                date: date(year: 2025, month: 9, day: 28),
                type: .bills,
                amount: 1200.00),
                
        Expense(name: "Taxi Home",
                date: date(year: 2025, month: 9, day: 30, hour: 22),
                type: .transport,
                amount: 28.00),

        // --- October 2025 (Original Data) ---
        
        Expense(name: "Train Fare",
                date: date(year: 2025, month: 10, day: 1, hour: 9), // Sorted: 9am
                type: .transport,
                amount: 2.80),
                
        Expense(name: "Morning Coffee",
                date: date(year: 2025, month: 10, day: 1, hour: 10), // Sorted: 10am
                type: .food,
                amount: 5.50),
         
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
                type: .misc,
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
                type: .misc,
                amount: 15.00),
         
        // --- Added More Data (Original) ---
         
        Expense(name: "Taxi Home (Late)",
                date: date(year: 2025, month: 10, day: 24, hour: 23),
                type: .transport,
                amount: 32.50),
         
        Expense(name: "Coffee & Cake",
                date: date(year: 2025, month: 10, day: 26, hour: 15),
                type: .food,
                amount: 12.80),

        Expense(name: "Rent Payment",
                date: date(year: 2025, month: 10, day: 28),
                type: .bills,
                amount: 1200.00),
                  
        Expense(name: "Halloween Party Supplies",
                date: date(year: 2025, month: 10, day: 30),
                type: .misc,
                amount: 55.20),
         
        // --- November 2025 (Original Data) ---
         
        Expense(name: "Monthly Train Pass",
                date: date(year: 2025, month: 11, day: 1, hour: 8),
                type: .transport,
                amount: 85.00),
                  
        Expense(name: "Morning Coffee",
                date: date(year: 2025, month: 11, day: 1, hour: 9),
                type: .food,
                amount: 5.50),
         
        Expense(name: "Weekly Groceries",
                date: date(year: 2025, month: 11, day: 2),
                type: .grocery,
                amount: 110.40),
         
        Expense(name: "Internet Bill",
                date: date(year: 2025, month: 11, day: 5),
                type: .bills,
                amount: 49.99),
         
        Expense(name: "Pizza Night",
                date: date(year: 2025, month: 11, day: 8, hour: 19),
                type: .food,
                amount: 38.00),
         
        Expense(name: "Savings Transfer",
                date: date(year: 2025, month: 11, day: 15),
                type: .savings,
                amount: 500.00)
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
