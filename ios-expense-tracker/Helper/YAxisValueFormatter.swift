//
//  YAxisValueFormatter.swift
//  ios-expense-tracker
//
import UIKit
import DGCharts

public class YAxisValueFormatter: NSObject, AxisValueFormatter {
    
    override public init() {
        super.init()
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // 1. Convert the Double from the chart axis into a Decimal
        let decimalValue = Decimal(value)
        
        // 2. Use your shared CurrencyFormatter
        return CurrencyFormatter.shared.string(from: decimalValue)
    }
}
