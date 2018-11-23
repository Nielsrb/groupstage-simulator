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
        
        OverviewModel.shared.gameWasSimulatedEvent.bind(self) { id in
            if let view = self.controllerView as? OverviewView {
                view.reloadRowsWith(ids: [id, id+1])
            }
            
//            if let game = OverviewModel.shared.games.first(where: { return $0.id == id }) {
//                let gamePopup = GamePopupView(frame: view.bounds, game: game)
//                self.controllerView.addSubview(gamePopup)
                
//                gamePopup.togglePopup(open: true)
//            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(controllerView)
    }
}
