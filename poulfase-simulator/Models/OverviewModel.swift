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
                games.append(Game(isSimulated: false, homeTeam: team, awayTeam: teamsModel.teams[2], goalsHome: 0, goalsAway: 0, turns: [], ballHolder: team.players.last!))
                games.append(Game(isSimulated: false, homeTeam: teamsModel.teams[1], awayTeam: team, goalsHome: 0, goalsAway: 0, turns: [], ballHolder: teamsModel.teams[1].players.last!))
            } else if index == 1 {
                games.insert(Game(isSimulated: false, homeTeam: teamsModel.teams[3], awayTeam: team, goalsHome: 0, goalsAway: 0, turns: [], ballHolder: teamsModel.teams[3].players.last!), at: 1)
                games.append(Game(isSimulated: false, homeTeam: team, awayTeam: teamsModel.teams[2], goalsHome: 0, goalsAway: 0, turns: [], ballHolder: team.players.last!))
            } else if index == 2 {
                games.insert(Game(isSimulated: false, homeTeam: team, awayTeam: teamsModel.teams[3], goalsHome: 0, goalsAway: 0, turns: [], ballHolder: team.players.last!), at: 3)
            } else if index == 3 {
                games.insert(Game(isSimulated: false, homeTeam: teamsModel.teams[0], awayTeam: team, goalsHome: 0, goalsAway: 0, turns: [], ballHolder: teamsModel.teams[0].players.last!), at: 4)
            }
        }
        
        // All teams should play home/away atleast once against each contestant, so we reverse the previous
        for game in games {
            games.append(reverseTeamsFor(game: game))
        }
    }
    
    private func reverseTeamsFor(game: Game) -> Game {
        return Game(isSimulated: false, homeTeam: game.awayTeam, awayTeam: game.homeTeam, goalsHome: 0, goalsAway: 0, turns: [], ballHolder: game.awayTeam.players.last!)
    }
    
    public func simulateGame(game: inout Game) {
        nextTurn(game: &game)
        
        //TODO: - Game finished simulating, show results
    }
    
    
    private func nextTurn(game: inout Game) {
        //TODO: - Simulate a move
        
        // First move of the half, the keeper should start with the ball (might create actual kick-off later on
        if game.turns.count == 0 {
            
        } else if game.turns.count == numberOfTurns / 2 {
            
        }
        
        
    }
}

struct Game {
    let isSimulated: Bool
    let homeTeam: TeamModel
    let awayTeam: TeamModel
    let goalsHome: Int
    let goalsAway: Int
    let turns: [Turn]
    let ballHolder: PlayerModel
}

struct Turn {
    let fromPlayer: PlayerModel
    let toPlayer: PlayerModel
    let goal: Bool
    let currentTeam: TeamModel
}
