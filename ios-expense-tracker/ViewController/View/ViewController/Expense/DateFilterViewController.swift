//
//  DateFilterViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 24/10/25.
//

import UIKit

protocol DateFilterViewControllerDelegate: AnyObject {
    /// Passes the selected date range back. `nil` for both means the filter was cleared.
    func didApplyDateFilter(startDate: Date?, endDate: Date?)
}

class DateFilterViewController: UIViewController {
    
    weak var delegate: DateFilterViewControllerDelegate?
    
    var currentStartDate: Date?
    var currentEndDate: Date?
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Date Range"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let startLabel: UILabel = {
        let label = UILabel()
        label.text = "Start Date"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private lazy var startPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.date = currentStartDate ?? Date()
        
        picker.addAction(UIAction(handler: {[weak self] _ in
            self?.startDatePickerChanged()
        }), for: .valueChanged)
        return picker
    }()
    
    private func startDatePickerChanged() {
        endPicker.minimumDate = startPicker.date
        
        if endPicker.date < startPicker.date {
            endPicker.date = startPicker.date
        }
    }
    private let endLabel: UILabel = {
        let label = UILabel()
        label.text = "End Date"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private lazy var endPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.date = currentEndDate ?? Date()
        return picker
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Filter", for: .normal)
        button.tintColor = .systemRed
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.tintColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupLayout()
        endPicker.minimumDate = startPicker.date
    }
    
    
    private func setupLayout() {
        let buttonStack = UIStackView(arrangedSubviews: [clearButton, cancelButton, applyButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16
        
        applyButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            startLabel,
            startPicker,
            endLabel,
            endPicker,
            buttonStack
        ])
        
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    
    @objc private func applyTapped() {
        delegate?.didApplyDateFilter(startDate: startPicker.date, endDate: endPicker.date)
        dismiss(animated: true)
    }
    
    @objc private func clearTapped() {
        delegate?.didApplyDateFilter(startDate: nil, endDate: nil)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
