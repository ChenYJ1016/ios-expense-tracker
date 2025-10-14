//
//  FormInputCell.swift
//  ios-expense-tracker
//
//  Created by James Chen on 14/10/25.
//

import UIKit

class TextFieldCell: UITableViewCell {

    let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        return tf
    }()
    
    var onTextChanged: ((String?) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        textField.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            self.textFieldDidChange(_: textField)
        }), for: .editingChanged)
    }
    
    private func textFieldDidChange(_ textField: UITextField) {
        onTextChanged?(textField.text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
