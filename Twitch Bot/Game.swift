//
//  Game.swift
//  Twitch bot
//
//  Created by leon on 3/16/24.
//

import Foundation

let gameUrl = ""

func banUser(username: String, completion: @escaping (String) -> Void){
    
    let json = getJson()
    let permalist = json["mvplist"] as! [String]
    let usr = username.lowercased()
    if permalist.contains(where: { $0.lowercased() == usr }) {
        completion("They are on the PVP mvp list, are you sure?")
        return
    }
    let url = "\(gameUrl)?cn=setBanStatus&command=setBanStatus&twitchUserName=\(username)&isBanned=y"
    makeRequest(urlString: url) { _ in
        // No need to handle the response.
    }
    completion("Done :(")
}

func unbanUser(username: String, completion: @escaping (String) -> Void) {
    
    var json = getJson()
    let permalist = json["permalist"] as! [String]
    if permalist.contains(username) {
        completion("@\(username), can not unban you at this occasion :(")
        return
    }
    var watchlist = json["watchlist"] as! [String]
    watchlist.append(username)
    json["watchlist"] = watchlist
    updateJson(json: json)
    
    
    let bannedUrl = "\(gameUrl)?cn=getBanList&command=getBanList"
    var completionString = ""
    
    makeRequest(urlString: bannedUrl) { data in
        guard let data = data else {
            completion("Unable to fetch ban list.")
            return
        }

        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let status = dict["status"] as! String

                if status != "success" {
                    completion("Unable to fetch ban list.")
                    return
                }

                let usersList = dict["data"] as! [String: Any]
                let banList = usersList["bans"] as! [[String: Any]]

                for banned in banList {
                    guard let ban = banned as? [String : Any], !ban.isEmpty else {
                        continue
                    }

                    let name = banned["twitchUserName"] as! String

                    if username.lowercased() == name.lowercased() {
                        let userId = banned["userId"] as! String
                        let banUrl = "\(gameUrl)?cn=setBanStatus&command=setBanStatus&userId=\(userId)&twitchUserName=\(username)&isBanned=n"
                        
                        makeRequest(urlString: banUrl) { _ in
                            completionString = "@\(username) you have been unbanned, the captain should be visible after this battle. Placing tank souls, spies or erasing tactical markers may grant you a new permanent ban for being a repeat offender."
                            completion(completionString)
                        }
                        return // Return here to avoid calling completion prematurely
                    }
                }

                // If the loop completes without finding the username
                completion("@\(username), you are not banned. Check if you typed the username correctly! Try reloading the game DoritosChip")
            }
        } catch {
            print("Error decoding data: \(error)")
            completion("Error decoding ban list.")
        }
    }
}

//Get top 50 pvp players
func getMvp(username: String, completion: @escaping (String) -> Void){
    let token = UserDefaults.standard.object(forKey: "srToken")! as! String
    let userId = token.components(separatedBy: "%")[0] + "c"
    
    let dV = UserDefaults.standard.object(forKey: "dataVersion")! as! String
    let cV = UserDefaults.standard.object(forKey: "clientVersion")! as! String
    let url = "\(gameUrl)?cn=getPvpRaidsByEvent&userId=\(userId)&isCaptain=1&gameDataVersion=\(dV)&command=getPvpRaidsByEvent&clientVersion=\(cV)&clientPlatform=WebGL"
    makeRequest(urlString: url) { data in
        guard let data = data else {
            completion("Something went wrong :(")
            return
        }
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let status = dict["status"] as! String

                if status != "success" {
                    completion("Something went wrong :(")
                    return
                }
                
                let data = dict["data"] as! [String: Any]
                var stats = data["stats"] as! [[String: String]]
                let streamer = getStreamer()
                for (index, stat) in stats.enumerated() {
                    guard let name = stat["twitchDisplayName"] else {
                        continue
                    }
                    
                    if name.lowercased() == streamer.lowercased() {
                        stats.remove(at: index)
                    }
                }

                stats.sort {
                    guard let units1 = Int($0["unitsPlaced"] ?? "0"),
                          let units2 = Int($1["unitsPlaced"] ?? "0") else {
                        return false
                    }
                    return units1 > units2
                }
                
                if let matchingStat = stats.first(where: { $0["twitchDisplayName"]?.lowercased() == username.lowercased() }) {
                    if let index = stats.firstIndex(where: { $0 == matchingStat }) {
                        let placedUnits = matchingStat["unitsPlaced"]!
                        let kills = matchingStat["kills"]!
                        let assists = matchingStat["assists"]!
                        completion("@\(username) you are #\(index + 1) on the PVP leaderboard with \(placedUnits) placed units, \(kills) kills and \(assists) assists. Thank you for your placements DoritosChip")
                    }
                } else {

                    completion("Couldn't find you in the top 50 :(")
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            completion("Something went wrong :(")
        }
    }
}

func getDungeonLeaderboard( completion: @escaping ([String]) -> Void) {
    let token = UserDefaults.standard.object(forKey: "srToken")! as! String
    let userId = token.components(separatedBy: "%")[0] + "c"
    
    let dV = UserDefaults.standard.object(forKey: "dataVersion")! as! String
    let cV = UserDefaults.standard.object(forKey: "clientVersion")! as! String
    let urlString = "\(gameUrl)?cn=getDungeonLeaderboard&userId=\(userId)&isCaptain=1&gameDataVersion=\(dV)&command=getDungeonLeaderboard&clientVersion=\(cV)&clientPlatform=WebGL"
    makeRequest(urlString: urlString) { data in
        guard let data = data else {
            completion(["Something went wrong :(", ""])
            return
        }
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let status = dict["status"] as! String
                
                if status != "success" {
                    completion(["Something went wrong :(", ""])
                    return
                }
                
                let leaderboard = dict["data"] as! [String: Any]
                let top10 = leaderboard["globalRuns"] as! [[String: Any]]
                var leaderboardString1 = "Leaderboard for latest dungeon is:  "
                var leaderboardString2 = ""
                
                let sortedCaptains = top10.sorted { (cap1, cap2) -> Bool in
                    guard let startTime1 = cap1["startTime"] as? String,
                          let startTime2 = cap2["startTime"] as? String,
                          let completedLevels1 = cap1["completedLevels"] as? String,
                          let completedLevels2 = cap2["completedLevels"] as? String else {
                        return false
                    }
                    
                    let endTime1: String?
                    let endTime2: String?
                    
                    if let endTimeStr1 = cap1["endTime"] as? String {
                        endTime1 = endTimeStr1
                    } else {
                        endTime1 = nil
                    }
                    
                    if let endTimeStr2 = cap2["endTime"] as? String {
                        endTime2 = endTimeStr2
                    } else {
                        endTime2 = nil
                    }
                    
                    guard let endTimeStr1 = endTime1, let endTimeStr2 = endTime2 else {
                        return false
                    }
                    
                    let duration1 = calculateDuration(startTime: startTime1, endTime: endTimeStr1)
                    let duration2 = calculateDuration(startTime: startTime2, endTime: endTimeStr2)
                    
                    if completedLevels1 == completedLevels2 {
                        return duration1 < duration2
                    } else {
                        return false
                    }
                }

                
                // Do the first 5
                for (index, cap) in sortedCaptains.prefix(5).enumerated() {
                    let index = index + 1
                    let capName = cap["twitchDisplayName"] as! String
                    let completedLevels = cap["completedLevels"] as! String
                    let startTime = cap["startTime"] as! String
                    let endTime = cap["endTime"] as? String ?? ""
                    var duration = ""
                    if endTime == "" {
                        duration = "Dungeon in progress. "
                    } else {
                        let durDouble = calculateDuration(startTime: startTime, endTime: endTime)
                        duration = "Completed \(completedLevels) levels in \(durDouble) hours. "
                    }
                    let phrase = "\(index) - \(capName) - \(duration)"
                    leaderboardString1 += phrase
                }
                // Do that last 10
                for (index, cap) in sortedCaptains.suffix(5).enumerated() {
                    let index = index + 5 + 1
                    let capName = cap["twitchDisplayName"] as! String
                    let completedLevels = cap["completedLevels"] as! String
                    let startTime = cap["startTime"] as! String
                    let endTime = cap["endTime"] as? String ?? ""
                    var duration = ""
                    if endTime == "" {
                        duration = "Dungeon in progress. "
                    } else {
                        let durDouble = calculateDuration(startTime: startTime, endTime: endTime)
                        duration = "Completed \(completedLevels) levels in \(durDouble) hours. "
                    }
                    let phrase = "\(index) - \(capName) - \(duration)"
                    leaderboardString2 += phrase
                }
                completion([leaderboardString1, leaderboardString2])
            }
        } catch {
            completion(["Something went wrong :(", ""])
            return
        }
    }
    return
}


func checkMidPatch() {
    makeRequest(urlString: gameUrl) { data in
        guard let data = data else {
            print("Unable to fetch game version data.")
            return
        }
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                let info = dict["info"] as! [String: String]
                
                let dataPath = info["dataPath"]!
                let localDataPath = UserDefaults.standard.string(forKey: "dataPath")
                if dataPath != localDataPath {
                    updateGameData()
                    playTTS(ttsString: "Brace yourselves, a midpatch is coming")
                }
            }
        } catch {
            print("Error decoding data: \(error)")
        }
    }
    sleep(5)
}


func makeRequest(urlString: String, completion: @escaping ((Data?) -> Void)) {
    let token = UserDefaults.standard.object(forKey: "srToken")! as! String
    let url = URL(string: urlString)!
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("ACCESS_INFO=\(token)", forHTTPHeaderField: "Cookie")
    request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
    
    let session = URLSession(configuration: .default)
    
    let task = session.dataTask(with: request) { data, response, error in
        completion(data)
    }
    
    task.resume()
    
}

func updateGameData() {
    let url = "\(gameUrl)?cn=trackEvent&command=trackEvent&eventName=load_timing_init&eventData={\"Type\":\"Init\"}"
    makeRequest(urlString: url) { data in
        guard let data = data else {
            print("Unable to fetch game version data.")
            return
        }
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let status = dict["status"] as! String

                if status != "success" {
                    print("Unable to fetch game version data.")
                    return
                }
                let info = dict["info"] as! [String: String]
                let dataVersion = info["dataVersion"]!
                let clientVersion = info["version"]!
                let dataPath = info["dataPath"]!
                UserDefaults.standard.set(dataVersion, forKey: "dataVersion")
                UserDefaults.standard.set(clientVersion, forKey: "clientVersion")
                UserDefaults.standard.set(dataPath, forKey: "dataPath")
                UserDefaults.standard.synchronize()
                print("Game data is up to date.")
            }
        } catch {
            print("Error decoding data: \(error)")
        }
    }
}
