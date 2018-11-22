//
//  ViewController.swift
//  groupstage-simulator
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
        
        let teamsViewController = TeamsViewController(view: TeamsView(frame: view.bounds))
        teamsViewController.tabBarItem = UITabBarItem(title: "Teams", image: UIImage(named: "ic_team"), selectedImage: UIImage.coloredImage(named: "ic_team", color: Colors.blue))
        
        let overviewViewController = OverviewViewController(view: OverviewView(frame: view.bounds))
        overviewViewController.tabBarItem = UITabBarItem(title: "Overview", image: UIImage(named: "ic_overview"), selectedImage: UIImage.coloredImage(named: "ic_overview", color: Colors.blue))
        
        let statistiscViewController = StatisticsViewController(view: StatisticsView(frame: view.bounds))
        statistiscViewController.tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(named: "ic_statistics"), selectedImage: UIImage.coloredImage(named: "ic_statistics", color: Colors.blue))
        
        tabbarcontroller.viewControllers = [teamsViewController, overviewViewController, statistiscViewController]
        pushViewController(tabbarcontroller, animated: true)
    }


}

