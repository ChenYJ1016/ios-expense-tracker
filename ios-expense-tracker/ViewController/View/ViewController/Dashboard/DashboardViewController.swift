//
//  DashboardViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 27/10/25
//

import UIKit
import DGCharts

// A custom gesture recognizer to hold the Goal ID
fileprivate class GoalTapGestureRecognizer: UITapGestureRecognizer {
    var goalID: UUID?
}


class DashboardViewController: UIViewController {

    private let expenseStore = ExpenseDataStore.shared
    private let budgetStore = BudgetDataStore.shared
    private let savingGoalStore = SavingGoalDataStore.shared
    
    // Properties for pie chart
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
    
    // --- Card 2: Saving Goals Components ---
    private lazy var savingGoalsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()
    
    private lazy var addGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.addAction(UIAction(handler: { _ in
            self.addGoalTapped()
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
        navigationItem.largeTitleDisplayMode = .never // Your "sticky title" fix
        view.backgroundColor = .systemGroupedBackground
        
        // Listen for ALL data updates
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidChange), name: .didUpdateBudget, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidChange), name: .didUpdateSavingGoals, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidChange), name: .didUpdateExpenses, object: nil)
        
        setupLayout()
        loadSavedData()
        refreshDashboardData(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            // This is key: make the stack view's width match the scroll view's frame
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
        
        // Now, build the cards and add them to the stack view
        buildDashboardCards()
    }
    
    private func buildDashboardCards() {
        let budgetCard = createBudgetCard()
        let savingsCard = createSavingGoalsCard()
        let spendingCard = createSpendingBreakdownCard()
        
        contentStackView.addArrangedSubview(budgetCard)
        contentStackView.addArrangedSubview(savingsCard)
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
    
    // ---
    // MARK: - Card 2: Saving Goals
    // ---
    
    private func createSavingGoalsCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "SAVING GOALS"
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabel
        
        // Horizontal stack for Title and Add button
        let hStack = UIStackView(arrangedSubviews: [titleLabel, addGoalButton])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        // Main vertical stack for the card
        let mainVStack = UIStackView(arrangedSubviews: [hStack, savingGoalsStackView])
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        mainVStack.axis = .vertical
        mainVStack.spacing = 16
        
        card.addSubview(mainVStack)
        
        NSLayoutConstraint.activate([
            mainVStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainVStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainVStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainVStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    // (UPDATED) This function now contains the "Completed State" logic
    private func createGoalRow(goal: SavingGoal) -> UIView {
        
        // Check if the goal is completed
        let isCompleted = goal.savedAmount >= goal.targetAmount
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let progressLabel = UILabel()
        progressLabel.font = .systemFont(ofSize: 13, weight: .regular)
        progressLabel.textColor = .secondaryLabel
        
        let progressBar = RoundedProgressView(cornerRadius: 5)
        progressBar.trackTintColor = .systemGray5
        
        if isCompleted {
            // --- THIS IS YOUR "COMPLETED" STATE ---
            
            // 1. Icon: Use a checkmark
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
            iconView.tintColor = .systemGreen
            
            // 2. Name: Add a strikethrough (as you suggested!)
            let attributedName = NSAttributedString(
                string: goal.name,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            nameLabel.attributedText = attributedName
            nameLabel.textColor = .secondaryLabel // Fade it out
            
            // 3. Progress Text: Show a "Completed" message
            let total = CurrencyFormatter.shared.string(from: goal.targetAmount)
            progressLabel.text = "Completed! \(total)"
            
            // 4. Progress Bar: Fill it and make it green
            progressBar.progress = 1.0
            progressBar.progressTintColor = .systemGreen
            
        } else {
            // --- THIS IS YOUR NORMAL, "IN-PROGRESS" STATE ---
            
            iconView.image = UIImage(systemName: goal.iconName)
            iconView.tintColor = .systemBlue
            
            nameLabel.text = goal.name
            
            let saved = CurrencyFormatter.shared.string(from: goal.savedAmount)
            let total = CurrencyFormatter.shared.string(from: goal.targetAmount)
            progressLabel.text = "\(saved) / \(total)"
            
            var progress: Float = 0.0
            if goal.targetAmount > 0 {
                progress = (NSDecimalNumber(decimal: goal.savedAmount).floatValue) / (NSDecimalNumber(decimal: goal.targetAmount).floatValue)
            }
            
            progressBar.progress = min(progress, 1.0)
            progressBar.progressTintColor = .systemBlue
        }

        // Layout code
        let labelStack = UIStackView(arrangedSubviews: [nameLabel, progressLabel, progressBar])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        
        let hStack = UIStackView(arrangedSubviews: [iconView, labelStack])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            progressBar.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        return hStack
    }

    // (MODIFIED) This function now adds tap gestures
    private func refreshSavingGoalsCardData() {
        // 1. Clear all old goal rows
        for view in savingGoalsStackView.arrangedSubviews {
            savingGoalsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // 2. Load the goals
        let goals = savingGoalStore.loadSavingGoals()
        
        // 3. Add new rows
        if goals.isEmpty {
            let label = UILabel()
            label.text = "Tap the + to add a saving goal."
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            savingGoalsStackView.addArrangedSubview(label)
        } else {
            for goal in goals {
                let goalRow = createGoalRow(goal: goal)
                
                // --- Make the row tappable ---
                goalRow.isUserInteractionEnabled = true
                let tap = GoalTapGestureRecognizer(target: self, action: #selector(goalTapped))
                tap.goalID = goal.id // Pass the ID
                goalRow.addGestureRecognizer(tap)
                // ---
                
                savingGoalsStackView.addArrangedSubview(goalRow)
            }
        }
    }


    // ---
    // MARK: - Card 3: Spending Breakdown
    // ---
    
    private func createSpendingBreakdownCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "SPENDING BREAKDOWN"
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add components to the card
        card.addSubview(titleLabel)
        card.addSubview(timeRangeSegmentedControl)
        card.addSubview(pieChartView)
        
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            // Segmented Control
            timeRangeSegmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            timeRangeSegmentedControl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            timeRangeSegmentedControl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            // Pie Chart
            pieChartView.topAnchor.constraint(equalTo: timeRangeSegmentedControl.bottomAnchor, constant: 16),
            pieChartView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            pieChartView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            pieChartView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor) // Keep aspect ratio
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
        
        if selectedRange == 0 { // Current Month
            filteredExpenses = allExpenses.filter { $0.date >= startOfCurrentMonth && $0.type != .savings }
        } else { // Previous Months
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
    
    @objc private func refreshDashboardData(animated: Bool) {
        refreshBudgetCardData()
        refreshSavingGoalsCardData()
        refreshSpendingCardData(animated: animated)
    }

    @objc private func dataDidChange(){
        refreshDashboardData(animated: true)
    }
    
    @objc private func timeRangeDidChange() {
        refreshSpendingCardData(animated: true)
    }
    
    private func editBudgetTapped(){
        let budgetVC = BudgetFormController()
        
        budgetVC.delegate = self
        
        let navController = UINavigationController(rootViewController: budgetVC)
        present(navController, animated: true, completion: nil)
    }
    
    // (MODIFIED) This now presents the form correctly
    private func addGoalTapped() {
        let goalVC = SavingGoalFormController()
        goalVC.delegate = self
        goalVC.goalToEdit = nil // Make sure it's in "Add Mode"
        let navController = UINavigationController(rootViewController: goalVC)
        present(navController, animated: true, completion: nil)
    }
    
    // --- (NEW) Action Methods for Edit/Delete ---
    
    @objc private func goalTapped(sender: GoalTapGestureRecognizer) {
            guard let goalID = sender.goalID else {
                print("Error: Tapped goal view has no goalID.")
                return
            }
            
            // (FIXED) Load all goals and find the one that was tapped
            guard let tappedGoal = savingGoalStore.loadSavingGoals().first(where: { $0.id == goalID }) else {
                print("Error: Could not find tapped goal with ID \(goalID)")
                return
            }

            // Create the Action Sheet
            let alert = UIAlertController(title: tappedGoal.name, message: "What would you like to do?", preferredStyle: .actionSheet)
            
            // --- EDIT ACTION ---
            alert.addAction(UIAlertAction(title: "Edit Goal", style: .default, handler: { _ in
                let goalVC = SavingGoalFormController()
                goalVC.delegate = self
                goalVC.goalToEdit = tappedGoal // <-- Pass the goal to the form
                let navController = UINavigationController(rootViewController: goalVC)
                self.present(navController, animated: true)
            }))
            
            // --- DELETE ACTION ---
            alert.addAction(UIAlertAction(title: "Delete Goal", style: .destructive, handler: { _ in
                // Show a confirmation before deleting
                self.showDeleteConfirmation(for: tappedGoal)
            }))
            
            // --- CANCEL ACTION ---
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // Show the menu
            present(alert, animated: true)
        }

    // (NEW) Helper for the "Delete" action
    private func showDeleteConfirmation(for goal: SavingGoal) {
        let alert = UIAlertController(title: "Delete \(goal.name)?", message: "Are you sure you want to delete this goal? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            // Tell the store to delete it
            self.savingGoalStore.deleteSavingGoal(goal)
            // The store's notification will handle the refresh!
        }))
        
        present(alert, animated: true)
    }
    
    // ---
    
    private func loadSavedData(){
        if budgetStore.loadBudget() != nil{
            print("Budget loaded from dataStore")
        }else {
            print("no budget retrieved from store")
        }
    }
    
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

// ---
// MARK: - BudgetFormControllerDelegate
// ---
extension DashboardViewController: BudgetFormControllerDelegate{
    func budgetFormController(didSave budget: Budget) {
        budgetStore.saveBudget(budget)
        // No need to call refresh, notification will handle it
    }
}

// ---
// MARK: - SavingGoalFormControllerDelegate
// ---
extension DashboardViewController: SavingGoalFormControllerDelegate {
    
    func savingGoalFormController(_ controller: SavingGoalFormController, didSaveNew goal: SavingGoal) {
        // Tell the store to save it
        savingGoalStore.addSavingGoal(goal)
        // Dismiss the form
        controller.dismiss(animated: true)
        // The notification from the store will trigger the UI refresh
    }
    
    func savingGoalFormController(_ controller: SavingGoalFormController, didUpdate goal: SavingGoal) {
        // Tell the store to update it
        savingGoalStore.updateSavingGoal(goal)
        // Dismiss the form
        controller.dismiss(animated: true)
        // The notification from the store will trigger the UI refresh
    }
    
    func savingGoalFormControllerDidCancel(_ controller: SavingGoalFormController) {
        // Just dismiss the form
        controller.dismiss(animated: true)
    }
}

