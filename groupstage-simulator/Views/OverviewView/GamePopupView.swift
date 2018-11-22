//
//  GamePopupView.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 22/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class GamePopupView: UIView {
    
    let contentView = UIView()
    let padding: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alpha = 0
        self.backgroundColor = Color(0, alpha: 0.6).UI
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        
        contentView.frame = CGRect(x: padding, y: frame.size.height * 0.2, width: frame.size.width - (padding*2), height: frame.size.height * 0.6)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func togglePopup(open: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = open ? 1 : 0
        }, completion: { _ in
            if !open {
                self.removeFromSuperview()
            }
        })
    }
    
    // MARK: - Targets
    @objc private func backgroundTapped() {
        togglePopup(open: false)
    }
}
