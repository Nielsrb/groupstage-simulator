//
//  OverviewViewController.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 21-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class OverviewViewController: UIViewController, Controller {
    
    let controllerView: View
    let cellHeight: CGFloat = 100
    
    init(view: View) {
        controllerView = view
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .white
        
        OverviewModel.shared.generateGames()
    }
    
    override func viewDidLoad() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
