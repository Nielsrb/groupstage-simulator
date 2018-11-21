//
//  OverviewModel.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 21-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation

final class OverviewModel: NSObject {
    
    static let shared = OverviewModel()
    
    var games: [Game] = []
    var currentGame: Game?
    
    let numberOfTurns: Int = 90
    
    public func generateGames() {
        let teamsModel = TeamsModel.shared
        
        // If there are no teams generated yet, generate teams
        if teamsModel.teams.count == 0 {
            teamsModel.generateTeams()
        }
        
        guard games.count == 0 else {
            return
        }
        
        // Plan all games
        // Planning:
        // A vs C
        // D vs B
        // B vs A
        // C vs D
        // A vs D
        // B vs C
        for (index, team) in teamsModel.teams.enumerated() {
            if index == 0 {
                games.append(Game(isSimulated: false, homeTeam: team, awayTeam: teamsModel.teams[2], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: team.players.last!))
                games.append(Game(isSimulated: false, homeTeam: teamsModel.teams[1], awayTeam: team, goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[1].players.last!))
            } else if index == 1 {
                games.insert(Game(isSimulated: false, homeTeam: teamsModel.teams[3], awayTeam: team, goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[3].players.last!), at: 1)
                games.append(Game(isSimulated: false, homeTeam: team, awayTeam: teamsModel.teams[2], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: team.players.last!))
            } else if index == 2 {
                games.insert(Game(isSimulated: false, homeTeam: team, awayTeam: teamsModel.teams[3], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: team.players.last!), at: 3)
            } else if index == 3 {
                games.insert(Game(isSimulated: false, homeTeam: teamsModel.teams[0], awayTeam: team, goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[0].players.last!), at: 4)
            }
        }
        
        // All teams should play home/away atleast once against each contestant, so we reverse the previous
        for game in games {
            games.append(reverseTeamsFor(game: game))
        }
    }
    
    private func reverseTeamsFor(game: Game) -> Game {
        return Game(isSimulated: false, homeTeam: game.awayTeam, awayTeam: game.homeTeam, goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: game.awayTeam.players.last!)
    }
    
    public func simulateGame(game: inout Game) {
        nextTurn(game: &game)
        
        //TODO: - Game finished simulating, show results/turns
    }
    
    
    private func nextTurn(game: inout Game) {
        //TODO: - Simulate a turn
        
        // First move of the second half, the goalkeeper should start with the ball (might create actual kick-off later on
        if game.turns.count == (numberOfTurns / 2) - 1 {
            game.ballHolder = game.awayTeam.players.last!
        }
        
        // Player is a forwarder, should shoot on goal
        if game.ballHolder.position.1 == 3 {
            var goalChance: Double = 60
            
            // The higher difference between the forwarder and the keeper, the higher the chance to score.
            let playerPower = game.ballHolder.power
            let enemyPower = game.holdingTeam == .home ? game.awayTeam.players.last!.power : game.homeTeam.players.last!.power
            let difference: Double = Double(playerPower - enemyPower)
            
            goalChance = max(goalChance + (difference*1.5), 95) // 1.5% goal chance +- per power level difference, with a maximum of 95% chance.
            
            let totalPower = playerPower + enemyPower
            let goalValue = Double(totalPower) * goalChance
            
            let randomValue = Int.random(in: 0...totalPower)
            
            if randomValue < Int(goalValue) {
                // GOAL
            } else {
                // MISS
            }
            
            // Either after scroring or missing, the ball should return to the others goalkeeper (might add chance for rebound?)
            game.ballHolder = game.holdingTeam == .home ? game.awayTeam.players.last! : game.homeTeam.players.last!
            game.holdingTeam = game.holdingTeam == .home ? .away : .home
            
        } else { // Player is either a goalkeeper, defender or midfielder. He should try passing.
            
        }
        
        // If game still has turns left, simulate next turn!
        if game.turns.count != numberOfTurns {
            nextTurn(game: &game)
        }
    }
    
    private func teamForPlayer(player: PlayerModel, inGame: Game) -> Teams {
        var team: Teams = .home
        
        for awayPlayer in inGame.awayTeam.players {
            if player == awayPlayer {
                team = .away
            }
        }
        
        return team
    }
}

struct Game {
    var isSimulated: Bool = false
    let homeTeam: TeamModel
    let awayTeam: TeamModel
    var goalsHome: Int
    var goalsAway: Int
    var turns: [Turn]
    var holdingTeam: Teams
    var ballHolder: PlayerModel
}

struct Turn {
    let fromPlayer: PlayerModel
    let toPlayer: PlayerModel
    let goal: Bool
}

enum Teams {
    case home
    case away
}
