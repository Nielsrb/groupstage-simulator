//
//  TeamView.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

protocol TeamsViewDelegate: class {
    func playerPressed(player: PlayerModel)
}

final class TeamsView: View {
    
    let tableView = UITableView()
    let cellHeight: CGFloat = 50
    
    let model = TeamsModel.shared
    
    weak var delegate: TeamsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        tableView.frame = CGRect(x: 10, y: 0, width: frame.size.width - 20, height: frame.size.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// UITableview extensions (delegate + dataSource)
extension TeamsView: UITableViewDelegate, UITableViewDataSource {
    // Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: cellHeight))
        view.backgroundColor = Colors.blue.UI
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let team = model.teams[section]
        let powerViewSize: CGFloat = 35
        
        let nameLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: view.frame.size.height))
        nameLabel.text = team.name
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(nameLabel)
        
        let powerLabel = UILabel(frame: CGRect(x: view.frame.size.width - powerViewSize - 10, y: (view.frame.size.height - powerViewSize) / 2, width: powerViewSize, height: powerViewSize))
        powerLabel.text = "\(team.power)"
        powerLabel.textColor = .white
        powerLabel.textAlignment = .center
        powerLabel.font = UIFont.boldSystemFont(ofSize: 18)
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
        
        let player = model.teams[indexPath.section].players[indexPath.row]
        delegate?.playerPressed(player: player)
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
        cell?.position = player.position
        
        return cell!
    }
}

// MARK: -
// Custom cell(s)

// Custom Player cell
private class PlayerCell: UITableViewCell {
    static let identifier = "PLAYER"
    
    let background = UIView()
    let nameLabel = UILabel()
    let powerLabel = UILabel()
    let positionLabel = UILabel()
    
    var position: (Int, Int) = (0, 0)
    let padding: CGFloat = 10
    let infoViewSize: CGFloat = 35
    let positionViewSize: CGFloat = 45
    
    init() {
        super.init(style: .default, reuseIdentifier: PlayerCell.identifier)
        
        contentView.backgroundColor = Colors.lightGray.UI
        contentView.layer.cornerRadius = 4
        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        nameLabel.textColor = .black
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(nameLabel)
        
        powerLabel.textColor = .black
        powerLabel.textAlignment = .center
        powerLabel.font = UIFont.systemFont(ofSize: 18)
        //powerLabel.backgroundColor = .green
        powerLabel.layer.cornerRadius = 4
        powerLabel.clipsToBounds = true
        contentView.addSubview(powerLabel)
        
        positionLabel.textColor = .white
        positionLabel.textAlignment = .center
        positionLabel.font = UIFont.systemFont(ofSize: 18)
        positionLabel.backgroundColor = Colors.darkGray.UI
        positionLabel.layer.cornerRadius = 4
        positionLabel.clipsToBounds = true
        contentView.addSubview(positionLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width - 10 - infoViewSize - 10, height: contentView.frame.size.height)
        
        powerLabel.sizeToFit()
        powerLabel.frame = CGRect(x: contentView.frame.size.width - infoViewSize - 10, y: (contentView.frame.size.height - infoViewSize) / 2, width: infoViewSize, height: infoViewSize)
        powerLabel.backgroundColor = Int(powerLabel.text ?? "") ?? 50 >= 100 ? Colors.gold.UI : Colors.green.UI
        
        positionLabel.frame = CGRect(x: powerLabel.frame.origin.x - 10 - positionViewSize, y: (contentView.frame.size.height - infoViewSize) / 2, width: positionViewSize, height: infoViewSize)
        positionLabel.text = getStringForPosition(position: position)
    }
    
    private func getColorForPower(power: Int) -> UIColor {
        if power >= 100 {
            return .yellow
        } else {
            return .green
        }
    }
    
    func getColorForPosition(position: (Int, Int)) -> UIColor {
        switch position.1 {
        case 0: // keeper
            return .black
        case 1: // defender
            return .green
        case 2: // midfielder
            return .orange
        case 3: // forwarder
            return .red
        default:
            return .black
        }
    }
    
    func getStringForPosition(position: (Int, Int)) -> String {
        switch position.1 {
        case 0: // keeper
            return "GK"
        case 1: // defender
            return "DEF"
        case 2: // midfielder
            return "MID"
        case 3: // forwarder
            return "FW"
        default:
            return "GK"
        }
    }
}
