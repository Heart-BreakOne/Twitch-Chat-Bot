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
    var code = code
    if code == "" {
        code = "none"
    }
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
            let string = "Read the clash instructions and find the 4 random coded words: No spies as they use 100% power and prevent spell placement. No tanks souls. Follow the markers. No spies, no tank souls. No spies, no tank souls."
            let rangeOfAnd = string.range(of: "power")!
            
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


struct SoulData {
    let username: String
    let qtt: Int
    let lastRedeem: String
}


func redeemTankSoul(user: String) -> String {
    var json = getJson()
    var tankSouls = json["tanksoul"] as! [[String: Any]]
    let currentTime = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var foundUser = false
    
    for (index, soul) in tankSouls.enumerated() {
        let userName = soul["username"] as! String
        
        if user.lowercased() == userName.lowercased() {
            foundUser = true
            let lastRedeemString = soul["lastRedeem"] as! String
            let lastRedeem = dateFormatter.date(from: lastRedeemString)!
            let qtt = soul["qtt"] as! Int
            
            if let elapsedHours = Calendar.current.dateComponents([.hour], from: lastRedeem, to: currentTime).hour, elapsedHours >= 24 {
                let newQtt = qtt + 1
                tankSouls[index]["qtt"] = newQtt
                tankSouls[index]["lastRedeem"] = dateFormatter.string(from: currentTime)
                updateJson(json: json)
                return "\(user), you now have \(newQtt) tank souls DoritosChip."
            } else {
                return "Sorry \(user), you already got your tank soul for the day. You have \(qtt) souls :p"
            }
        }
    }
    
    if !foundUser {
        let newSoul = ["username": user, "qtt": 1, "lastRedeem": dateFormatter.string(from: currentTime)] as [String : Any]
        tankSouls.append(newSoul)
        json["tanksoul"] = tankSouls
        updateJson(json: json)
        return "\(user), you now have 1 tank soul DoritosChip"
    }
}


func calculatePower(power: String) -> String{
    let power = Double(power) ?? 0
    if power == 0 {
        return "Please give a valid power number"
    }
    let full = String(format: "%.2f", 100 / power)
    let lowerBound = String(format: "%.2f", 100 / (power - 1))
    let lowerMid = String(format: "%.2f", 100 / (power - 0.5))
    let highMid = String(format: "%.2f", 100 / (power + 0.5))
    let highBound = String(format: "%.2f", 100 / (power + 1))

    return "\(lowerBound) | \(lowerMid) | \(full) | \(highMid) | \(highBound)"
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
    let l: Int
    let h: Int
    let g: Int
    let s: Int
}

func calculateLevel(data: [String], commandName: String, user: String) -> String {
    
    let regularCost: [CostTable] = [
        CostTable(l: 1, h: 2, g: 25, s: 15),
        CostTable(l: 2, h: 3, g: 35, s: 20),
        CostTable(l: 3, h: 4, g: 50, s: 25),
        CostTable(l: 4, h: 5, g: 100, s: 50),
        CostTable(l: 5, h: 6, g: 120, s: 60),
        CostTable(l: 6, h: 7, g: 140, s: 70),
        CostTable(l: 7, h: 8, g: 160, s: 80),
        CostTable(l: 8, h: 9, g: 180, s: 90),
        CostTable(l: 9, h: 10, g: 200, s: 100),
        CostTable(l: 10, h: 11, g: 220, s: 110),
        CostTable(l: 11, h: 12, g: 240, s: 120),
        CostTable(l: 12, h: 13, g: 260, s: 130),
        CostTable(l: 13, h: 14, g: 280, s: 140),
        CostTable(l: 14, h: 15, g: 300, s: 150),
        CostTable(l: 15, h: 16, g: 320, s: 160),
        CostTable(l: 16, h: 17, g: 340, s: 170),
        CostTable(l: 17, h: 18, g: 360, s: 180),
        CostTable(l: 18, h: 19, g: 380, s: 190),
        CostTable(l: 19, h: 20, g: 400, s: 200),
        CostTable(l: 20, h: 21, g: 450, s: 220),
        CostTable(l: 21, h: 22, g: 500, s: 240),
        CostTable(l: 22, h: 23, g: 550, s: 260),
        CostTable(l: 23, h: 24, g: 600, s: 280),
        CostTable(l: 24, h: 25, g: 675, s: 300),
        CostTable(l: 25, h: 26, g: 750, s: 320),
        CostTable(l: 26, h: 27, g: 825, s: 340),
        CostTable(l: 27, h: 28, g: 900, s: 360),
        CostTable(l: 28, h: 29, g: 1000, s: 380),
        CostTable(l: 29, h: 30, g: 1200, s: 400)
    ]
    
    let legendaryCost: [CostTable] = [
        CostTable(l: 1, h: 2, g: 50, s: 10),
        CostTable(l: 2, h: 3, g: 70, s: 10),
        CostTable(l: 3, h: 4, g: 100, s: 10),
        CostTable(l: 4, h: 5, g: 200, s: 10),
        CostTable(l: 5, h: 6, g: 240, s: 10),
        CostTable(l: 6, h: 7, g: 280, s: 10),
        CostTable(l: 7, h: 8, g: 320, s: 10),
        CostTable(l: 8, h: 9, g: 360, s: 10),
        CostTable(l: 9, h: 10, g: 400, s: 10),
        CostTable(l: 10, h: 11, g: 440, s: 15),
        CostTable(l: 11, h: 12, g: 480, s: 15),
        CostTable(l: 12, h: 13, g: 520, s: 15),
        CostTable(l: 13, h: 14, g: 560, s: 15),
        CostTable(l: 14, h: 15, g: 600, s: 15),
        CostTable(l: 15, h: 16, g: 640, s: 15),
        CostTable(l: 16, h: 17, g: 680, s: 15),
        CostTable(l: 17, h: 18, g: 720, s: 15),
        CostTable(l: 18, h: 19, g: 760, s: 15),
        CostTable(l: 19, h: 20, g: 800, s: 15),
        CostTable(l: 20, h: 21, g: 850, s: 20),
        CostTable(l: 21, h: 22, g: 900, s: 20),
        CostTable(l: 22, h: 23, g: 950, s: 20),
        CostTable(l: 23, h: 24, g: 1000, s: 20),
        CostTable(l: 24, h: 25, g: 1100, s: 20),
        CostTable(l: 25, h: 26, g: 1200, s: 20),
        CostTable(l: 26, h: 27, g: 1300, s: 20),
        CostTable(l: 27, h: 28, g: 1500, s: 20),
        CostTable(l: 28, h: 29, g: 1600, s: 20),
        CostTable(l: 29, h: 30, g: 2000, s: 20)
    ]
    
    let capRegularCost: [CostTable] = [
        CostTable(l: 1, h: 2, g: 6, s: 7),
        CostTable(l: 2, h: 3, g: 7, s: 8),
        CostTable(l: 3, h: 4, g: 8, s: 9),
        CostTable(l: 4, h: 5, g: 9, s: 10),
        CostTable(l: 5, h: 6, g: 10, s: 11),
        CostTable(l: 6, h: 7, g: 15, s: 12),
        CostTable(l: 7, h: 8, g: 20, s: 13),
        CostTable(l: 8, h: 9, g: 25, s: 14),
        CostTable(l: 9, h: 10, g: 30, s: 15),
        CostTable(l: 10, h: 11, g: 35, s: 16),
        CostTable(l: 11, h: 12, g: 40, s: 17),
        CostTable(l: 12, h: 13, g: 45, s: 18),
        CostTable(l: 13, h: 14, g: 50, s: 19),
        CostTable(l: 14, h: 15, g: 55, s: 20),
        CostTable(l: 15, h: 16, g: 60, s: 22),
        CostTable(l: 16, h: 17, g: 65, s: 24),
        CostTable(l: 17, h: 18, g: 70, s: 26),
        CostTable(l: 18, h: 19, g: 75, s: 28),
        CostTable(l: 19, h: 20, g: 100, s: 30),
        CostTable(l: 20, h: 21, g: 120, s: 40),
        CostTable(l: 21, h: 22, g: 140, s: 60),
        CostTable(l: 22, h: 23, g: 160, s: 60),
        CostTable(l: 23, h: 24, g: 180, s: 70),
        CostTable(l: 24, h: 25, g: 200, s: 90),
        CostTable(l: 25, h: 26, g: 220, s: 90),
        CostTable(l: 26, h: 27, g: 240, s: 100),
        CostTable(l: 27, h: 28, g: 260, s: 115),
        CostTable(l: 28, h: 29, g: 280, s: 130),
        CostTable(l: 29, h: 30, g: 300, s: 150)
    ]
    
    let capLegendaryCost: [CostTable] = [
        CostTable(l: 1, h: 2, g: 12, s: 10),
        CostTable(l: 2, h: 3, g: 14, s: 10),
        CostTable(l: 3, h: 4, g: 16, s: 10),
        CostTable(l: 4, h: 5, g: 18, s: 10),
        CostTable(l: 5, h: 6, g: 20, s: 10),
        CostTable(l: 6, h: 7, g: 30, s: 10),
        CostTable(l: 7, h: 8, g: 40, s: 10),
        CostTable(l: 8, h: 9, g: 50, s: 10),
        CostTable(l: 9, h: 10, g: 60, s: 10),
        CostTable(l: 10, h: 11, g: 70, s: 15),
        CostTable(l: 11, h: 12, g: 80, s: 15),
        CostTable(l: 12, h: 13, g: 90, s: 15),
        CostTable(l: 13, h: 14, g: 100, s: 15),
        CostTable(l: 14, h: 15, g: 110, s: 15),
        CostTable(l: 15, h: 16, g: 120, s: 15),
        CostTable(l: 16, h: 17, g: 130, s: 15),
        CostTable(l: 17, h: 18, g: 140, s: 15),
        CostTable(l: 18, h: 19, g: 150, s: 15),
        CostTable(l: 19, h: 20, g: 200, s: 15),
        CostTable(l: 20, h: 21, g: 220, s: 20),
        CostTable(l: 21, h: 22, g: 240, s: 20),
        CostTable(l: 22, h: 23, g: 260, s: 20),
        CostTable(l: 23, h: 24, g: 280, s: 20),
        CostTable(l: 24, h: 25, g: 300, s: 20),
        CostTable(l: 25, h: 26, g: 320, s: 20),
        CostTable(l: 26, h: 27, g: 340, s: 20),
        CostTable(l: 27, h: 28, g: 360, s: 20),
        CostTable(l: 28, h: 29, g: 380, s: 20),
        CostTable(l: 29, h: 30, g: 400, s: 20)
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
            return "@\(user) Those are not valid levels :p Command usage is: !levelup/!levelupcaptain starting_level ending_level or !levelup/!levelupcaptain legendary starting_level ending_level. E.g: !levelup 3 17"
        }
        
        var coins = 0
        var scrolls = 0
        // Determine which table to use
        var lTable: [CostTable] = []
        var rTable: [CostTable] = []
        if commandName.contains("captain") {
            lTable = capLegendaryCost
            rTable = capRegularCost
        } else {
            lTable = legendaryCost
            rTable = regularCost
        }
        
        if isLegendary {
            for level in startingLevel..<endingLevel {
                if let cost = lTable.first(where: { $0.l <= level && $0.h > level }) {
                    coins += cost.g
                    scrolls += cost.s
                } else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
            }
        } else {
            for level in startingLevel..<endingLevel {
                if let cost = rTable.first(where: { $0.l <= level && $0.h > level }) {
                    coins += cost.g
                    scrolls += cost.s
                } else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
            }
        }
        
        return "@\(user) level up cost will be \(coins) coins and \(scrolls) scrolls"
        
    } catch {
        return "@\(user) command usage is: !levelup/!levelupcaptain starting_level ending_level or !levelup/!levelupcaptain legendary starting_level ending_level. E.g: !levelup 3 17"
    }
}
