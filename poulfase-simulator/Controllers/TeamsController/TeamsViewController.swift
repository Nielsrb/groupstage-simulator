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
    
    let cellHeight: CGFloat = 50
    
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
        view.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        let team = model.teams[section]
        let powerViewSize: CGFloat = 35
        
        let nameLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: view.frame.size.height))
        nameLabel.text = team.name
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        let powerLabel = UILabel(frame: CGRect(x: view.frame.size.width - powerViewSize - 10, y: (view.frame.size.height - powerViewSize) / 2, width: powerViewSize, height: powerViewSize))
        powerLabel.text = "\(team.power)"
        powerLabel.textColor = .black
        powerLabel.textAlignment = .center
        view.addSubview(powerLabel)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
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
        
        let nameText = NSMutableAttributedString(string: "\(player.firstName) ")
        nameText.append(NSMutableAttributedString(string: "\(player.lastName)").bold(size: 14))
        
        cell?.nameLabel.attributedText = nameText
        cell?.powerLabel.text = "\(player.power)"
        
        return cell!
    }
}

// MARK: -
// Custom cell(s)

// Custom Player cell
private class PlayerCell: UITableViewCell {
    static let identifier = "PLAYER"
    
    let nameLabel = UILabel()
    let powerLabel = UILabel()
    
    let padding: CGFloat = 10
    let powerViewSize: CGFloat = 35
    
    init() {
        super.init(style: .default, reuseIdentifier: PlayerCell.identifier)
        
        nameLabel.textColor = .black
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(nameLabel)
        
        powerLabel.textColor = .black
        powerLabel.textAlignment = .center
        powerLabel.font = UIFont.systemFont(ofSize: 18)
        //powerLabel.backgroundColor = .green
        powerLabel.layer.cornerRadius = 4
        powerLabel.clipsToBounds = true
        addSubview(powerLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.frame = CGRect(x: 10, y: 0, width: frame.size.width - 10 - powerViewSize - 10, height: frame.size.height)
        
        powerLabel.sizeToFit()
        powerLabel.frame = CGRect(x: frame.size.width - powerViewSize - 10, y: (frame.size.height - powerViewSize) / 2, width: powerViewSize, height: powerViewSize)
        powerLabel.backgroundColor = Int(powerLabel.text ?? "") ?? 50 >= 100 ? .yellow : .green
    }
    
    private func getColorForPower(power: Int) -> UIColor {
        if power >= 100 {
            return .yellow
        } else {
            return .green
        }
    }
}
