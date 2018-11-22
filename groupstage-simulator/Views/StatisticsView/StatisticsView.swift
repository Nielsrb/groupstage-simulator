//
//  StatisticsView.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 22/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class StatisticsView: View {
    
    let contentView = UIScrollView()
    let gamesView = UIView()
    
    let rowHeight: CGFloat = 50
    let padding: CGFloat = 10
    let labelWidth: CGFloat = 25
    let fontSize: CGFloat = 14
    
    let model = TeamsModel.shared
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.frame = bounds
        contentView.contentInset.top = padding
        addSubview(contentView)
        
        backgroundColor = .white
        
        let header = UIView(frame: CGRect(x: padding, y: 0, width: frame.size.width - (padding*2), height: 50))
        header.backgroundColor = Colors.blue.UI
        header.layer.cornerRadius = 4
        header.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.addSubview(header)
        
        header.addSubview(designRow(frame: header.bounds, name: "Club", played: "Pld", points: "Pts", balance: "Gd", goals: "Gf", goalsAgainst: "Ga", isHeader: true, hasLine: false))
        
        gamesView.frame = CGRect(x: padding, y: header.frame.size.height, width: frame.size.width - (padding*2), height: frame.size.height - header.frame.size.height)
        contentView.addSubview(gamesView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        designView()
    }
    
    private func designView() {
        // Clear current data
        gamesView.subviews.forEach { $0.removeFromSuperview() }
        
        // Sorting teams by:
        //  - Goals against
        //  - Goals
        //  - Goal balance
        //  - Points
        var filteredTeams = model.teams.sorted(by: { $0.goalsAgainst < $1.goalsAgainst } )
        filteredTeams = filteredTeams.sorted(by: { $0.goals > $1.goals } )
        filteredTeams = filteredTeams.sorted(by:  { ($0.goals - $0.goalsAgainst) > ($1.goals - $1.goalsAgainst) } )
        filteredTeams = filteredTeams.sorted(by: { $0.points > $1.points } )
        
        guard let lastGame = OverviewModel.shared.games.last else {
            return
        }
        
        let groupStageFinished = lastGame.isSimulated
        
        var yPos: CGFloat = 0
        for (index, team) in filteredTeams.enumerated() {
            let row = designRow(frame: CGRect(x: 0, y: yPos, width: gamesView.frame.size.width, height: rowHeight), name: team.name, played: "\(team.played)", points: "\(team.points)", balance: "\(team.goals - team.goalsAgainst)", goals: "\(team.goals)", goalsAgainst: "\(team.goalsAgainst)", hasLine: index != filteredTeams.count - 1)
            gamesView.addSubview(row)
            
            // When the group stage is finished, show what team passed by giving them a golden background.
            if groupStageFinished, index < 2 {
                row.backgroundColor = Colors.gold.UI
            } else {
                row.backgroundColor = Colors.lightGray.UI
            }
            
            if index == filteredTeams.count - 1 {
                row.layer.cornerRadius = 4
                row.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            yPos += rowHeight
        }
        
        yPos += 50
        
        // Some extra information about the group stage.
        //  - Topscorer
        //  - Most assists (optional)
        //  - Most saves, goalkeeper (optional)
        var allPlayers: [PlayerModel] = []
        for team in TeamsModel.shared.teams {
            for player in team.players {
                allPlayers.append(player)
            }
        }
        
        let sortedPlayers = allPlayers.sorted(by: { $0.goals > $1.goals } )
        if let topScorer = sortedPlayers.first {
            let view = UIView(frame: CGRect(x: 0, y: yPos, width: gamesView.frame.size.width, height: rowHeight))
            view.backgroundColor = Colors.lightGray.UI
            view.layer.cornerRadius = 4
            gamesView.addSubview(view)
            
            let goalLabel = UILabel(frame: CGRect(x: view.frame.size.width - 40 - padding, y: (view.frame.size.height - 40) / 2, width: 40, height: 40))
            goalLabel.text = "\(topScorer.goals)"
            goalLabel.textColor = .white
            goalLabel.textAlignment = .center
            goalLabel.backgroundColor = Colors.blue.UI
            goalLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
            goalLabel.layer.cornerRadius = goalLabel.frame.size.height / 2
            goalLabel.clipsToBounds = true
            view.addSubview(goalLabel)
            
            let nameLabel = UILabel(frame: CGRect(x: padding, y: 0, width: view.frame.size.width - goalLabel.frame.size.width - (padding*2), height: view.frame.size.height))
            nameLabel.text = "Most goals: \(topScorer.lastName)"
            nameLabel.textColor = .black
            nameLabel.textAlignment = .left
            nameLabel.font = UIFont.systemFont(ofSize: fontSize)
            view.addSubview(nameLabel)
        }
        
        gamesView.frame.size.height = yPos + padding
    }
    
    private func designRow(frame: CGRect, name: String, played: String, points: String, balance: String, goals: String, goalsAgainst: String, isHeader: Bool = false, hasLine: Bool = true) -> UIView {
        let row = UIView(frame: frame)
        
        let textColor: UIColor = isHeader ? .white : .black
        let font: UIFont = isHeader ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        
        let goalBalanceLabel = UILabel(frame: CGRect(x: frame.size.width - labelWidth - padding, y: 0, width: labelWidth, height: frame.size.height))
        goalBalanceLabel.text = balance
        goalBalanceLabel.textColor = textColor
        goalBalanceLabel.textAlignment = .center
        goalBalanceLabel.font = font
        row.addSubview(goalBalanceLabel)
        
        let goalsAgainstLabel = UILabel(frame: CGRect(x: goalBalanceLabel.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: frame.size.height))
        goalsAgainstLabel.text = goalsAgainst
        goalsAgainstLabel.textColor = textColor
        goalsAgainstLabel.textAlignment = .center
        goalsAgainstLabel.font = font
        row.addSubview(goalsAgainstLabel)
        
        let goalsForLabel = UILabel(frame: CGRect(x: goalsAgainstLabel.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: frame.size.height))
        goalsForLabel.text = goals
        goalsForLabel.textColor = textColor
        goalsForLabel.textAlignment = .center
        goalsForLabel.font = font
        row.addSubview(goalsForLabel)
        
        let pointsLabel = UILabel(frame: CGRect(x: goalsForLabel.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: frame.size.height))
        pointsLabel.text = points
        pointsLabel.textColor = textColor
        pointsLabel.textAlignment = .center
        pointsLabel.font = font
        row.addSubview(pointsLabel)
        
        let playedLabel = UILabel(frame: CGRect(x: pointsLabel.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: frame.size.height))
        playedLabel.text = played
        playedLabel.textColor = textColor
        playedLabel.textAlignment = .center
        playedLabel.font = font
        row.addSubview(playedLabel)
        
        let club = UILabel(frame: CGRect(x: padding, y: 0, width: frame.size.width - padding - playedLabel.frame.origin.x, height: frame.size.height))
        club.text = name
        club.textColor = textColor
        club.textAlignment = .left
        club.font = font
        row.addSubview(club)
        
        if hasLine {
            let line = UIView(frame: CGRect(x: padding, y: frame.size.height - 1, width: frame.size.width - padding, height: 1))
            line.backgroundColor = Colors.darkGray.UI
            row.addSubview(line)
        }
        
        return row
    }
}
