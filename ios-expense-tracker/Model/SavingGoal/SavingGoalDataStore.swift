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
    
    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        return documentsPath.appendingPathComponent("savingGoals.json")
    }
    
    func loadSavingGoals() -> [SavingGoal]{
        guard let data = try? Data(contentsOf: fileURL),
              let savingGoals = try? JSONDecoder().decode([SavingGoal].self, from: data) else {
            return []
        }
        
        return savingGoals
    }
    
    /// Adds a new goal to the list and saves the entire list.
    func addSavingGoal(_ goal: SavingGoal) {
        var allGoals = loadSavingGoals()
        allGoals.append(goal)
        saveSavingGoals(allGoals) 
    }
    
    func add(amount: Decimal, to goal: SavingGoal) {
            var allGoals = loadSavingGoals()
            
            guard let index = allGoals.firstIndex(where: { $0.id == goal.id }) else {
                print("Error: Could not find goal to update.")
                return
            }
            
            allGoals[index].savedAmount += amount
            
            saveSavingGoals(allGoals)
        }
    
    // ---
    // TODO:
    // func updateSavingGoal(_ goal: SavingGoal) { ... }
    // func deleteSavingGoal(_ goal: SavingGoal) { ... }
    // ---
    
    private func saveSavingGoals(_ goals: [SavingGoal]){
        guard let data = try? JSONEncoder().encode(goals) else {
            print("Error trying to save saving goals")
            return
        }
        
        do{
            try data.write(to: fileURL)
            NotificationCenter.default.post(name: .didUpdateSavingGoals, object: nil)

            print("Saved to saving goal dataStore")
        }catch{
            print("Error writing to file when saving goals")
        }
        
    }
}

