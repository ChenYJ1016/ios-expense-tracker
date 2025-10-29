//
//  BudgetDataStore.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import Foundation

class BudgetDataStore{
    static let shared = BudgetDataStore()
    
    private init() {}
    
    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        // 2. Use a separate file
        return documentsPath.appendingPathComponent("budget.json")
    }
    
    func loadBudget() -> Budget? {
        guard let data = try? Data(contentsOf: fileURL), let budget = try? JSONDecoder().decode(Budget.self, from: data) else {
            return nil
        }
        
        return budget
    }
    
    func saveBudget(_ budget: Budget){
        guard let data = try? JSONEncoder().encode(budget) else{
            print("Error encoding budget")
            return
        }
        
        do{
            try data.write(to: fileURL)
            NotificationCenter.default.post(name: .didUpdateBudget, object: nil)
            print("Budget saved successfully")
        }catch{
            print("Error saving budget: \(error.localizedDescription)")
        }
    }
}
