//
//  SavingGoalDataStore.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import Foundation

class SavingGoalDataStore {
    
    static let shared = SavingGoalDataStore()
    
    private init(){}
    
    private var fileUrl: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        return documentsPath.appendingPathComponent("savingGoals.json")
    }
    
    /// Loads all saving goals from disk.
    /// - Returns: An array of `SavingGoal` objects.
    func loadSavingGoals() -> [SavingGoal] {
        guard let data = try? Data(contentsOf: fileUrl),
              let savingGoals = try? JSONDecoder().decode([SavingGoal].self, from: data) else {
            return []
        }
        
        return savingGoals
    }
    
    /// Adds a new saving goal to the list and saves.
    /// - Parameter goal: The new `SavingGoal` to add.
    func addSavingGoal(_ goal: SavingGoal) {
        var allGoals = loadSavingGoals()
        allGoals.append(goal)
        saveSavingGoals(allGoals)
    }
    
    /// Finds a goal by its ID, updates it, and saves.
    /// - Parameter goal: The updated `SavingGoal` object.
    func updateSavingGoal(_ goal: SavingGoal) {
        var allGoals = loadSavingGoals()
        
        guard let index = allGoals.firstIndex(where: { $0.id == goal.id }) else {
            print("Error: Could not find goal with ID \(goal.id) to update.")
            return
        }
        
        allGoals[index] = goal
        saveSavingGoals(allGoals)
    }
    
    /// Finds a goal by its ID, removes it from the list, and saves.
    /// - Parameter goal: The `SavingGoal` to delete.
    func deleteSavingGoal(_ goal: SavingGoal) {
        var allGoals = loadSavingGoals()
        
        allGoals.removeAll(where: { $0.id == goal.id })
        
        saveSavingGoals(allGoals)
    }
    
    /// Adds a specific amount to a goal's 'savedAmount' and saves the change.
    /// - Parameters:
    ///   - amount: The amount of money to add (e.g., from a new expense).
    ///   - goal: The specific SavingGoal object to update.
    func add(amount: Decimal, to goal: SavingGoal) {
        var allGoals = loadSavingGoals()
        
        guard let index = allGoals.firstIndex(where: { $0.id == goal.id }) else {
            print("Error: Could not find goal to update.")
            return
        }
        
        allGoals[index].savedAmount += amount
        
        saveSavingGoals(allGoals)
    }
    
    func subtract(amount: Decimal, from goalID: UUID){
        var allGoals = loadSavingGoals()
        
        guard let index  = allGoals.firstIndex(where: { $0.id == goalID }) else { return }
        let newAmount = allGoals[index].savedAmount - amount
        allGoals[index].savedAmount = max(0, newAmount)
        saveSavingGoals(allGoals)
    }

    
    /// Saves an array of goals to disk and posts a notification.
    /// This is the main save function that all other methods should call.
    /// - Parameter goals: The complete array of `SavingGoal` objects to save.
    private func saveSavingGoals(_ goals: [SavingGoal]){
        guard let data = try? JSONEncoder().encode(goals) else {
            print("Error trying to save saving goals")
            return
        }
        
        do{
            try data.write(to: fileUrl)
            NotificationCenter.default.post(name: .didUpdateSavingGoals, object: nil)
            print("Saved to saving goal dataStore")
        } catch {
            print("Error writing to file when saving goals: \(error.localizedDescription)")
        }
        
    }
    
    func deleteAllSavingGoals() {
            let fileManager = FileManager.default
            
            // 1. Check if the file exists
            guard fileManager.fileExists(atPath: fileUrl.path) else {
                print("Saving goals file does not exist, nothing to delete.")
                // Still post a notification to clear the UI
                NotificationCenter.default.post(name: .didUpdateSavingGoals, object: nil)
                return
            }
            
            // 2. Try to remove the file
            do {
                try fileManager.removeItem(at: fileUrl)
                
                // 3. Post notification on success
                // Note: Your saveSavingGoals method already posts this, but it's
                // good practice to post it here too for a delete operation.
                NotificationCenter.default.post(name: .didUpdateSavingGoals, object: nil)
                print("All saving goals deleted successfully.")
            } catch {
                print("Error deleting saving goals file: \(error.localizedDescription)")
            }
        }
}

