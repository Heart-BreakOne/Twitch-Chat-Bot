//
//  Twitch.swift
//  Twitch bot
//
//  Created by leon on 3/16/24.
//

import Foundation
import AVFoundation

//Log battle
func logBattle(eventId: String, captainName: String, outcome: String) -> String {
    
    let dataToLog = ["event": eventId, "capName": captainName, "outcome": outcome] as [String : Any]
    var json = getJson()
    var log = json["log"] as! [[String: Any]]
    log.insert(dataToLog, at: 0)
    json["log"] = log
    updateJson(json: json)
    return "Logged!"
}

//List commands
func sendCommands() -> String {
    let json = getJson()
    let commands = json["chatCommands"] as! [String]
    var commandsStr = "Commands available are: "
    for com in commands {
        commandsStr = commandsStr + com
    }
    return commandsStr
}

//Send current winning streak
func sendStreak() -> String {
    let json = getJson()
    let battleLog = json["log"] as! [[String: Any]]
    var streakCounter = 0
    for log in battleLog {
        if log["outcome"] as! String == "win" {
            streakCounter += 1
        } else {
            break
        }
    }
    return "The current win streak is \(streakCounter)"
}

// Set battle code
func setCode(code: String) -> String {
    var json = getJson()
    json["code"] = code
    updateJson(json: json)
    return "New code has been set. Don't forget to !setmode. DoritosChip"
}

func setGameMode(mode: String) -> String {
    var json = getJson()
    json["mode"] = mode
    updateJson(json: json)
    return "Mode has been set to \(mode)."
}

//Send code if there's any
func sendCode() -> String {
    let json = getJson()
    let code = json["code"] as! String
    let mode = (json["mode"] as! String).lowercased()
    
    if code == "none" {
        return "No code at the moment! DoritosChip"
    } else {
        if mode == "duels" || mode == "duel" {
            return "Code is: \(code). Coded duels usually means something is being tested or there's PvP clash practice happening, please follow the markers to help with the practice."
        }
        else if mode == "dungeon" || mode == "dungeons" {
            return "Code is: \(code). This captain sucks at dungeons, I'm don't know why they coded it."
        } else if mode == "clash" {
            let string = "The code is among the clash instructions: No spies as they use 100% power and prevent spell placement. No tanks souls. Follow the markers. No spies, no tank souls. No spies, no tank souls."
            let rangeOfAnd = string.range(of: "and")!
            
            var randomIndex = string.index(rangeOfAnd.upperBound, offsetBy: Int.random(in: 0..<(string.distance(from: rangeOfAnd.upperBound, to: string.endIndex))))
            
            while string[randomIndex] != " " {
                randomIndex = string.index(after: randomIndex)
            }
            let encodedCode = getCodeString(code: code)
            let modifiedString = String(string.prefix(upTo: randomIndex)) + " " + encodedCode + String(string.suffix(from: randomIndex))
            return modifiedString
        } else {
            return "No code for campaign."
        }
    }
}

func updateList(username:String, listId: String) -> String {
    var json = getJson()
    var list = json[listId] as! [String]
    
    list.append(username)
    json[listId] = list
    updateJson(json: json)
    
    return "\(listId) updated successfully!"
}

//Play audio cue to start battle
func playBattle() {
    let path = getFilePath()
    do {
        let url = URL(fileURLWithPath: "\(path)audio.mp3")
        let audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.play()
        
        while audioPlayer.isPlaying {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    } catch {
        print("Error playing audio: \(error.localizedDescription)")
    }
}

// Check battle stats
func checkStats(from: String) -> String{
    var stats = ""
    let json = getJson()
    let battleLog = json["log"] as! [[String: Any]]
    switch from {
    case "":
        stats = getAllStats(battleLog: battleLog)
    case "current":
        stats = getCurrentStats(battleLog: battleLog)
    default:
        stats = getCaptainStats(from: from, battleLog: battleLog)
    }
    
    return stats
}

func getAllStats(battleLog: [[String: Any]]) -> String {
    var wins = 0
    var losses = 0
    for b in battleLog {
        let outcome = b["outcome"] as! String
        if outcome == "win" {
            wins += 1
        } else if outcome == "loss" {
            losses += 1
        }
    }
    let total = wins + losses
    let winRate = Int(Double(wins) / Double(total) * 100.0)
    return "Historical stats: \(wins) battles won, \(losses) battles lost, \(winRate)% winning rate."
}

//Send random strings
func sendRdmStr(key: String) -> String {
    let json = getJson()
    let msg = json[key] as! [String]
    let randomMsg = msg.randomElement()!
    return randomMsg
}

func getCurrentStats(battleLog: [[String: Any]]) -> String{
    var wins = 0
    var losses = 0
    for b in battleLog {
        if b["event"] as! String == "1" {
            let outcome = b["outcome"] as! String
            if outcome == "win" {
                wins += 1
            } else if outcome == "loss" {
                losses += 1
            }
        }
    }
    let total = wins + losses
    let winRate = Int(Double(wins) / Double(total) * 100.0)
    return "Current event stats: \(wins) battles won, \(losses) battles lost, \(winRate)% winning rate."
}

func getCaptainStats(from: String, battleLog: [[String: Any]]) -> String{
    var wins = 0
    var losses = 0
    for b in battleLog {
        let capName = b["capName"] as! String
        if capName.lowercased() == from.lowercased() {
            let outcome = b["outcome"] as! String
            if outcome == "win" {
                wins += 1
            } else if outcome == "loss" {
                losses += 1
            }
        }
    }
    
    if wins == 0 && losses == 0 {
        return "DoritosChip No data to show DoritosChip"
    } else {
        let total = wins + losses
        let winRate = Int(Double(wins) / Double(total) * 100.0)
        return "Historical stats against \(from): \(wins) battles won, \(losses) battles lost, \(winRate)% winning rate."
    }
}

func getDoritos() -> String {
    let i = Int(arc4random_uniform(4))
    var doritosChip = "DoritosChip"
    var count = 0
    while count < i {
        doritosChip += " DoritosChip"
        count += 1
    }
    return doritosChip
}

func getUnitOfTheDay() -> String {
    let lvl = Int(arc4random_uniform(30)) + 1
    guard let unitsList = getJson()["unitsList"] as? [[String: [String]]],
          let randomCategory = unitsList.randomElement(),
          let unitName = randomCategory.keys.first,
          let unitSpec = randomCategory.values.first,
          let spec = unitSpec.randomElement() else {
        return ""
    }
    let epic = arc4random_uniform(2) == 0 ? " epic " : " "
    let soul = ["with a tank soul", "with an archer soul", "with a rogue soul", "with a warrior soul", "with a flag soul", "", "", "", "", "", "", "", "", ""].randomElement() ?? ""
    
    return " today you are a level \(lvl)\(epic)\(lvl >= 20 ? spec : "") \(unitName) \(soul)"
}

struct CostTable {
    let lower: Int
    let high: Int
    let gold: Int
    let scroll: Int
}

func calculateLevel(data: [String], user: String) -> String {
    
    let regularCost: [CostTable] = [
        CostTable(lower: 1, high: 2, gold: 25, scroll: 15),
        CostTable(lower: 2, high: 3, gold: 35, scroll: 20),
        CostTable(lower: 3, high: 4, gold: 50, scroll: 25),
        CostTable(lower: 4, high: 5, gold: 100, scroll: 50),
        CostTable(lower: 5, high: 6, gold: 120, scroll: 60),
        CostTable(lower: 6, high: 7, gold: 140, scroll: 70),
        CostTable(lower: 7, high: 8, gold: 160, scroll: 80),
        CostTable(lower: 8, high: 9, gold: 180, scroll: 90),
        CostTable(lower: 9, high: 10, gold: 200, scroll: 100),
        CostTable(lower: 10, high: 11, gold: 220, scroll: 110),
        CostTable(lower: 11, high: 12, gold: 240, scroll: 120),
        CostTable(lower: 12, high: 13, gold: 260, scroll: 130),
        CostTable(lower: 13, high: 14, gold: 280, scroll: 140),
        CostTable(lower: 14, high: 15, gold: 300, scroll: 150),
        CostTable(lower: 15, high: 16, gold: 320, scroll: 160),
        CostTable(lower: 16, high: 17, gold: 340, scroll: 170),
        CostTable(lower: 17, high: 18, gold: 360, scroll: 180),
        CostTable(lower: 18, high: 19, gold: 380, scroll: 190),
        CostTable(lower: 19, high: 20, gold: 400, scroll: 200),
        CostTable(lower: 20, high: 21, gold: 450, scroll: 220),
        CostTable(lower: 21, high: 22, gold: 500, scroll: 240),
        CostTable(lower: 22, high: 23, gold: 550, scroll: 260),
        CostTable(lower: 23, high: 24, gold: 600, scroll: 280),
        CostTable(lower: 24, high: 25, gold: 675, scroll: 300),
        CostTable(lower: 25, high: 26, gold: 750, scroll: 320),
        CostTable(lower: 26, high: 27, gold: 825, scroll: 340),
        CostTable(lower: 27, high: 28, gold: 900, scroll: 360),
        CostTable(lower: 28, high: 29, gold: 1000, scroll: 380),
        CostTable(lower: 29, high: 30, gold: 1200, scroll: 400)
    ]

    let legendaryCost: [CostTable] = [
        CostTable(lower: 2, high: 3, gold: 70, scroll: 10),
        CostTable(lower: 3, high: 4, gold: 100, scroll: 10),
        CostTable(lower: 4, high: 5, gold: 200, scroll: 10),
        CostTable(lower: 5, high: 6, gold: 240, scroll: 10),
        CostTable(lower: 6, high: 7, gold: 280, scroll: 10),
        CostTable(lower: 7, high: 8, gold: 320, scroll: 10),
        CostTable(lower: 8, high: 9, gold: 360, scroll: 10),
        CostTable(lower: 9, high: 10, gold: 400, scroll: 10),
        CostTable(lower: 10, high: 11, gold: 440, scroll: 15),
        CostTable(lower: 11, high: 12, gold: 480, scroll: 15),
        CostTable(lower: 12, high: 13, gold: 520, scroll: 15),
        CostTable(lower: 13, high: 14, gold: 560, scroll: 15),
        CostTable(lower: 14, high: 15, gold: 600, scroll: 15),
        CostTable(lower: 15, high: 16, gold: 640, scroll: 15),
        CostTable(lower: 16, high: 17, gold: 680, scroll: 15),
        CostTable(lower: 17, high: 18, gold: 720, scroll: 15),
        CostTable(lower: 18, high: 19, gold: 760, scroll: 15),
        CostTable(lower: 19, high: 20, gold: 800, scroll: 15),
        CostTable(lower: 20, high: 21, gold: 850, scroll: 20),
        CostTable(lower: 21, high: 22, gold: 900, scroll: 20),
        CostTable(lower: 22, high: 23, gold: 950, scroll: 20),
        CostTable(lower: 23, high: 24, gold: 1000, scroll: 20),
        CostTable(lower: 24, high: 25, gold: 1100, scroll: 20),
        CostTable(lower: 25, high: 26, gold: 1200, scroll: 20),
        CostTable(lower: 26, high: 27, gold: 1300, scroll: 20),
        CostTable(lower: 27, high: 28, gold: 1500, scroll: 20),
        CostTable(lower: 28, high: 29, gold: 1600, scroll: 20),
        CostTable(lower: 29, high: 30, gold: 2000, scroll: 20)
    ]
    
    do {
        var startingLevel = 0
        var endingLevel = 0
        var isLegendary = false
        if data.count  <= 1 {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        if data[1] == "legendary" {
            isLegendary = true
        }
        
        if isLegendary {
            if let starting = Int(data[2]), let ending = Int(data[3]) {
                startingLevel = starting
                endingLevel = ending
            } else {
                throw NSError(domain: "", code: 0, userInfo: nil)
            }
        } else {
            if let starting = Int(data[1]), let ending = Int(data[2]) {
                startingLevel = starting
                endingLevel = ending
            } else {
                throw NSError(domain: "", code: 0, userInfo: nil)
            }
        }
        
        if startingLevel >= endingLevel || startingLevel <= 0 || endingLevel > 30{
            return "@\(user) Those are not valid levels :p Command usage is: !levelup starting_level ending_level or !levelup legendary starting_level ending_level. E.g: !levelup 3 17"
        } else if endingLevel == 30 {
            return "@\(user) Can't go past level 30 DoritosChip"
        }
        
        
        var coins = 0
        var scrolls = 0
        
        if isLegendary {
            for level in startingLevel..<endingLevel {
                if let cost = legendaryCost.first(where: { $0.lower <= level && $0.high > level }) {
                    coins += cost.gold
                    scrolls += cost.scroll
                } else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
            }
        } else {
            for level in startingLevel..<endingLevel {
                if let cost = regularCost.first(where: { $0.lower <= level && $0.high > level }) {
                    coins += cost.gold
                    scrolls += cost.scroll
                } else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
            }
        }
        
        return "@\(user) level up cost will be \(coins) coins and \(scrolls) scrolls"
        
    } catch {
        return "@\(user) command usage is: !levelup starting_level ending_level or !levelup legendary starting_level ending_level. E.g: !levelup 3 17"
    }
}
