//
//  ExpenseTableViewCell.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    static let identifier: String = "ExpenseTableViewCell"
    
    // labels
    let expenseNameLabel = UILabel()
    let expenseDateLabel = UILabel()
    let expenseAmountLabel = UILabel()
    let expenseTypeLabel = UILabel()
    
    let cellStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with expense: Expense){
        expenseNameLabel.text = expense.name
        expenseTypeLabel.text = expense.type.rawValue.capitalized
        expenseAmountLabel.text = CurrencyFormatter.shared.string(from: expense.amount)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        expenseDateLabel.text = dateFormatter.string(from: expense.date)
        
    }
    
    private func setupUI(){
        cellStackView.axis = .vertical
        cellStackView.spacing = 4
        cellStackView.translatesAutoresizingMaskIntoConstraints = false
        
        expenseNameLabel.font = .boldSystemFont(ofSize: 18)
        expenseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        expenseAmountLabel.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        expenseAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        expenseDateLabel.font = .systemFont(ofSize: 14)
        expenseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        expenseDateLabel.textColor = .gray
        
        expenseTypeLabel.font = .systemFont(ofSize: 14)
        expenseTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cellStackView.addArrangedSubview(expenseNameLabel)
        cellStackView.addArrangedSubview(expenseDateLabel)
        cellStackView.addArrangedSubview(expenseTypeLabel)
        
        contentView.addSubview(cellStackView)
        contentView.addSubview(expenseAmountLabel)
        
        NSLayoutConstraint.activate([
                    cellStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    cellStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                    cellStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
                    expenseAmountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                    expenseAmountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                        cellStackView.trailingAnchor.constraint(lessThanOrEqualTo: expenseAmountLabel.leadingAnchor, constant: -8)
        ])
    }

}
