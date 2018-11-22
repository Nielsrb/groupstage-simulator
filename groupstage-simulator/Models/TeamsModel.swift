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
    
    private let teamFirstNames = ["Real", "SC", "FC", "Atletico", "Youth"]
    private let teamLastNames = ["Cambuur", "Madrid", "Hotspur", "Zoetermeer", "Barcelona", "London", "Amsterdam", "Kaapstad", "Rotterdam", "Groningen", "Lelystad"]
    
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
        let handicap = [0.75, 1.0, 1.5].randomElement()! // Handicaps are added to show the difference between team powers during the simulation
        let players = generatePlayerModels(formation: formation, handicap: handicap)
        let power = teamPowerFor(players: players)
        
        return TeamModel(name: teamName, formation: formation, players: players, power: power, played: 0, points: 0, goals: 0, goalsAgainst: 0)
    }
    
    // Generate a player, random names and power
    // TODO: - Players should not be able to have the same first and last name.
    private func generatePlayerModels(formation: Formations, handicap: Double) -> [PlayerModel] {
        var players: [PlayerModel] = []
        
        for i in 0 ..< 11 {
            var player = PlayerModel()
            player.configure(formation: formation, position: i, handicap: handicap)
            players.append(player)
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

struct TeamModel: Equatable {
    let name: String
    let formation: Formations
    var players: [PlayerModel]
    let power: Int
    var played: Int
    var points: Int
    var goals: Int
    var goalsAgainst: Int
}

public enum Formations: String {
    case A = "2-4-4"
    case B = "3-3-4"
    case C = "4-2-4"
    case D = "1-4-5"
    case E = "3-4-3"
}
