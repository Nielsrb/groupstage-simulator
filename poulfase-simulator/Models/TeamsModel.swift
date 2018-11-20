//
//  TeamModel.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation

final class TeamsModel: NSObject {
    private let teamFirstNames = ["Real", "SC", "FC", "Atletico"]
    private let teamLastNames = ["Cambuur", "Madrid", "Hotspur", "Zoetermeer", "Barcelona", "London", "Amsterdam", "Kaapstad"]
    
    private let playerFirstNames = ["Robert", "Bill", "Evan", "Richard", "Pepper", "Mauro", "Lucas", "Niels"]
    private let playerLastNames = ["Wood", "Shizuke", "Mulder", "Ndidi", "Lee", "San Giorgi", "van der Sloot"]
    
    var teams: [TeamModel] = []
    
    // public funtion to generate 4 random teams, can only be called once
    public func generateTeams() {
        guard teams.count == 0 else {
            return
        }
        
        for _ in 0..<4 {
            teams.append(generateTeamModel())
        }
    }
    
    private func generateTeamModel() -> TeamModel {
        let firstName = teamFirstNames[Int.random(in: 0 ..< teamFirstNames.count)]
        let lastName = teamLastNames[Int.random(in: 0 ..< teamLastNames.count)]
        
        let name = "\(firstName) \(lastName)"
        let players = generatePlayerModels()
        let power = teamPowerFor(players: players)
        
        return TeamModel(name: name, players: players, power: power)
    }
    
    private func generatePlayerModels() -> [PlayerModel] {
        var players: [PlayerModel] = []
        
        for _ in 0..<11 {
            let firstName = playerFirstNames[Int.random(in: 0 ..< playerFirstNames.count)]
            let lastName = playerLastNames[Int.random(in: 0 ..< playerLastNames.count)]
            let power = Int.random(in: 50...100)
            
            players.append(PlayerModel(firstName: firstName, lastName: lastName, power: power))
        }
        
        return players
    }
    
    // Team power is the average power of all team players.
    private func teamPowerFor(players: [PlayerModel]) -> Int {
        var totalPower: Int = 0
        
        for player in players {
            totalPower += player.power
        }
        
        return totalPower / players.count
    }
        
}

struct TeamModel: Codable {
    let name: String
    let players: [PlayerModel]
    let power: Int
}

struct PlayerModel: Codable {
    let firstName: String
    let lastName: String
    let power: Int
}
