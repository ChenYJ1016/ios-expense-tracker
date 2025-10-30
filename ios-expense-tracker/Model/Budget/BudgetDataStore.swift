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
    
        func deleteBudget() {
            let fileManager = FileManager.default
            
            // 1. Check if the file actually exists before trying to delete it
            guard fileManager.fileExists(atPath: fileURL.path) else {
                print("Budget file does not exist, nothing to delete.")
                // You might still want to post a notification to clear the UI
                NotificationCenter.default.post(name: .didUpdateBudget, object: nil)
                return
            }
            
            // 2. Try to remove the file
            do {
                try fileManager.removeItem(at: fileURL)
                
                // 3. Post a notification to refresh the UI
                NotificationCenter.default.post(name: .didUpdateBudget, object: nil)
                print("Budget deleted successfully.")
            } catch {
                print("Error deleting budget file: \(error.localizedDescription)")
            }
        }
}
