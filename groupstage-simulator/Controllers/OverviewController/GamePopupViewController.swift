//
//  GamePopupView.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 22/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class GamePopupViewController: UIViewController {
    
    init(view: View) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        
        self.view.backgroundColor = Color(0, alpha: 0.6).UI
        self.view.addSubview(view)
        
        if let view = view as? GamePopupView {
            view.delegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GamePopupViewController: GamePopupViewDelegate {
    func closeButtonPressed() {
        dismiss(animated: true)
    }
}
