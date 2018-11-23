//
//  GamePopupView.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 22/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class GamePopupView: UIView {
    private let contentView = UIView()
    private let tableView = UITableView()
    
    private let padding: CGFloat = 10
    private let cellHeight: CGFloat = 50
    
    private let game: Game
    private var timer = Timer()
    private var turnsFinished: Int = 0
    
    init(frame: CGRect, game: Game, hasFinished: Bool = false) {
        self.game = game
        super.init(frame: frame)
        
        self.alpha = 0
        self.backgroundColor = Color(0, alpha: 0.6).UI
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        
        contentView.frame = CGRect(x: padding, y: frame.size.height * 0.2, width: frame.size.width - (padding*2), height: frame.size.height * 0.6)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        addSubview(contentView)
        
        tableView.frame = contentView.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        contentView.addSubview(tableView)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            let section = self.turnsFinished <= self.game.turns.count / 2 ? 0 : 1
            self.turnsFinished += 1
            self.tableView.numberOfRows(inSection: min(max(self.turnsFinished - (section * self.game.turns.count) , 0), game.turns.count / 2))
            self.tableView.insertRows(at: [IndexPath(row: self.turnsFinished, section: section)], with: .bottom)
            
            if self.turnsFinished % (self.game.turns.count / 2) == 0 {
                timer.invalidate()
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func togglePopup(open: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = open ? 1 : 0
        }, completion: { _ in
            if !open {
                self.removeFromSuperview()
            }
        })
    }
    
    // MARK: - Targets
    @objc private func backgroundTapped() {
        togglePopup(open: false)
    }
}

extension GamePopupView: UITableViewDelegate, UITableViewDataSource {
    // Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: GameTurnCell.identifier) as? GameTurnCell
        
        if cell == nil {
            cell = GameTurnCell()
        }
        
        let turnCount = indexPath.row + (indexPath.section * (game.turns.count / 2))
        let turn = game.turns[turnCount]
        
        cell?.turn = turn
        cell?.gameMinute = turnCount
        cell?.holdingTeam = game.holdingTeam
        
        return cell!
    }
    
    // Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

fileprivate final class GameTurnCell: UITableViewCell {
    static let identifier = "TURN"
    
    private let turnLabel = UILabel()
    private let turnImageView = UIImageView()
    private let timeLabel = UILabel()
    private let line = UIView()
    
    var holdingTeam: Teams = .home
    var turn: Turn?
    var gameMinute: Int = 1
    
    init() {
        super.init(style: .default, reuseIdentifier: GameTurnCell.identifier)
        
        turnLabel.textColor = .black
        turnLabel.font = UIFont.systemFont(ofSize: 18)
        turnLabel.numberOfLines = 2
        addSubview(turnLabel)
        
        turnImageView.contentMode = .scaleAspectFit
        addSubview(turnImageView)
        
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        timeLabel.backgroundColor = Colors.blue.UI
        timeLabel.clipsToBounds = true
        addSubview(timeLabel)
        
        line.backgroundColor = Colors.lightGray.UI
        addSubview(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        timeLabel.frame = CGRect(x: (frame.size.width - frame.size.height) / 2, y: (frame.size.height - 30) / 2, width: 30, height: 30)
        timeLabel.text = "\(gameMinute)"
        timeLabel.layer.cornerRadius = timeLabel.frame.size.height / 2
        
        let labelWidth = (frame.size.width / 2) - (frame.size.height * 1.5)
        turnLabel.frame = CGRect(x: holdingTeam == .home ? frame.size.height : labelWidth + (frame.size.height / 2), y: 0, width: labelWidth, height: frame.size.height)
        turnLabel.textAlignment = holdingTeam == .home ? .left : .right
        
        guard let turn = turn else {
            return
        }
        
        if turn.goal { // fromPlayer scored
            turnLabel.text = "\(turn.fromPlayer.firstName.first!). \(turn.fromPlayer.lastName) scored!"
        } else {
            if turn.fromPlayer.position.1 > turn.toPlayer.position.1 { // toPlayer succesfully passes to fromPlayer
                turnLabel.text = "\(turn.fromPlayer.firstName.first!). \(turn.fromPlayer.lastName) passed to \(turn.toPlayer.firstName.first!). \(turn.toPlayer.lastName)."
            } else if turn.toPlayer.position.1 == 0 { // fromPlayer shot on goal, missed
                turnLabel.text = "\(turn.fromPlayer.firstName.first!). \(turn.fromPlayer.lastName) shoots on goal! But misses."
            } else { // toPlayer intercepted the ball
                turnLabel.text = "\(turn.toPlayer.firstName.first!). \(turn.toPlayer.lastName) intercepts \(turn.fromPlayer.firstName.first!). \(turn.fromPlayer.lastName) pass."
                turnLabel.frame.origin.x = (frame.size.height*2) + labelWidth
            }
        }
        
        line.frame = CGRect(x: 10, y: frame.size.height - 1, width: frame.size.width - 20, height: 1)
    }
}
