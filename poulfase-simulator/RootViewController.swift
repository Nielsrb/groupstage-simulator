//
//  ViewController.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import UIKit

class RootViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tabbarcontroller = UITabBarController()
        
        let teamsViewController = TeamsViewController(view: TeamsView())
        
        tabbarcontroller.viewControllers = [teamsViewController]
        pushViewController(tabbarcontroller, animated: true)
    }


}

