//
//  PieChartCategoryFormatter.swift
//  ios-expense-tracker
//
//  Created by James Chen on 28/10/25.
//
import Foundation
import DGCharts

/// This custom formatter takes the `label` of a PieChartDataEntry
/// (which you set as the category name) and uses it as the value text.
public class PieChartCategoryFormatter: ValueFormatter {
    
    public func stringForValue(_ value: Double,
                               entry: ChartDataEntry,
                               dataSetIndex: Int,
                               viewPortHandler: ViewPortHandler?) -> String {
        if let pieEntry = entry as? PieChartDataEntry {
            return pieEntry.label ?? ""
        } else {
            return ""
        }
    }
}
