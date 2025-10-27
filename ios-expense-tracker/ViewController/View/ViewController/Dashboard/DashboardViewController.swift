//
//  DashboardViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 27/10/25.
//

import UIKit
import DGCharts


class DashboardViewController: UIViewController {

    // 2. Create a chart view, like a BarChartView
        lazy var barChartView: BarChartView = {
            let chartView = BarChartView()
            chartView.translatesAutoresizingMaskIntoConstraints = false
            return chartView
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white
            view.addSubview(barChartView)
            
            // 3. Add constraints
            NSLayoutConstraint.activate([
                barChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                barChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                barChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                barChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
            
            // 4. Set up your chart data
            setData()
        }
        
        func setData() {
            let entries = [
                BarChartDataEntry(x: 1.0, y: 10.0),
                BarChartDataEntry(x: 2.0, y: 20.0),
                BarChartDataEntry(x: 3.0, y: 15.0)
            ]
            
            let dataSet = BarChartDataSet(entries: entries, label: "My Data")
            let data = BarChartData(dataSet: dataSet)
            
            barChartView.data = data
            
            // Customize the chart
            dataSet.colors = [.systemBlue]
            barChartView.rightAxis.enabled = false
            barChartView.animate(yAxisDuration: 1.0)
        }

}
