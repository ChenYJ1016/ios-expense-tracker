//
//  XAxisMonthFormatter.swift
//  ios-expense-tracker
//
//  Created by James Chen on 30/10/25.
//
import UIKit
import DGCharts

public class XAxisMonthFormatter: NSObject, AxisValueFormatter {
    
    private let months: [String]
    
    init(months: [String]) {
        self.months = months
        super.init()
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        
        // Safety check to prevent crashing if the index is out of bounds
        guard index >= 0 && index < months.count else {
            return ""
        }
        
        return months[index]
    }
}
