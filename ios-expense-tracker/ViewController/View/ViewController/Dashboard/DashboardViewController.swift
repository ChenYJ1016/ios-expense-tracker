//
//  DashboardViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 27/10/25.
//

import UIKit
import DGCharts


class DashboardViewController: UIViewController {

    private let store = ExpenseDataStore.shared
    private var expensesByCategory: [String: Double] = [:]

    lazy var pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.delegate = self
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Overview"
        
        expensesByCategory = getExpensesGroupedByCategory()
        setupPieChart()
        
    }
        
    private func setupPieChart(){
        view.addSubview(pieChartView)
        
        pieChartView.drawHoleEnabled = true
        pieChartView.holeColor = .systemBackground
        pieChartView.holeRadiusPercent = 0.50
        
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.entryLabelColor = .black
        pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .regular)
        
        pieChartView.legend.enabled = true
        pieChartView.legend.orientation = .vertical
        pieChartView.legend.horizontalAlignment = .right
        pieChartView.legend.verticalAlignment = .bottom
        
        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeInOutQuad)
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor)
        ])
        
        configureData()
    }

    private func configureData(){
        let dataEntries: [PieChartDataEntry] = expensesByCategory.map { (category, amount) in
            return PieChartDataEntry(value: amount, label: category)
        }
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "Monthly Expenses")
        
        var colours = ChartColorTemplates.pastel()
        colours.append(contentsOf: ChartColorTemplates.liberty())
        dataSet.colors = colours
        
        dataSet.drawValuesEnabled = true
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .semibold)
        
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.4
        dataSet.valueLinePart2Length = 0.4
        dataSet.yValuePosition = .outsideSlice
        
        let data = PieChartData(dataSet: dataSet)
        
        let total = expensesByCategory.values.reduce(0, +)

        let totalString = CurrencyFormatter.shared.string(from: Decimal(total))
        pieChartView.centerAttributedText = NSAttributedString(
            string: "Total\n\(totalString)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        
        pieChartView.data = data
    }
    
    private func getExpensesGroupedByCategory() -> [String: Double]{
        let allExpense = store.loadExpenses()
        
        let groupedByCategory = Dictionary(grouping: allExpense, by: { $0.type })
        
        let totalByCategory = groupedByCategory.mapValues { expenses in
            expenses.reduce(Decimal(0)) { $0 + $1.amount }
        }
        
        let pieChartData = totalByCategory.reduce(into: [String: Double]()) { (result, group) in
            let categoryName = group.key.rawValue
            let totalAmount = group.value
            result[categoryName] = (totalAmount as NSDecimalNumber).doubleValue
        }
        
        return pieChartData
        
    }

}

extension DashboardViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            if let pieEntry = entry as? PieChartDataEntry {
                print("Selected category: \(pieEntry.label ?? "N/A"), Amount: \(pieEntry.value)")
            }
        }
}
