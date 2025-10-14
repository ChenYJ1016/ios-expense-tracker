//
//  DatePickerCell.swift
//  ios-expense-tracker
//
//  Created by James Chen on 14/10/25.
//

import UIKit

class DatePickerCell: UITableViewCell{
    
    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .wheels
        dp.translatesAutoresizingMaskIntoConstraints = false
        
        return dp
    }()
    
    var onDateChanged: ((Date) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        datePicker.addAction(UIAction(handler: {[weak self] _ in
            guard let self else { return }
            self.datePickerDidChange(_: datePicker)
        }), for: .valueChanged)
    }
    
    private func datePickerDidChange(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
