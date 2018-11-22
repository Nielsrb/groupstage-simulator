//
//  PlayerModel.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 22/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

private let playerFirstNames = ["Robert", "Bill", "Evan", "Richard", "Pepper", "Mauro", "Lucas", "Niels", "Jan", "Rob", "Edwin", "John", "Alex"]
private let playerLastNames = ["Wood", "Shizuke", "Mulder", "Ndidi", "Lee", "San Giorgi", "van der Sloot", "de Groot", "Kluivert", "Santon", "Florence"]
private var playerNames: [String] = []

struct PlayerModel: Equatable {
    var firstName: String = ""
    var lastName: String = ""
    var age: Int = 0
    var length: Double = 0.0
    var kickPower: Int = 0
    var headPower: Int = 0
    var speed: Int = 0
    var position: (Int, Int) = (0, 0)
    
    var power: Int {
        get { return (kickPower + headPower + speed) / 3 }
    }
    
    mutating func configure(formation: Formations, position: Int, handicap: Double) {
        let names = generatePlayerName()
        self.firstName = names.firstName
        self.lastName = names.lastName
        
        self.age = Int.random(in: 18 ... 36)
        self.length = Double(Int.random(in: 150 ... 200)) / 100
        
        let powers = generatePlayerPower()
        self.kickPower = Int(powers.kick * handicap)
        self.headPower = Int(powers.head * handicap)
        self.speed = Int(powers.speed * handicap)
        
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
        
        // Making sure 2 players can NEVER have the same name
        if playerNames.contains(fullName) {
            return generatePlayerName()
        }
        playerNames.append(fullName)
        
        return (firstName: firstName, lastName: lastName)
    }
    
    private func generatePlayerPower() -> (kick: Double, head: Double, speed: Double) {
        // Heigher length is always beter
        let lengthPower = 50 + ((length - 1.50) * 100)
        
        // Kick, based on length
        let kickPower = lengthPower
        
        // Head, based on length
        let headPower = lengthPower
        
        // Speed, based on age and length
        let ageSpeedPower: Double = 50.0 - ((25.0 / 18.0) * (Double(age) - 18.0))
        let speedPower = ageSpeedPower + (lengthPower / 2)
        
        return (kick: kickPower, head: headPower, speed: speedPower)
    }
}
