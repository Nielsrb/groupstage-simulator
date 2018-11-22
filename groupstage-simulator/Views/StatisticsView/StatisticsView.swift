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
    
    let padding: CGFloat = 10
    let labelWidth: CGFloat = 25
    let fontSize: CGFloat = 14
    
    var games = OverviewModel.shared.games
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.frame = bounds
        addSubview(contentView)
        
        backgroundColor = .white
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 50))
        header.backgroundColor = Colors.blue.UI
        contentView.addSubview(header)
        
        let goalBalance = UILabel(frame: CGRect(x: header.frame.size.width - labelWidth - padding, y: 0, width: labelWidth, height: header.frame.size.height))
        goalBalance.text = "Gd"
        goalBalance.textColor = .white
        goalBalance.textAlignment = .center
        goalBalance.font = UIFont.boldSystemFont(ofSize: fontSize)
        header.addSubview(goalBalance)
        
        let goalsAgainst = UILabel(frame: CGRect(x: goalBalance.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: header.frame.size.height))
        goalsAgainst.text = "Ga"
        goalsAgainst.textColor = .white
        goalsAgainst.textAlignment = .center
        goalsAgainst.font = UIFont.boldSystemFont(ofSize: fontSize)
        header.addSubview(goalsAgainst)
        
        let goalsFor = UILabel(frame: CGRect(x: goalsAgainst.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: header.frame.size.height))
        goalsFor.text = "Gf"
        goalsFor.textColor = .white
        goalsFor.textAlignment = .center
        goalsFor.font = UIFont.boldSystemFont(ofSize: fontSize)
        header.addSubview(goalsFor)
        
        let points = UILabel(frame: CGRect(x: goalsFor.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: header.frame.size.height))
        points.text = "Pts"
        points.textColor = .white
        points.textAlignment = .center
        points.font = UIFont.boldSystemFont(ofSize: fontSize)
        header.addSubview(points)
        
        let played = UILabel(frame: CGRect(x: points.frame.origin.x - labelWidth - padding, y: 0, width: labelWidth, height: header.frame.size.height))
        played.text = "Pld"
        played.textColor = .white
        played.textAlignment = .center
        played.font = UIFont.boldSystemFont(ofSize: fontSize)
        header.addSubview(played)
        
        let club = UILabel(frame: CGRect(x: padding, y: 0, width: header.frame.size.width - padding - played.frame.origin.x, height: header.frame.size.height))
        club.text = "Club"
        club.textColor = .white
        club.textAlignment = .left
        club.font = UIFont.boldSystemFont(ofSize: fontSize)
        header.addSubview(club)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        games = OverviewModel.shared.games
        
        designView()
    }
    
    private func designView() {
        // Clear current data
        gamesView.subviews.forEach { $0.removeFromSuperview() }
        
        
    }
}
