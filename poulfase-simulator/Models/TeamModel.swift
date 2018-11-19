//
//  TeamModel.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 19-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation

final class TeamObject: NSObject {
    private let teamFirstNames = ["Real", "SC", "FC", "Atletico"]
    private let teamLastNames = ["Cambuur", "Madrid", "Hotspur", "Zoetermeer"]
    
    private let playerFirstNames = ["Robert", "Bill", "Evan", "Richard"]
    private let playerLastNames = ["Wood", "Shizuke", "Mulder", "Ndidi"]
    
    var model: TeamModel?
    
    public func generateTeamModel() {
        let firstName = teamFirstNames[Int.random(in: 0 ..< teamFirstNames.count)]
        let lastName = teamLastNames[Int.random(in: 0 ..< teamLastNames.count)]
        
        let name = "\(firstName) \(lastName)"
        let players = generatePlayerModels()
        let power = teamPowerFor(players: players)
        
        model = TeamModel(name: name, players: players, power: power)
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
    func teamPowerFor(players: [PlayerModel]) -> Int {
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
