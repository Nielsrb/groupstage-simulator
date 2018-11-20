//
//  TeamModel.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class TeamsModel: NSObject {
    private let teamFirstNames = ["Real", "SC", "FC", "Atletico"]
    private let teamLastNames = ["Cambuur", "Madrid", "Hotspur", "Zoetermeer", "Barcelona", "London", "Amsterdam", "Kaapstad"]
    
    private let playerFirstNames = ["Robert", "Bill", "Evan", "Richard", "Pepper", "Mauro", "Lucas", "Niels"]
    private let playerLastNames = ["Wood", "Shizuke", "Mulder", "Ndidi", "Lee", "San Giorgi", "van der Sloot"]
    
    private var chosenPlayerNames: [String] = []
    
    var teams: [TeamModel] = []
    
    // Public funtion to generate 4 random teams, can only be called once
    public func generateTeams() {
        guard teams.count == 0 else {
            return
        }
        
        for _ in 0..<4 {
            teams.append(generateTeamModel())
        }
    }
    
    // Generate a new team with random players
    private func generateTeamModel() -> TeamModel {
        let firstName = teamFirstNames[Int.random(in: 0 ..< teamFirstNames.count)]
        let lastName = teamLastNames[Int.random(in: 0 ..< teamLastNames.count)]
        let teamName = "\(firstName) \(lastName)"
        
        // Making sure teams can ever have the same name.
        var valid = true
        for team in teams {
            if team.name == teamName {
                valid = false
                break
            }
        }
        
        guard valid else {
            return generateTeamModel()
        }
        
        let formation = generateRandomFormation()
        let players = generatePlayerModels(formation: formation)
        let power = teamPowerFor(players: players)
        
        return TeamModel(name: teamName, formation: formation, players: players, power: power)
    }
    
    // Generate a player, random names and power
    // TODO: - Players should not be able to have the same first and last name.
    private func generatePlayerModels(formation: Formations) -> [PlayerModel] {
        var players: [PlayerModel] = []
        
        for i in 0 ..< 11 {
            let firstName = playerFirstNames[Int.random(in: 0 ..< playerFirstNames.count)]
            let lastName = playerLastNames[Int.random(in: 0 ..< playerLastNames.count)]
            let fullName = "\(firstName) \(lastName)"
            
            // Making sure a team can't contain 2 players with the same name.
            var valid = true
            for player in players {
                if "\(player.firstName) \(player.lastName)" == fullName {
                    valid = false
                    break
                }
            }
            
            guard valid else  {
                return generatePlayerModels(formation:formation)
            }
            
            let age = Int.random(in: 18 ... 34)
            let power = Int.random(in: 50...100)
            
            players.append(PlayerModel(firstName: firstName, lastName: lastName, age: age, power: power, position: positionForPlayer(formation: formation, position: i)))
        }
        
        return players
    }
    
    // Function to get a teams power
    // Team power is the average power of all team players.
    private func teamPowerFor(players: [PlayerModel]) -> Int {
        var totalPower: Int = 0
        
        for player in players {
            totalPower += player.power
        }
        
        return totalPower / players.count
    }
    
    // Generate a random formation
    private func generateRandomFormation() -> Formations {
        let random = Int.random(in: 0 ... 4)
        
        switch random {
        case 0:
            return .A
        case 1:
            return .B
        case 2:
            return .C
        case 3:
            return .D
        case 4:
            return .E
        default:
            return .A
        }
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
        
        // TODO: - Positions are almost perfectly calculated now, might want a new fomule to perfectionate it.
        //
        if position < form.0 { // player is in first row (forwarder)
            let xPos = floor((CGFloat(9) / CGFloat(form.0 + 1)) * CGFloat(position + 1))
            
            return (Int(xPos), 3)
        } else if position < (form.0 + form.1) { // player is in second row (midfielder)
            let xPos = floor((CGFloat(9) / CGFloat(form.1 + 1)) * CGFloat(position - form.0 + 1))
            
            return (Int(xPos), 2)
        } else if position < (form.0 + form.1 + form.2) { // player is in third row (defender)
            let xPos = floor((CGFloat(9) / CGFloat(form.2 + 1)) * CGFloat(position - form.0 - form.1 + 1))
            
            return (Int(xPos), 1)
        } else { // player is in last row (keeper)
            return (4, 0)
        }
    }
}

struct TeamModel {
    let name: String
    let formation: Formations
    let players: [PlayerModel]
    let power: Int
}

struct PlayerModel {
    let firstName: String
    let lastName: String
    let age: Int
    let power: Int
    let position: (Int, Int)
}

enum Formations {
    case A
    case B
    case C
    case D
    case E
}
