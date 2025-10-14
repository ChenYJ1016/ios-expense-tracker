//
//  PickerViewCell.swift
//  ios-expense-tracker
//
//  Created by James Chen on 14/10/25.
//

import UIKit

class PickerViewCell: UITableViewCell {

    let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
