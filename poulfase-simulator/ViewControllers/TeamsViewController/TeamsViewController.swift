//
//  TeamsViewController.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class TeamsViewController: UIViewController, ViewController {
    init(view: View) {
        super.init(nibName: nil, bundle: nil)
        
        print("Init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
