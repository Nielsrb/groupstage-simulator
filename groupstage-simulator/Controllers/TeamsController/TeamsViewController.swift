//
//  TeamsViewController.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class TeamsViewController: UIViewController, Controller {
    
    // Teams model, contains all teams with its players.
    var model = TeamsModel.shared
    
    let controllerView: View
    let tableView = UITableView()
    
    init(view: View) {
        controllerView = view
        
        super.init(nibName: nil, bundle: nil)
        
        // Generate 4 new teams, can only be done once.
        model.generateTeams()
        
        if let view = view as? TeamsView {
            view.delegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(controllerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.title = "Teams"
    }
}

extension TeamsViewController: TeamsViewDelegate {
    func playerPressed(player: PlayerModel) {
        let vc = PlayerPopupViewController(view: PlayerPopupView(frame: view.frame, player: player))
        present(vc, animated: true)
    }
}
