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
        teamsViewController.tabBarItem =  UITabBarItem(title: "Teams", image: UIImage(named: "ic_team"), selectedImage: UIImage.coloredImage(named: "ic_team", color: Colors.blue))
        
        let overviewViewController = OverviewViewController(view: OverviewView())
        overviewViewController.tabBarItem =  UITabBarItem(title: "Overview", image: UIImage(named: "ic_overview"), selectedImage: UIImage.coloredImage(named: "ic_overview", color: Colors.blue))
        
        tabbarcontroller.viewControllers = [teamsViewController, overviewViewController]
        pushViewController(tabbarcontroller, animated: true)
    }


}

