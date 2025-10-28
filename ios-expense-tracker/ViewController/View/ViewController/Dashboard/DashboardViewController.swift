//
//  DashboardViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 27/10/25.
//

import UIKit
import DGCharts


class DashboardViewController: UIViewController {

    lazy var pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.delegate = self
        return chartView
    }()
    
    let monthlyExpenses: [String: Double] = [
        "Groceries": 350.00,
        "Bills": 1000.00,
        "Food": 300.00,
        "Transport": 200.00,
        "Misc" : 100.00
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Overview"
        
        setupPieChart()
        
    }
        
    private func setupPieChart(){
        view.addSubview(pieChartView)
        
        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor)
        ])
        setupData()
    }

    private func setupData(){
        let dataEntries: [PieChartDataEntry] = monthlyExpenses.map { (category, amount) in
            return PieChartDataEntry(value: amount, label: category)
            
        }
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "Monthly Expenses")
        
        dataSet.colors = ChartColorTemplates.colorful()
        
        dataSet.drawValuesEnabled = true
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .semibold)
        
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.4
        dataSet.valueLinePart2Length = 0.4
        dataSet.yValuePosition = .outsideSlice
        
        let data = PieChartData(dataSet: dataSet)
        
        pieChartView.drawHoleEnabled = true
        pieChartView.holeColor = .systemBackground
        pieChartView.holeRadiusPercent = 0.50
        
        let total = monthlyExpenses.values.reduce(0, +)

        let totalString = CurrencyFormatter.shared.string(from: Decimal(total))
        pieChartView.centerAttributedText = NSAttributedString(
            string: "Total\n\(totalString)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.entryLabelColor = .black
        pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .regular)
        
        pieChartView.legend.enabled = true
        pieChartView.legend.orientation = .vertical
        pieChartView.legend.horizontalAlignment = .right
        pieChartView.legend.verticalAlignment = .bottom
        
        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeInOutQuad)
        
        pieChartView.data = data
    }

}

extension DashboardViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            // This is called when a user taps on a slice
            if let pieEntry = entry as? PieChartDataEntry {
                print("Selected category: \(pieEntry.label ?? "N/A"), Amount: \(pieEntry.value)")
            }
        }
}
