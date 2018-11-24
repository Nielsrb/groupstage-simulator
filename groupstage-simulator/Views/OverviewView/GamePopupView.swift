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
    private var turnsFinished: Int = 0
    private let goalLabel = UILabel()
    
    private var timer: Timer?
    private let speedButton = UIButton()
    private var speed: Int = 1
    
    init(frame: CGRect, game: Game, hasFinished: Bool = false) {
        self.game = game
        super.init(frame: frame)
        
        self.alpha = 0
        self.backgroundColor = Color(0, alpha: 0.6).UI
        
        contentView.frame = CGRect(x: padding, y: frame.size.height * 0.2, width: frame.size.width - (padding*2), height: frame.size.height * 0.6)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: -2.5, height: -2.5)
        contentView.layer.shadowOpacity = 0.3
        contentView.clipsToBounds = false
        addSubview(contentView)
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: cellHeight))
        header.backgroundColor = Colors.blue.UI
        contentView.addSubview(header)
        
        let closeButton = UIButton(frame: CGRect(x: padding, y: padding, width: header.frame.size.height - (padding*2), height: header.frame.size.height - (padding*2)))
        closeButton.setImage(UIImage.coloredImage(named: "ic_close", color: Color(255)), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        header.addSubview(closeButton)
        
        goalLabel.frame = CGRect(x: 0, y: 0, width: header.frame.size.width, height: header.frame.size.height)
        goalLabel.text = "0 - 0"
        goalLabel.textColor = .white
        goalLabel.textAlignment = .center
        goalLabel.font = UIFont.boldSystemFont(ofSize: 18)
        header.addSubview(goalLabel)
        
        let speedButtonHeight = header.frame.size.height - (padding*2)
        speedButton.frame = CGRect(x: header.frame.size.width - padding - speedButtonHeight, y: (header.frame.size.height - speedButtonHeight) / 2, width: speedButtonHeight, height: speedButtonHeight)
        speedButton.setTitle("1x", for: .normal)
        speedButton.setTitleColor(.white, for: .normal)
        speedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        speedButton.backgroundColor = header.backgroundColor
        speedButton.layer.borderColor = UIColor.white.cgColor
        speedButton.layer.borderWidth = 2
        speedButton.layer.cornerRadius = 4
        speedButton.layer.shadowRadius = 4
        speedButton.layer.shadowOffset = CGSize(width: -1, height: -1)
        speedButton.layer.shadowOpacity = 0.3
        speedButton.addTarget(self, action: #selector(speedButtonPressed), for: .touchUpInside)
        header.addSubview(speedButton)
        
        tableView.frame = CGRect(x: 0, y: header.frame.size.height, width: contentView.frame.size.width, height: contentView.frame.size.height - header.frame.size.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = false
        contentView.addSubview(tableView)
        
        fireTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fireTimer() {
        guard turnsFinished < self.game.turns.count else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0 / Double(speed), repeats: true, block: { timer in
            let section = self.turnsFinished <= self.game.turns.count / 2 ? 0 : 1
            let row = self.turnsFinished % (self.game.turns.count / 2)
            
            let goals = OverviewModel.shared.goalsForTurn(turn: self.turnsFinished, inGame: self.game)
            self.goalLabel.text = "\(goals.home) - \(goals.away)"
            
            // Add next turn to the tableview.
            self.turnsFinished += 1
            
            // TODO: scrollToRow is quite buggy, also jumps to top for a split second when the second half/section starts. Needs a fix.
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: true)
            
            //            self.tableView.beginUpdates()
            //            self.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .bottom)
            //            self.tableView.endUpdates()
            
            
            // If game is at half time, stop timer.
            if self.turnsFinished == self.game.turns.count {
                timer.invalidate()
                self.tableView.isUserInteractionEnabled = true
            }
        })
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
    @objc private func closeButtonPressed() {
        togglePopup(open: false)
    }
    
    @objc private func speedButtonPressed() {
        switch speed {
        case 1:
            speed = 2
        case 2:
            speed = 4
        case 4:
            speed = 1
        default:
            speed = 1
        }
        
        speedButton.setTitle("\(speed)x", for: .normal)
        timer?.invalidate()
        fireTimer()
    }
}

extension GamePopupView: UITableViewDelegate, UITableViewDataSource {
    // Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(max(turnsFinished - (section * (game.turns.count / 2)), 0), game.turns.count / 2)
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
        cell?.gameMinute = Int(round(90.0 / Double(game.turns.count) * Double(turnCount)))
        cell?.fromTeam = game.homeTeam.players.contains(turn.fromPlayer) ? .home : .away
        cell?.toTeam = game.homeTeam.players.contains(turn.toPlayer) ? .home : .away
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /*guard section == 1 && max(turnsFinished - (section * (game.turns.count / 2)), 0) != 0 else {
            return nil
        }*/
        
        // scrollToRow seems buggy when using section headers.
        // TODO: Try to find a way to allow section headers without being buggy.
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        view.backgroundColor = .white
        
        let label = UILabel(frame: view.bounds)
        label.text = section == 0 ? "FIRST HALF" : "SECOND HALF"
        label.textColor = Colors.lightGray.UI
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.frame = CGRect(x: (view.frame.size.width - label.frame.size.width) / 2, y: 0, width: label.frame.size.width, height: view.frame.size.height)
        view.addSubview(label)
        
        let leftLine = UIView(frame: CGRect(x: padding, y: (view.frame.size.height - 1) / 2, width: (view.frame.size.width / 2) - padding - (label.frame.size.width / 2) - 5, height: 1))
        leftLine.backgroundColor = Colors.lightGray.UI
        view.addSubview(leftLine)
        
        let rightLine = UIView(frame: CGRect(x: label.frame.origin.x + label.frame.size.width + 5, y: (view.frame.size.height - 1) / 2, width: (view.frame.size.width / 2) - padding - (label.frame.size.width / 2) - 5, height: 1))
        rightLine.backgroundColor = Colors.lightGray.UI
        view.addSubview(rightLine)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 || max(turnsFinished - (section * (game.turns.count / 2)), 0) != 0 ? 30 : 0
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
    
    private let padding: CGFloat = 10
    
    private let turnLabel = UILabel()
    private let turnImageView = UIImageView()
    private let timeLabel = UILabel()
    //private let line = UIView()
    
    var fromTeam: Teams = .home
    var toTeam: Teams = .away
    var turn: Turn?
    var gameMinute: Int = 1
    
    init() {
        super.init(style: .default, reuseIdentifier: GameTurnCell.identifier)
        
        turnLabel.textColor = .black
        turnLabel.font = UIFont.systemFont(ofSize: 14)
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
        
        //line.backgroundColor = Colors.lightGray.UI
        //addSubview(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        timeLabel.frame = CGRect(x: (frame.size.width - 30) / 2, y: (frame.size.height - 30) / 2, width: 30, height: 30)
        timeLabel.text = "\(gameMinute)"
        timeLabel.layer.cornerRadius = timeLabel.frame.size.height / 2
        
        guard let turn = turn else {
            return
        }
        
        var textSide: Teams = fromTeam
        
        if turn.goal { // fromPlayer scored
            turnLabel.text = "\(turn.fromPlayer.firstName.first!). \(turn.fromPlayer.lastName) scored!"
        } else {
            if fromTeam == toTeam { // toPlayer succesfully passes to fromPlayer
                turnLabel.text = "\(turn.fromPlayer.firstName.first!). \(turn.fromPlayer.lastName) passed to \(turn.toPlayer.firstName.first!). \(turn.toPlayer.lastName)."
            } else if turn.toPlayer.position.1 == 0 { // fromPlayer shot on goal, missed
                turnLabel.text = "\(turn.fromPlayer.firstName.first!). \(turn.fromPlayer.lastName) shoots on goal! But misses."
            } else { // toPlayer intercepted the ball
                turnLabel.text = "\(turn.toPlayer.firstName.first!). \(turn.toPlayer.lastName) intercepts."
                textSide = fromTeam == .home ? .away : .home
            }
        }
        
        let labelWidth = (frame.size.width / 2) - (frame.size.height * 0.5) - padding
        turnLabel.frame = CGRect(x: textSide == .home ? padding : padding + labelWidth + frame.size.height, y: 0, width: labelWidth, height: frame.size.height)
        turnLabel.textAlignment = textSide == .home ? .left : .right
        
        /*if gameMinute != 44 {
            line.frame = CGRect(x: 10, y: frame.size.height - 1, width: frame.size.width - 20, height: 1)
        } else {
            line.frame = CGRect.zero
        }*/
    }
}
