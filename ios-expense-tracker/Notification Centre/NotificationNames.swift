//
//  NotificationNames.swift
//  ios-expense-tracker
//
//  Created by James Chen on 28/10/25.
//

import Foundation

extension Notification.Name {
    /// Posted when the user's budget (income/goal) is saved.
    static let didUpdateBudget = Notification.Name("didUpdateBudget")
    
    /// Posted when the list of saving goals is modified (added, edited, deleted).
    static let didUpdateSavingGoals = Notification.Name("didUpdateSavingGoals")
    
    /// Posted when the list of expenses is modified.
    /// (You are already using this, but it's good to define it here too)
    static let didUpdateExpenses = Notification.Name("didUpdateExpenses")
}
