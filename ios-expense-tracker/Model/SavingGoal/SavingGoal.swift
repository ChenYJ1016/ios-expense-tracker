//
//  SavingGoal.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import Foundation

struct SavingGoal: Identifiable, Codable, Hashable{
    let id: UUID
    var name: String
    var iconName: String
    var savedAmount: Decimal
    var targetAmount: Decimal
    
    init(id: UUID = UUID(), name: String, iconName: String, savedAmount: Decimal, targetAmount: Decimal){
        self.id = id
        self.name = name
        self.iconName = iconName
        self.savedAmount = savedAmount
        self.targetAmount = targetAmount
    }
}
