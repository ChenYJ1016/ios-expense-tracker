//
//  ViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

class ListViewController: UIViewController {

    
    var allExpenses: [Expense] = []
    // UIVIews
    let expenseTableView = UITableView()
    
    private let store = ExpenseDataStore.shared
    private var dataSource: UITableViewDiffableDataSource<ExpenseType, Expense>!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var filteredExpenses: [Expense] = []
    
    private var addButton: UIBarButtonItem!
    private var filterButton: UIBarButtonItem!
    
    private var dateFilterView: UIStackView!
    private var dateFilterButton: UIButton!
    private var dateFilterLabel: UILabel!
    
    private var currentStartDate: Date?
    private var currentEndDate: Date?
    
    private var isSearching: Bool {
        let hasText = !(searchController.searchBar.text?.isEmpty ?? true)
        let hasScope = searchController.searchBar.selectedScopeButtonIndex != 0
        let hasDateFilter = currentStartDate != nil || currentEndDate != nil
        
        return searchController.isActive && (hasText || hasScope || hasDateFilter)
    }
    
    private var scopeTitles: [String] = ["All"] + ExpenseType.allCases.map { $0.rawValue }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        title = "Expenses"
        setupNavigationBar()
        setupSearchController()
        setupDateFilterView()

        setupTableView()

        setupDiffableDataSource()
        allExpenses = store.loadExpenses()
        applySnapshot()
        
    }
    
    
    
    private func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Expenses"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false

        
        searchController.delegate = self
        searchController.searchBar.scopeButtonTitles = scopeTitles
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = false
                
        searchController.searchBar.layoutIfNeeded()

        if let segmentedControl = searchController.searchBar.findSegmentedControl() {
            for (index, type) in ExpenseType.allCases.enumerated() {
                if let icon = UIImage(systemName: type.iconName) {
                    segmentedControl.setImage(icon, forSegmentAt: index + 1)
                }
            }
        }
    }
    
    
    private func setupDateFilterView() {
            dateFilterLabel = UILabel()
            dateFilterLabel.text = "Filter by Date Range"
            dateFilterLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            dateFilterButton = UIButton(type: .system)
            dateFilterButton.setTitle("None ", for: .normal)
            dateFilterButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            dateFilterButton.semanticContentAttribute = .forceRightToLeft
            dateFilterButton.addTarget(self, action: #selector(selectDateTapped), for: .touchUpInside)
            
            dateFilterView = UIStackView(arrangedSubviews: [dateFilterLabel, dateFilterButton])
            dateFilterView.axis = .horizontal
            dateFilterView.spacing = 8
            dateFilterView.alignment = .center
            dateFilterView.isLayoutMarginsRelativeArrangement = true
            dateFilterView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            dateFilterView.backgroundColor = .systemGray6
            
            dateFilterView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dateFilterView)
            
            dateFilterView.isHidden = true
            
            NSLayoutConstraint.activate([
                dateFilterView.topAnchor.constraint(equalTo: view.topAnchor),
                dateFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dateFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
        }
    
    @objc private func selectDateTapped() {
            let dateFilterVC = DateFilterViewController()
            
            dateFilterVC.delegate = self
            dateFilterVC.currentStartDate = self.currentStartDate
            dateFilterVC.currentEndDate = self.currentEndDate
            
            if let sheet = dateFilterVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            present(dateFilterVC, animated: true)
        }
        
        private func updateDateFilterButtonLabel() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            
            if let startDate = currentStartDate, let endDate = currentEndDate {
                let startString = formatter.string(from: startDate)
                let endString = formatter.string(from: endDate)
                dateFilterButton.setTitle("\(startString) - \(endString) ", for: .normal)
            } else {
                dateFilterButton.setTitle("None ", for: .normal)
            }
        }
    
    private func setupNavigationBar(){
        
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewExpense))
        let filterIcon = UIImage(systemName: "line.3.horizontal.decrease.circle")
        filterButton = UIBarButtonItem(image: filterIcon, style: .plain, target: self, action: #selector(filterButtonTapped))
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupTableView() {
        expenseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(expenseTableView)
        
        NSLayoutConstraint.activate([
            expenseTableView.topAnchor.constraint(equalTo: dateFilterView.bottomAnchor),
            expenseTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            expenseTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expenseTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        expenseTableView.delegate = self
        expenseTableView.rowHeight = UITableView.automaticDimension
        expenseTableView.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.identifier)
    }
    
    // MARK: Helper
    
    @objc private func addNewExpense(){
        // add new expense
        let addVC = ExpenseFormController()
        addVC.delegate = self
        let navController = UINavigationController(rootViewController: addVC)
        present(navController, animated: true)
    }
    
    private func updateBackgroundMessage() {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        if allExpenses.isEmpty {
            label.text = "No expenses yet"
        } else if isSearching && filteredExpenses.isEmpty {
            label.text = "No results."
        } else {
            expenseTableView.backgroundView = nil
            return
        }
        expenseTableView.backgroundView = label
    }
    
    @objc private func filterButtonTapped(){
        if searchController.isActive {
            UIView.animate(withDuration: 0.3) {
                self.searchController.searchBar.showsScopeBar.toggle()
                self.searchController.searchBar.sizeToFit()
            }
            self.dateFilterView.isHidden.toggle()

        }
    }
}

extension ListViewController{
    private func setupDiffableDataSource() {
        dataSource = UITableViewDiffableDataSource<ExpenseType, Expense>(tableView: expenseTableView) {
            // Add the explicit type for 'item' here
            tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifier, for: indexPath) as? ExpenseTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: item)
            return cell
        }
        
        dataSource.defaultRowAnimation = .fade
        expenseTableView.dataSource = dataSource
        expenseTableView.delegate = self
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<ExpenseType, Expense>()

        let current = isSearching ? filteredExpenses : allExpenses
        
        // Group items by type (1)
        let grouped = Dictionary(grouping: current, by: { $0.type })

        // Sort types alphabetically (1)
        let sortedTypes = grouped.keys.sorted(by: { $0.rawValue < $1.rawValue })

        // Build snapshot
        snapshot.appendSections(sortedTypes)
        for type in sortedTypes {
            // (2) Force unwrap!
            snapshot.appendItems(grouped[type]!, toSection: type)
        }

            // Apply it to the data source
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        updateBackgroundMessage()
    }
}

extension UIView {
    func findSegmentedControl() -> UISegmentedControl? {
        for subview in self.subviews {
            if let segmentedControl = subview as? UISegmentedControl {
                return segmentedControl
            }
        }
        
        for subview in self.subviews {
            if let segmentedControl = subview.findSegmentedControl() {
                return segmentedControl
            }
        }
        
        return nil
    }
}

extension ListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tappedExpense = dataSource.itemIdentifier(for: indexPath) else {return}
                
        let detailVC = ExpenseDetailViewController(expense: tappedExpense)
        detailVC.delegate = self
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard let expenseToDelete = dataSource.itemIdentifier(for: indexPath) else { return }
        allExpenses.removeAll { $0.id == expenseToDelete.id }
        store.saveExpenses(allExpenses)
        applySnapshot()
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        guard let expense = dataSource.itemIdentifier(for: indexPath) else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { _,_,done in
            self.allExpenses.removeAll { $0.id == expense.id }
            self.store.saveExpenses(self.allExpenses)
            self.applySnapshot()
            done(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

extension ListViewController: ExpenseFormControllerDelegate{
    func didAddExpense(_ expense: Expense) {
        allExpenses.append(expense)
        store.saveExpenses(allExpenses)
        applySnapshot()
    }
}

extension ListViewController: ExpenseDetailViewControllerDelegate{
    func didFinishEditing(expense updatedExpense: Expense) {
        if let index = allExpenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            allExpenses[index] = updatedExpense
            
            store.saveExpenses(allExpenses)
            applySnapshot()
        }
    }
}

extension ListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {

            var filtered = allExpenses
            
            let selectedScopeIndex = searchController.searchBar.selectedScopeButtonIndex
            if selectedScopeIndex > 0 {
                let expenseType = ExpenseType.allCases[selectedScopeIndex - 1]
                filtered = filtered.filter {$0.type == expenseType}
            }
            
            if let searchText = searchController.searchBar.text, !searchText.isEmpty {
                filtered = filtered.filter { expense in
                    expense.name.lowercased().contains(searchText.lowercased())
                }
            }
            
            if let startDate = currentStartDate, let endDate = currentEndDate {

                let startOfDay = Calendar.current.startOfDay(for: startDate)
                let endOfDay = Calendar.current.startOfDay(for: endDate).addingTimeInterval(24*60*60 - 1)

                filtered = filtered.filter { expense in
                    return expense.date >= startOfDay && expense.date <= endOfDay
                }
            }
            
            self.filteredExpenses = filtered
            applySnapshot()
        }

}

extension ListViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = false
        
        currentStartDate = nil
        currentEndDate = nil
        updateDateFilterButtonLabel()
        
        UIView.animate(withDuration: 0.3) {
            self.dateFilterView.isHidden = true
        }
    }
}

extension ListViewController: UISearchControllerDelegate{
    func didPresentSearchController(_ searchController: UISearchController) {
        navigationItem.setRightBarButton(filterButton, animated: true)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationItem.setRightBarButton(addButton, animated: true)
        
        currentStartDate = nil
        currentEndDate = nil
        updateDateFilterButtonLabel()
        
        UIView.animate(withDuration: 0.3) {
            self.searchController.searchBar.showsScopeBar = false
            self.dateFilterView.isHidden = true
        }
    }
}

extension ListViewController: DateFilterViewControllerDelegate {
    
    func didApplyDateFilter(startDate: Date?, endDate: Date?) {

        self.currentStartDate = startDate
        self.currentEndDate = endDate
        
        updateDateFilterButtonLabel()
        
        updateSearchResults(for: searchController)
    }
}

