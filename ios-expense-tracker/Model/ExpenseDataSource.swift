//
//  ExpenseDataSource.swift
//  ios-expense-tracker
//
//  Created by James Chen on 15/10/25.
//
import UIKit

class ExpenseDataSource: UITableViewDiffableDataSource<ExpenseType, Expense> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let type = snapshot().sectionIdentifiers[section]
        return type.rawValue.capitalized
    }
}
