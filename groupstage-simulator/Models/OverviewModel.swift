//
//  OverviewModel.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 21-11-18.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation

final class OverviewModel: NSObject {
    
    static let shared = OverviewModel()
    
    var games: [Game] = []
    var currentGame: Game?
    
    let numberOfTurns: Int = 40
    
    // This is the completionHandler for simulating the games.
    // Every view that needs to know when a game has been finished can listen to this event.
    let gameWasSimulatedEvent = Event<Int>()
    
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
        // B vs C
        // A vs D
        games.append(Game(id: 0, isSimulated: false, homeTeam: teamsModel.teams[0], awayTeam: teamsModel.teams[2], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[0].players.last!))
        games.append(Game(id: 1, isSimulated: false, homeTeam: teamsModel.teams[3], awayTeam: teamsModel.teams[1], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[3].players.last!))
        games.append(Game(id: 2, isSimulated: false, homeTeam: teamsModel.teams[1], awayTeam: teamsModel.teams[0], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[1].players.last!))
        games.append(Game(id: 3, isSimulated: false, homeTeam: teamsModel.teams[2], awayTeam: teamsModel.teams[3], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[2].players.last!))
        games.append(Game(id: 5, isSimulated: false, homeTeam: teamsModel.teams[1], awayTeam: teamsModel.teams[2], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[1].players.last!))
        games.append(Game(id: 4, isSimulated: false, homeTeam: teamsModel.teams[0], awayTeam: teamsModel.teams[3], goalsHome: 0, goalsAway: 0, turns: [], holdingTeam: .home, ballHolder: teamsModel.teams[0].players.last!))
    }
    
    public func simulateGameWith(id: Int) {
        nextTurnForGameWith(id: id)
    }
    
    
    private func nextTurnForGameWith(id: Int) {
        var game = games[id]
        
        // First move of a half, the defenders should start with the ball (might create actual kick-off later on)
        if game.turns.count == 0 || game.turns.count == (numberOfTurns / 2) {
            let team = game.turns.count == 0 ? game.homeTeam : game.awayTeam
            
            let defenders = team.players.filter { player in
                return player.position.1 == 1
            }
            
            if let player = defenders.randomElement() {
                game.ballHolder = player
            }
        }
        
        // Player is a forwarder, player should shoot on goal
        if game.ballHolder.position.1 == 3 {
            var goalChance: Double = 60
            
            // The higher difference between the forwarder and the keeper, the higher the chance to score.
            let playerPower = game.ballHolder.power
            let enemyPower = game.holdingTeam == .home ? game.awayTeam.players.last!.power : game.homeTeam.players.last!.power
            let difference: Double = Double(playerPower - enemyPower)
            
            goalChance = max(min(goalChance + (difference*1.5), 95), 10) // +-1.5% goal chance per power level difference, with a maximum of 95% chance, and a minimum of 10% chance.
            
            let randomValue = Int.random(in: 0...100)
            
            var goal = false
            if randomValue < Int(goalChance) {
                // GOAL
                if game.holdingTeam == .home {
                    game.goalsHome += 1
                } else {
                    game.goalsAway += 1
                }
                goal = true
                
                
                // We should add the goal to the player that just scored (for statistics)
                // First find out what team he's in.
                let team = TeamsModel.shared.teams.enumerated().first { team in
                    return team.element.players.contains(game.ballHolder)
                }
                
                // If we found a team, search for his index within his team and add the goal.
                if let team = team {
                    for (index, player) in team.element.players.enumerated() {
                        if player == game.ballHolder {
                            TeamsModel.shared.teams[team.offset].players[index].goals += 1
                            break
                        }
                    }
                }
                
                print("\(game.ballHolder.firstName) \(game.ballHolder.lastName) scored! The score now stands \(game.goalsHome)-\(game.goalsAway)")
            } else {
                // OPTIONAL: We could add rebound chance right here.
                print("\(game.ballHolder.firstName) \(game.ballHolder.lastName) misses!")
            }
            
            // Let the keeper start with the ball after a shot on goal (defenders if goal was made, see 4 lines ahead).
            var ballHolder = game.holdingTeam == .home ? game.awayTeam.players.last! : game.homeTeam.players.last!
            let holdingTeam: Teams = game.holdingTeam == .home ? .away : .home
            let team = holdingTeam == .home ? game.homeTeam : game.awayTeam
            
            if goal { // If a goal was made, let the defenders start with the ball
                let defenders = team.players.filter { player in
                    return player.position.1 == 1
                }
                
                if let player = defenders.randomElement() {
                    ballHolder = player
                }
            }
            
            game.turns.append(Turn(fromPlayer: game.ballHolder, toPlayer: ballHolder, goal: goal))
            game.ballHolder = ballHolder
            game.holdingTeam = holdingTeam
        } else {
            // Player is either a goalkeeper, defender or midfielder. He should try passing.
            // Player should make a decision who to pass to:
            //   - Every player starts with 100 'chance points'
            //   - Stronger teammates get bonus chance (+2.5 per power)
            //   - Further teammates get decreased chance (-7.5 per grid)
            //
            let yPosCurrentGrid = game.ballHolder.position.1
            let teamMates = game.holdingTeam == .home ? game.homeTeam.players : game.awayTeam.players
            
            // Posible teammates, all players the current ball holder is currently able to pass to.
            // .0 = PlayerModel
            // .1 = Double, represents the amount of chance points someone has.
            var possibleTeammates = teamMates.compactMap { player -> (PlayerModel, Double)? in
                if player.position.1 == yPosCurrentGrid + 1 {
                    return (player, 100)
                }
                return nil
            }
            
            guard possibleTeammates.count > 0 else {
                games[id] = game
                nextTurnForGameWith(id: id)
                return
            }
            
            // We should know the weakest posible teammate, the other teammates should get extra chance points
            let lowestPower = possibleTeammates.compactMap { teammate -> Int in
                return teammate.0.power
            }.min() ?? 50
            
            for (index, teammate) in possibleTeammates.enumerated() {
                // Add the +2.5 for each point stronger than the weakest player
                let powerDifference = teammate.0.power - lowestPower
                possibleTeammates[index].1 += Double(powerDifference) * 2.5
                
                // Decrease the -5 for each grid further away from the current ball holder
                var gridDifference = yPosCurrentGrid - teammate.0.position.1
                if gridDifference < 0 {
                    gridDifference = -gridDifference
                }
                possibleTeammates[index].1 -= Double(gridDifference) * 7.5
            }
            
            // Now that we calculated the chances, lets see to what player the current ball holder will pass to.
            // First we need to know what the total amount of 'chance points' they have.
            var totalTeammatesChance: Double = 0
            for teammate in possibleTeammates {
                totalTeammatesChance += teammate.1
            }
            
            let randomTeammatesChanceValue = Double.random(in: 0 ..< totalTeammatesChance)
            var checkedTeammatesChance: Double = 0
            var chosenTeammate: PlayerModel = possibleTeammates.first!.0
            for teammate in possibleTeammates {
                if randomTeammatesChanceValue < checkedTeammatesChance + teammate.1 {
                    chosenTeammate = teammate.0
                } else {
                    checkedTeammatesChance += teammate.1
                }
            }
            
            // Possible future features for passing/intercepting:
            //   - Make the pass possible to be a high/far shot as well, in this case instead of comparing Power, compare headPower or speedPower.
            
            // Now we know what player the current holder is passing to, we can now calculate how much chance the player has in succeeding this pass.
            //  - The person receiving the ball, and possibly the enemy on the same grid use full power when defending.
            //  - Each teammate and enemy in the same row can support their teammate with receiving/intercepting the ball, yet the further away they are, the less effective they help.
            var chances: [Double] = []
            
            // We have to know what enemies are able to intercept the pass.
            let yPosEnemies = 4 - chosenTeammate.position.1
            let enemies = (game.holdingTeam == .home ? game.awayTeam : game.homeTeam).players.compactMap { player -> PlayerModel? in
                if player.position.1 == yPosEnemies {
                    return player
                }
                return nil
            }
            
            // When there are no enemies, pass succesion should be 100% (this should not be possible right now).
            if enemies.count == 0 {
                chances[0] = 100
                print("ERROR")
            } else {
                // Calculate the power for each supporting teammate and ball receiver
                for teammate in possibleTeammates {
                    var gridDifference = chosenTeammate.position.0 - teammate.0.position.0
                    if gridDifference < 0 {
                        gridDifference = -gridDifference
                    }
                    let chance = max(10, Double(teammate.0.power) * max(0.1, 1 - (Double(gridDifference) * 0.1))) // -10% power per grid
                    chances.append(chance)
                }
                
                // Calculate the power for each enemy
                for enemy in enemies {
                    var gridDifference = chosenTeammate.position.0 - enemy.position.0
                    if gridDifference < 0 {
                        gridDifference = -gridDifference
                    }
                    let chance = max(10, Double(enemy.power) * max(0.1, 1 - (Double(gridDifference) * 0.1))) // -10% power per grid
                    chances.append(chance)
                }
            }
            
            var totalChances: Double = 0
            for chance in chances {
                totalChances += chance
            }
            
            let randomChanceValue = Double.random(in: 0 ..< totalChances)
            var checkedChance: Double = 0
            var passSucceeded = false
            
            if randomChanceValue < chances[0] {
                passSucceeded = true
            } else {
                if possibleTeammates.count > 0 {
                    for i in 0 ..< possibleTeammates.count {
                        if randomChanceValue < checkedChance + chances[i] {
                            passSucceeded = true
                        } else {
                            checkedChance += chances[i]
                        }
                    }
                }
            }
            
            if passSucceeded { // If pass succeeds, toPlayer should now be ballHolder.
                print("\(game.ballHolder.firstName) \(game.ballHolder.lastName) passed to \(chosenTeammate.firstName) \(chosenTeammate.lastName)!")
                game.turns.append(Turn(fromPlayer: game.ballHolder, toPlayer: chosenTeammate, goal: false))
                game.ballHolder = chosenTeammate
            } else {
                // If pass was intercepted, let a random enemy in this 'row' get the ball.
                // OPTIONAL: Calculate chance for each enemy based on grid difference (and maybe power?).
                
                let receivingEnemy = enemies.randomElement() ?? enemies[0]
                
                print("\(receivingEnemy.firstName) \(receivingEnemy.lastName) intercepts the pass!")
                game.turns.append(Turn(fromPlayer: game.ballHolder, toPlayer: receivingEnemy, goal: false))
                game.ballHolder = receivingEnemy
                game.holdingTeam = game.holdingTeam == .home ? .away : .home
            }
        }
        
        games[id] = game
        
        // If game still has turns left, simulate next turn!
        if game.turns.count != numberOfTurns {
            nextTurnForGameWith(id: id)
        } else {
            games[id].isSimulated = true
            print("Game finished! Total score is \(game.goalsHome)-\(game.goalsAway)")
            gameWasSimulatedEvent.emit(id)
            
            // Update the global TeamsModel with the games stats.
            for (index, team) in TeamsModel.shared.teams.enumerated() {
                if team.name == game.homeTeam.name {
                    TeamsModel.shared.teams[index].goals += game.goalsHome
                    TeamsModel.shared.teams[index].goalsAgainst += game.goalsAway
                    TeamsModel.shared.teams[index].points += game.goalsAway > game.goalsHome ? 0 : game.goalsHome == game.goalsAway ? 1 : 3
                    TeamsModel.shared.teams[index].played += 1
                } else if team.name == game.awayTeam.name {
                    TeamsModel.shared.teams[index].goals += game.goalsAway
                    TeamsModel.shared.teams[index].goalsAgainst += game.goalsHome
                    TeamsModel.shared.teams[index].points += game.goalsAway > game.goalsHome ? 3 : game.goalsHome == game.goalsAway ? 1 : 0
                    TeamsModel.shared.teams[index].played += 1
                }
            }
        }
    }
    
    public func goalsForTurn(turn: Int, inGame game: Game) -> (home: Int, away: Int) {
        var goals: (home: Int, away: Int) = (home: 0, away: 0)
        
        for i in 0 ... turn {
            let holdingTeam: Teams = game.homeTeam.players.contains(game.turns[i].fromPlayer) ? .home : .away
            
            if game.turns[i].goal {
                switch holdingTeam {
                case .home:
                    goals.home += 1
                case .away:
                    goals.away += 1
                }
            }
        }
        
        return goals
    }
}

struct Game {
    var id: Int
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
