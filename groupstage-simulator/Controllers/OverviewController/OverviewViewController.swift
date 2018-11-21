//
//  OverviewViewController.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 21-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class OverviewViewController: UIViewController, Controller {
    
    let controllerView: View
    
    init(view: View) {
        controllerView = view
        
        super.init(nibName: nil, bundle: nil)
        
        OverviewModel.shared.generateGames()
        
        OverviewModel.shared.gameWasSimulatedEvent.bind(self) {
            self.controllerView.shouldRefresh()
        }
    }
    
    override func viewDidLoad() {
        view.addSubview(controllerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
