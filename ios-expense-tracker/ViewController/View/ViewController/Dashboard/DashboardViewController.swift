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
        
            chartView.drawHoleEnabled = true
            chartView.holeColor = .systemBackground
            chartView.holeRadiusPercent = 0.50
            
            chartView.drawEntryLabelsEnabled = false
            
            chartView.legend.enabled = true
            chartView.legend.orientation = .vertical
            chartView.legend.horizontalAlignment = .right
            chartView.legend.verticalAlignment = .bottom
            
            chartView.setExtraOffsets(left: 32, top: 0, right: 32, bottom: 0)
            return chartView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Overview"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(expenseDataDidChange),
            name: .didUpdateExpenses,
            object: nil
        )
        
        setupPieChart()
        refreshChartData(animated: true)
        
    }
    
    deinit {
            NotificationCenter.default.removeObserver(
                self,
                name: .didUpdateExpenses,
                object: nil
            )
        }
    
    @objc private func expenseDataDidChange(){
        refreshChartData(animated: true)
    }
        
    private func setupPieChart(){
        view.addSubview(pieChartView)
        
        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor)
        ])
        
    }

    private func refreshChartData(animated: Bool) {
            
            let allExpense = store.loadExpenses()
            let groupedByCategory = Dictionary(grouping: allExpense, by: { $0.type })
            
            let totalByCategory = groupedByCategory.mapValues { expenses in
                expenses.reduce(Decimal(0)) { $0 + $1.amount }
            }
            
            self.expensesByCategory = totalByCategory.reduce(into: [String: Double]()) { (result, group) in
                let categoryName = group.key.rawValue
                let totalAmount = group.value
                result[categoryName] = (totalAmount as NSDecimalNumber).doubleValue
            }
            
            let dataEntries: [PieChartDataEntry] = expensesByCategory.map { (category, amount) in
                return PieChartDataEntry(value: amount, label: category)
            }
                
            let dataSet = PieChartDataSet(entries: dataEntries)
                
            var colours = ChartColorTemplates.pastel()
            colours.append(contentsOf: ChartColorTemplates.liberty())
            colours.append(contentsOf: ChartColorTemplates.joyful())
            dataSet.colors = colours
                
            dataSet.drawValuesEnabled = true
            dataSet.valueTextColor = .label
            dataSet.valueFont = .systemFont(ofSize: 10, weight: .semibold)
                
            dataSet.valueLinePart1OffsetPercentage = 0.8
            dataSet.valueLinePart1Length = 0.5
            dataSet.valueLinePart2Length = 0.6
            dataSet.yValuePosition = .outsideSlice
                
            dataSet.valueFormatter = PieChartCategoryFormatter()
            
            let data = PieChartData(dataSet: dataSet)
                
            let total = expensesByCategory.values.reduce(0, +)
            let totalString = CurrencyFormatter.shared.string(from: Decimal(total))
            
            let centerText = NSMutableAttributedString(string: "Total\n", attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ])
            centerText.append(NSAttributedString(string: totalString, attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.label
            ]))
            pieChartView.centerAttributedText = centerText
                
            pieChartView.data = data
            
            if animated {
                pieChartView.animate(xAxisDuration: 1.0, easingOption: .easeOutQuad)
            }
        }

}

extension DashboardViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let pieEntry = entry as? PieChartDataEntry, let categoryString = pieEntry.label else { return }
        guard let category = ExpenseType(rawValue: categoryString) else { return }
        
        let expenseForCategory = store.loadExpenses(by: category)
        
        let detailVC = CategoryDetailViewController()
        
        detailVC.categoryName = categoryString
        detailVC.expenses = expenseForCategory
        
        navigationController?.pushViewController(detailVC, animated: true)
        }
}
