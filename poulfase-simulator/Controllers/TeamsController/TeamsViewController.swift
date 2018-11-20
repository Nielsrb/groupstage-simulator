//
//  TeamsViewController.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class TeamsViewController: UIViewController, Controller {
    
    // Teams model, contains all teams with its players.
    var model = TeamsModel()
    
    let tableView = UITableView()
    
    let cellHeight: CGFloat = 40
    
    init(view: View) {
        super.init(nibName: nil, bundle: nil)
        
        // Generate 4 new teams, can only be done once.
        model.generateTeams()
    }
    
    override func viewDidLoad() {
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: -
// UITableview extensions (delegate + dataSource)
extension TeamsViewController: UITableViewDelegate, UITableViewDataSource {
    // Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: cellHeight))
        view.backgroundColor = .lightGray
        
        let team = model.teams[section]
        
        let nameLabel = UILabel(frame: view.bounds)
        nameLabel.text = team.name
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        /*let line = UIView(frame: CGRect(x: 0, y: view.frame.size.height - 1, width: view.frame.size.width, height: 1))
        line.backgroundColor = .gray
        view.addSubview(line)*/
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.teams.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.teams[section].players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PlayerCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.identifier) as? PlayerCell
        
        if cell == nil {
            cell = PlayerCell()
        }
        
        let player = model.teams[indexPath.section].players[indexPath.row]
        
        cell?.nameLabel.text = "\(player.lastName), \(player.firstName)"
        
        return cell!
    }
}

// MARK: -
// Custom cell(s)

// Custom Player cell
private class PlayerCell: UITableViewCell {
    static let identifier = "PLAYER"
    
    let nameLabel = UILabel()
    
    init() {
        super.init(style: .default, reuseIdentifier: PlayerCell.identifier)
        
        nameLabel.textColor = .black
        addSubview(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
}
