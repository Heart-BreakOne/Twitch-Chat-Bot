//
//  Twitch.swift
//  Twitch bot
//
//  Created by leon on 3/16/24.
//

import Foundation
import AVFoundation

//Log battle
func logBattle(eventId: String, captainName: String, scale: String, qttPlayers: String, enmPlayers: String, power: String, enmPower: String, spell: String, enmSpell: String, unit: String, enmUnit: String, plan: String, enmPlan: String, outcome: String) -> String {
    
    let dataToLog = ["event": eventId, "capName": captainName, "scale": scale, "qttPlayers": qttPlayers, "enmPlayers": enmPlayers, "power": power, "enmPower": enmPower, "spell": spell, "enmSpell": enmSpell, "unit": unit, "enmunit": enmUnit, "plan": plan, "enmPlan": enmPlan, "outcome": outcome] as [String : Any]
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
    return "New code has been set DoritosChip"
}

//Send code if there's any
func sendCode() -> String {
    let json = getJson()
    let code = json["code"] as! String
    if code == "none" {
        return "No code at the moment! DoritosChip"
    } else {
        return "Code is \(code). Clash specific rules: Please follow the markers, no tank souls, no spies, do not erase tactical markers with wrong placements."
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
        if b["event"] as! Int == 1 {
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
    let soul = ["with a tank soul", "with an archer soul", "with a rogue soul", "with a warrior soul", "with a flag soul", "", "", "", "", "", "", "", "", "", "", "", "", ""].randomElement() ?? ""

    return " today you are level \(lvl)\(epic)\(lvl >= 20 ? spec : "") \(unitName) \(soul)"
}
