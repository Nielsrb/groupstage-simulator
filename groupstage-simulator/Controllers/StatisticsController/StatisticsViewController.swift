//
//  StatisticsViewController.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 22/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController, Controller {
    
    let controllerView: View
    
    init(view: View) {
        controllerView = view
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(controllerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let view = controllerView as? StatisticsView {
            view.reloadData()
        }
    }
}
