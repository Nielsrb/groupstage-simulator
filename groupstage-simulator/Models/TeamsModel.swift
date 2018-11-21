//
//  TeamModel.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

final class TeamsModel: NSObject {
    
    static let shared = TeamsModel()
    
    private let teamFirstNames = ["Real", "SC", "FC", "Atletico"]
    private let teamLastNames = ["Cambuur", "Madrid", "Hotspur", "Zoetermeer", "Barcelona", "London", "Amsterdam", "Kaapstad"]
    
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
            players.append(PlayerModel.init(formation: formation, position: i))
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
}

struct TeamModel {
    let name: String
    let formation: Formations
    let players: [PlayerModel]
    let power: Int
}

public enum Formations: String {
    case A = "2-4-4"
    case B = "3-3-4"
    case C = "4-2-4"
    case D = "1-4-5"
    case E = "3-4-3"
}
