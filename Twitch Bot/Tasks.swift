//
//  Tasks.swift
//  Twitch bot
//
//  Created by leon on 3/16/24.
//

import Foundation

func updateUserData() {
    if UserDefaults.standard.value(forKey: "twitchToken") is String {
        print("Token already exists, starting chat bot...")
    } else {
        print("Insert SR token:")
        if let srToken = readLine(), !srToken.isEmpty {
            UserDefaults.standard.set(srToken, forKey: "srToken")
            UserDefaults.standard.synchronize()
        }
        print("Insert Twitch token:")
        if var token = readLine(), !token.isEmpty {
            token = "oauth:\(token)"
            UserDefaults.standard.set(token, forKey: "twitchToken")
            UserDefaults.standard.synchronize()
        }
        print("Insert channel name that will be joined:")
        if let chName = readLine(), !chName.isEmpty {
            UserDefaults.standard.set(chName, forKey: "channelName")
            UserDefaults.standard.synchronize()
        }
        print("Insert chat bot username:")
        if let chatBot = readLine(), !chatBot.isEmpty {
            UserDefaults.standard.set(chatBot, forKey: "botUserName")
            UserDefaults.standard.synchronize()
        }
        print("Insert chat bot real name:")
        if let botRealName = readLine(), !botRealName.isEmpty {
            UserDefaults.standard.set(botRealName, forKey: "botRealName")
            UserDefaults.standard.synchronize()
        }
        print("Insert chat bot nick:")
        if let botNick = readLine(), !botNick.isEmpty {
            UserDefaults.standard.set(botNick, forKey: "botNick")
            UserDefaults.standard.synchronize()
        }
        
    }
}

func deleUserData() {
    let keysToRemove = ["twitchToken", "srToken", "channelName", "botUserName", "botRealName", "botNick"]
    
    for key in keysToRemove {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    UserDefaults.standard.synchronize()
    print("Deleted your tokens successfully!")
}
func getTwitchData() -> (String, String, String, String, String) {
    let token = UserDefaults.standard.object(forKey: "twitchToken") as! String
    let channel = UserDefaults.standard.object(forKey: "channelName") as! String
    let bot = UserDefaults.standard.object(forKey: "botUserName") as! String
    let real = UserDefaults.standard.object(forKey: "botRealName") as! String
    let nick = UserDefaults.standard.object(forKey: "botNick") as! String
    return (token, channel, bot, real, nick)
}

func getJson() -> [String: Any] {
    
    let filePath = "/Users/leonardoluiz/dev/SR-Tools/Twitch bot/Twitch bot/Assets/data.json"
    let url = URL(fileURLWithPath: filePath)
    do {
        // Read the contents of the file
        let data = try Data(contentsOf: url)
        
        // Parse the JSON data
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        // Handle the JSON object as needed
        return json as! [String: Any]
    } catch {
        print("Error: Unable to read or parse the JSON file - \(error)")
    }
    return [:]
}



func updateJson(json: [String: Any]) {
    let filePath = "/Users/leonardoluiz/dev/SR-Tools/Twitch bot/Twitch bot/Assets/data.json"
    let url = URL(fileURLWithPath: filePath)
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try jsonData.write(to: url)
        print("JSON data has been updated and saved.")
    } catch {
        print("Error: Unable to update and save the JSON data - \(error)")
    }
}
