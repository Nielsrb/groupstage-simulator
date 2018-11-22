//
//  PlayerModel.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 22/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

private let playerFirstNames = ["Robert", "Bill", "Evan", "Richard", "Pepper", "Mauro", "Lucas", "Niels"]
private let playerLastNames = ["Wood", "Shizuke", "Mulder", "Ndidi", "Lee", "San Giorgi", "van der Sloot"]
private var playerNames: [String] = []

struct PlayerModel: Equatable {
    var firstName: String = ""
    var lastName: String = ""
    var age: Int = 0
    var power: Int = 0
    var position: (Int, Int) = (0, 0)
    
    mutating func configure(formation: Formations, position: Int) {
        let names = generatePlayerName()
        self.firstName = names.firstName
        self.lastName = names.lastName
        
        self.age = Int.random(in: 18 ... 36)
        self.power = Int.random(in: 50...100)
        
        self.position = positionForPlayer(formation: formation, position: position)
    }

    static func == (lhs: PlayerModel, rhs: PlayerModel) -> Bool {
        return ("\(lhs.firstName) \(lhs.lastName)") == ("\(rhs.firstName) \(rhs.lastName)")
    }
    
    private func positionForPlayer(formation: Formations, position: Int) -> (Int, Int) {
        var form = (2, 4, 4)
        
        switch formation {
        case .A:
            form = (2, 4, 4)
        case .B:
            form = (3, 3, 4)
            break
        case .C:
            form = (4, 2, 4)
            break
        case .D:
            form = (1, 4, 5)
            break
        case .E:
            form = (3, 4, 3)
            break
        }
        
        // Calculate position for a player
        if position < form.0 { // player is in first row (forwarder)
            let playerSpace: CGFloat = 9 / CGFloat(form.0)
            let locInPlayerSpace: CGFloat = playerSpace / 2
            let totalLoc: CGFloat = (playerSpace * CGFloat(position)) + locInPlayerSpace
            let xPos = Int(floor(totalLoc))
            
            return (xPos, 3)
        } else if position < (form.0 + form.1) { // player is in second row (midfielder)
            let pos = position - form.0
            let playerSpace: CGFloat = 9 / CGFloat(form.1)
            let locInPlayerSpace: CGFloat = playerSpace / 2
            let totalLoc: CGFloat = (playerSpace * CGFloat(pos)) + locInPlayerSpace
            let xPos = Int(floor(totalLoc))
            
            return (Int(xPos), 2)
        } else if position < (form.0 + form.1 + form.2) { // player is in third row (defender)
            let pos = position - form.0 - form.1
            let playerSpace: CGFloat = 9 / CGFloat(form.2)
            let locInPlayerSpace: CGFloat = playerSpace / 2
            let totalLoc: CGFloat = (playerSpace * CGFloat(pos)) + locInPlayerSpace
            let xPos = Int(floor(totalLoc))
            
            return (Int(xPos), 1)
        } else { // player is in last row (keeper)
            return (4, 0)
        }
    }
    
    private func generatePlayerName() -> (firstName: String, lastName: String) {
        let firstName = playerFirstNames[Int.random(in: 0 ..< playerFirstNames.count)]
        let lastName = playerLastNames[Int.random(in: 0 ..< playerLastNames.count)]
        let fullName = "\(firstName) \(lastName)"
        
        if playerNames.contains(fullName) {
            return generatePlayerName()
        }
        
        playerNames.append(fullName)
        return (firstName: firstName, lastName: lastName)
    }
}
