//
//  RoundedProgressView.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import UIKit

class RoundedProgressView: UIProgressView {
    
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        
        // Round the outer track
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // `subviews[0]` is the track view
        // `subviews[1]` is the fill view
        
        guard subviews.count > 1 else { return }
        let fillView = subviews[1]
        
        // Round the fill view's layer
        fillView.layer.cornerRadius = cornerRadius
        fillView.clipsToBounds = true
    }
}

