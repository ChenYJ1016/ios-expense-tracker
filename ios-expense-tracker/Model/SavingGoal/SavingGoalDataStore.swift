//
//  SavingGoalDataStore.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import Foundation

class SavingGoalDataStore{
    
    static let shared = SavingGoalDataStore()
    
    private init(){}
    
    private var fileUrl: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        return documentsPath.appendingPathComponent("savingGoals.json")
    }
    
    func loadSavingGoals() -> [SavingGoal]{
        guard let data = try? Data(contentsOf: fileUrl),
              let savingGoals = try? JSONDecoder().decode([SavingGoal].self, from: data) else {
            return []
        }
        
        return savingGoals
    }
    
    func saveSavingGoals(_ goals: [SavingGoal]){
        guard let data = try? JSONEncoder().encode(goals) else {
            print("Error trying to save saving goals")
            return
        }
        
        do{
            try data.write(to: fileUrl)
            print("Saved to saving goal dateStore")
        }catch{
            print("Error writing to file when saving goals")
        }
    }
}
