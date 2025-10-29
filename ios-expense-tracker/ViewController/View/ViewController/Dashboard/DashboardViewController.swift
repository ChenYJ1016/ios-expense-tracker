//
//  DashboardViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 27/10/25.
//

import UIKit
import DGCharts

class DashboardViewController: UIViewController {

    private let expenseStore = ExpenseDataStore.shared
    private let budgetStore = BudgetDataStore.shared
    
    private var expensesByCategory: [String: Double] = [:]
    private var expensesForChart: [Expense] = []
    
    // ---
    // MARK: - UI Components
    // ---
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()
    
    // --- Card 1: Budget Components ---
    private lazy var budgetAmountLeftLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "..."
        return label
    }()
    
    private lazy var budgetSpentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "..."
        return label
    }()
    
    private lazy var budgetProgressBar: UIProgressView = {
        let pv = RoundedProgressView(cornerRadius: 8)
        pv.progress = 0.0
        pv.progressTintColor = .systemGreen
        pv.trackTintColor = .systemGray5
        return pv
    }()
    
    private lazy var editBudgetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        button.addAction(UIAction(handler: { _ in
            self.editBudgetTapped()
        }), for: .touchUpInside)
        return button
    }()
    
    // --- Card 3: Spending Components ---
    private lazy var timeRangeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Current Month", "Previous Months"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(timeRangeDidChange), for: .valueChanged)
        return control
    }()
    
    lazy var pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.delegate = self
        
        chartView.drawHoleEnabled = true
        chartView.holeColor = .clear
        chartView.holeRadiusPercent = 0.50
        
        chartView.drawEntryLabelsEnabled = false
        
        chartView.legend.enabled = true
        chartView.legend.orientation = .horizontal
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .bottom
        
        chartView.setExtraOffsets(left: 32, top: 0, right: 32, bottom: 0)
        return chartView
    }()
    
    // ---
    // MARK: - View Lifecycle
    // ---
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Overview"
        
        view.backgroundColor = .systemGroupedBackground
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(expenseDataDidChange),
            name: .didUpdateExpenses,
            object: nil
        )
        
        setupLayout()
        loadSavedData()
        refreshDashboardData(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .didUpdateExpenses,
            object: nil
        )
    }
    
    // ---
    // MARK: - Setup UI
    // ---
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Set scroll view constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Set stack view constraints
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
        
        // Now, build the cards and add them to the stack view
        buildDashboardCards()
    }
    
    /// Creates and adds all the dashboard cards to the stack view
    private func buildDashboardCards() {
        let budgetCard = createBudgetCard()
        
        // We will create the savings card in Step 2
        
        let spendingCard = createSpendingBreakdownCard()
        
        contentStackView.addArrangedSubview(budgetCard)
        // contentStackView.addArrangedSubview(savingsCard) // For Step 2
        contentStackView.addArrangedSubview(spendingCard)
        
        // Add a flexible spacer at the bottom
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentStackView.addArrangedSubview(spacer)
    }

    // ---
    // MARK: - Card 1: Budget Card
    // ---
    
    private func createBudgetCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "MONTHLY BUDGET"
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabel
        
        let hStack = UIStackView(arrangedSubviews: [
            titleLabel,
            editBudgetButton,
        ])
        let vStack = UIStackView(arrangedSubviews: [
            hStack,
            budgetAmountLeftLabel,
            budgetSpentLabel,
            budgetProgressBar,
        ])
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.setCustomSpacing(16, after: budgetSpentLabel)
        
        card.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            budgetProgressBar.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return card
    }
    
    private func refreshBudgetCardData() {

        if let budget = budgetStore.loadBudget() {
            let monthlyIncome = budget.income
            let monthlySavingGoal = budget.savingGoal
            let spendableBudget = monthlyIncome - monthlySavingGoal
            
            let allExpenses = expenseStore.loadExpenses()
            
            let calendar = Calendar.current
            let now = Date()
            guard let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
                return
            }
            let currentMonthExpenses = allExpenses.filter { $0.date >= startOfCurrentMonth }
            
            let currentSpending = currentMonthExpenses
                .filter { $0.type != .savings }
                .reduce(Decimal(0)) { $0 + $1.amount }
            
            let amountLeft = spendableBudget - currentSpending
            
            var progress: Float = 0.0
            if spendableBudget > 0 {

                progress = (NSDecimalNumber(decimal: currentSpending).floatValue) / (NSDecimalNumber(decimal: spendableBudget).floatValue)
            }
            
            if progress > 1.0 {
                budgetProgressBar.progressTintColor = .systemRed
            } else if progress > 0.8 {
                budgetProgressBar.progressTintColor = .systemOrange
            } else {
                budgetProgressBar.progressTintColor = .systemGreen
            }
            

            budgetAmountLeftLabel.text = "\(CurrencyFormatter.shared.string(from: amountLeft)) Left"
            budgetSpentLabel.text = "Spent \(CurrencyFormatter.shared.string(from: currentSpending)) of \(CurrencyFormatter.shared.string(from: spendableBudget))"
            budgetProgressBar.setProgress(progress, animated: true)
            
        } else {
 
            budgetAmountLeftLabel.text = "$0.00 Left"
            budgetSpentLabel.text = "Tap the ✏️ to set your budget"
            budgetProgressBar.setProgress(0, animated: false)
            budgetProgressBar.progressTintColor = .systemGray
        }
    }
    
    private func createSpendingBreakdownCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "SPENDING BREAKDOWN"
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(timeRangeSegmentedControl)
        card.addSubview(pieChartView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            timeRangeSegmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            timeRangeSegmentedControl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            timeRangeSegmentedControl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            pieChartView.topAnchor.constraint(equalTo: timeRangeSegmentedControl.bottomAnchor, constant: 16),
            pieChartView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            pieChartView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            pieChartView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor)
        ])
        
        return card
    }
    
    private func refreshSpendingCardData(animated: Bool) {
        
        let allExpenses = expenseStore.loadExpenses()
        let selectedRange = timeRangeSegmentedControl.selectedSegmentIndex
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            print("Error calculating start of month")
            return
        }

        let filteredExpenses: [Expense]
        
        if selectedRange == 0 {

            filteredExpenses = allExpenses.filter { $0.date >= startOfCurrentMonth && $0.type != .savings }
        } else {
            filteredExpenses = allExpenses.filter { $0.date < startOfCurrentMonth && $0.type != .savings }
        }
        
        self.expensesForChart = filteredExpenses
        
        guard !filteredExpenses.isEmpty else {
            pieChartView.data = nil
            let centerText = NSAttributedString(string: "No spending for this period.", attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ])
            pieChartView.centerAttributedText = centerText
            pieChartView.notifyDataSetChanged()
            return
        }

        let groupedByCategory = Dictionary(grouping: filteredExpenses, by: { $0.type })
        
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
        } else {
            pieChartView.notifyDataSetChanged()
        }
    }
    
    // ---
    // MARK: - Data Logic & Selectors
    // ---
    
    /// Reloads all data for all dashboard cards
    @objc private func refreshDashboardData(animated: Bool) {
        refreshBudgetCardData()
        //refreshSavingGoalsCardData()
        refreshSpendingCardData(animated: animated)
    }

    /// Called when expense data changes
    @objc private func expenseDataDidChange(){
        refreshDashboardData(animated: true)
    }
    
    /// Called when the segmented control (in Card 3) changes
    @objc private func timeRangeDidChange() {
        refreshSpendingCardData(animated: true)
    }
    
    private func editBudgetTapped(){
        let budgetVC = BudgetFormController()
        
        budgetVC.delegate = self
        
        let navController = UINavigationController(rootViewController: budgetVC)
        present(navController, animated: true, completion: nil)
    }
    
    private func loadSavedData(){
        if budgetStore.loadBudget() != nil{
            print("Budget loaded from dataStore")
        }else {
            print("no budget retrieved from store")
        }
    }
    
    // ---
    // MARK: - Helper Functions
    // ---
    
    /// Creates a standardized card view
    private func createCardView() -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 12
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        return cardView
    }
}

// ---
// MARK: - ChartViewDelegate
// ---

extension DashboardViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let pieEntry = entry as? PieChartDataEntry, let categoryString = pieEntry.label else { return }
        guard let category = ExpenseType(rawValue: categoryString) else { return }
        
        let expenseForCategory = self.expensesForChart.filter { $0.type == category }
        
        let detailVC = CategoryDetailViewController()
        
        detailVC.categoryName = categoryString
        detailVC.expenses = expenseForCategory
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension DashboardViewController: BudgetFormControllerDelegate{
    func budgetFormController(didSave budget: Budget) {
        budgetStore.saveBudget(budget)
        refreshDashboardData(animated: true)
    }
}
