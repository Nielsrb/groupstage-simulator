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
    
    let rowHeight: CGFloat = 30
    let padding: CGFloat = 10
    let labelWidth: CGFloat = 25
    let fontSize: CGFloat = 14
    
    let model = TeamsModel.shared
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.frame = bounds
        addSubview(contentView)
        
        backgroundColor = .white
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 50))
        header.backgroundColor = Colors.blue.UI
        contentView.addSubview(header)
        
        header.addSubview(designRow(frame: header.bounds, name: "Club", played: "Pld", points: "Pts", balance: "Gd", goals: "Gf", goalsAgainst: "Ga", isHeader: true))
        
        gamesView.frame = CGRect(x: 0, y: header.frame.size.height, width: frame.size.width, height: frame.size.height - header.frame.size.height)
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
            let row = designRow(frame: CGRect(x: 0, y: yPos, width: gamesView.frame.size.width, height: rowHeight), name: team.name, played: "\(team.played)", points: "\(team.points)", balance: "\(team.goals - team.goalsAgainst)", goals: "\(team.goals)", goalsAgainst: "\(team.goalsAgainst)")
            gamesView.addSubview(row)
            
            if groupStageFinished, index < 2 {
                row.backgroundColor = Colors.gold.UI
            }
            
            yPos += rowHeight
        }
        //gamesView.frame.size.height = 
    }
    
    private func designRow(frame: CGRect, name: String, played: String, points: String, balance: String, goals: String, goalsAgainst: String, isHeader: Bool = false) -> UIView {
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
        
        return row
    }
}
