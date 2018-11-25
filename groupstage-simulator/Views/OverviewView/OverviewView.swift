//
//  OverviewView.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 21-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

protocol OverviewViewDelegate: class {
    func playButtonPressed(id: Int)
}

final class OverviewView: View {
    
    let tableView = UITableView()
    let cellHeight: CGFloat = 70
    let padding: CGFloat = 10
    
    let model = OverviewModel.shared
    
    weak var delegate: OverviewViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.frame = frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadRowsWith(ids: [Int]) {
        let indexPaths = ids.compactMap { id -> IndexPath? in
            let indexPath = IndexPath(row: 0, section: id)
            if tableView.cellForRow(at: indexPath) != nil {
                return indexPath
            }
            return nil
        }
        
        tableView.reloadRows(at: indexPaths, with: .automatic)
        tableView.scrollToRow(at: indexPaths[0], at: .middle, animated: true)
    }
}

// MARK: -
// UITableview extensions (delegate + dataSource)
extension OverviewView: UITableViewDelegate, UITableViewDataSource {
    // Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: padding, y: 0, width: tableView.frame.size.width - (padding*2), height: 50))
        
        let view = UIView(frame: CGRect(x: padding, y: 0, width: tableView.frame.size.width - (padding*2), height: 50))
        view.backgroundColor = Colors.blue.UI
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        header.addSubview(view)
        
        let game = model.games[section]
        
        let versusLabel = UILabel(frame: CGRect(x: (view.frame.size.width - 30) / 2, y: 0, width: 30, height: view.frame.size.height))
        versusLabel.text = "vs"
        versusLabel.textColor = .white
        versusLabel.textAlignment = .center
        versusLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(versusLabel)
        
        let homeLabel = UILabel(frame: CGRect(x: padding, y: 0, width: (view.frame.size.width / 2) - (padding*2) - (versusLabel.frame.size.width / 2), height: view.frame.size.height))
        homeLabel.text = game.homeTeam.name
        homeLabel.textColor = .white
        homeLabel.textAlignment = .left
        homeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(homeLabel)
        
        let awayLabel = UILabel(frame: CGRect(x: (view.frame.size.width / 2) + (versusLabel.frame.size.width / 2) + padding, y: 0, width: (view.frame.size.width / 2) - (padding*2) - (versusLabel.frame.size.width / 2), height: view.frame.size.height))
        awayLabel.text = game.awayTeam.name
        awayLabel.textColor = .white
        awayLabel.textAlignment = .right
        awayLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(awayLabel)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.games.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: GameCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: GameCell.identifier) as? GameCell
        
        if cell == nil {
            cell = GameCell()
        }
        
        let game = model.games[indexPath.section]
        cell?.playButton.tag = indexPath.section
        cell?.delegate = delegate
        
        var isNextMatch = false
        for (index, game) in model.games.enumerated() {
            if game.isSimulated == false {
                if index == indexPath.section {
                    isNextMatch = true
                }
                
                break
            }
        }
        
        if isNextMatch {
            cell?.scoreLabel.isHidden = true
            cell?.playButton.isHidden = false
            
            //cell?.backgroundColor = .white
        } else {
            cell?.scoreLabel.isHidden = !game.isSimulated
            cell?.playButton.isHidden = true
            
            cell?.scoreLabel.text = "\(game.goalsHome) - \(game.goalsAway)"
            //cell?.backgroundColor = Colors.lightGray.UI
        }
        
        return cell!
    }
}

// MARK: -
// Custom cell(s)

// Custom Player cell
private class GameCell: UITableViewCell {
    static let identifier = "GAME"
    
    let scoreLabel = UILabel()
    let playButton = UIButton()
    
    let isNextMatch = false
    let padding: CGFloat = 10
    
    weak var delegate: OverviewViewDelegate?
    
    init() {
        super.init(style: .default, reuseIdentifier: GameCell.identifier)
        
        let background = UIView(frame: CGRect(x: padding, y: 0, width: frame.size.width - (padding*2), height: frame.size.height))
        background.backgroundColor = Colors.lightGray.UI
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        background.layer.cornerRadius = 4
        background.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        addSubview(background)
        
        scoreLabel.textColor = .black
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(scoreLabel)
        
        playButton.backgroundColor = Colors.blue.UI
        playButton.setTitle("PLAY", for: .normal)
        playButton.layer.cornerRadius = 4
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        addSubview(playButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scoreLabel.frame = CGRect(x: 10, y: 0, width: frame.size.width - 20, height: frame.size.height)
        playButton.frame = CGRect(x: frame.size.width * 0.3, y: padding, width: frame.size.width * 0.4, height: frame.size.height - (padding*2))
    }
    
    @objc private func playButtonPressed() {
        delegate?.playButtonPressed(id: playButton.tag)
    }
}
