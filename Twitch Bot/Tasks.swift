//
//  Tasks.swift
//  Twitch bot
//
//  Created by leon on 3/16/24.
//

import Foundation

func updateUserData() {
    if UserDefaults.standard.value(forKey: "twitchToken") is String {
        print("Starting chat bot...")
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
        
        print("Insert full folder path where data.json and sound.mp3 will be:\nExample: /Users/yourusername/ChatBot/")
        if let path = readLine(), !path.isEmpty {
            UserDefaults.standard.setValue(path, forKey: "filePath")
            UserDefaults.standard.synchronize()
        }
    }
}

func deleUserData() {
    let keysToRemove = ["twitchToken", "srToken", "channelName", "botUserName", "botRealName", "botNick", "filePath", "dataVersion", "clientVersion"]
    
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

func getStreamer() -> String {
    return UserDefaults.standard.object(forKey: "channelName") as! String
}

func getFilePath() -> String{
    return UserDefaults.standard.object(forKey: "filePath") as! String
}

func getJson() -> [String: Any] {
    let path = getFilePath()
    let filePath = "\(path)data.json"
    let url = URL(fileURLWithPath: filePath)
    do {
        let data = try Data(contentsOf: url)
        
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        return json as! [String: Any]
    } catch {
        print("Error: Unable to read or parse the JSON file - \(error)")
    }
    return [:]
}

func updateJson(json: [String: Any]) {
    let path = getFilePath()
    let filePath = "\(path)data.json"
    let url = URL(fileURLWithPath: filePath)
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try jsonData.write(to: url)
        print("JSON data has been updated and saved.")
    } catch {
        print("Error: Unable to update and save the JSON data - \(error)")
    }
}


func getCodeString(code: String) -> String {
    let wordBankPath = "/usr/share/dict/words"
    // Add words to skip as needed
    let skipWords = [""]
    
    guard let wordBankContents = try? String(contentsOfFile: wordBankPath) else {
        return "Error: Unable to load word bank"
    }
    
    let words = wordBankContents.components(separatedBy: .newlines)
    
    
    var result = ""
    for char in code {
        let filteredWords = words.filter { word in
            let notAllowedPrefix = word.lowercased().starts(with: "trans") || word.lowercased().starts(with: "anti")
            let notAllowedSuffix = word.lowercased().hasSuffix("ism") || word.lowercased().hasSuffix("isms") || word.lowercased().hasSuffix("phile") || word.lowercased().hasSuffix("philes") || word.lowercased().hasSuffix("ist") || word.lowercased().hasSuffix("ists")
            let notInSkipWords = !skipWords.contains(word.lowercased())
            return word.hasPrefix(String(char)) && word.count > 6 && !notAllowedPrefix && !notAllowedSuffix && notInSkipWords
        }
        if let randomWord = filteredWords.randomElement() {
            let capitalizedWord = randomWord.capitalized
            result += capitalizedWord + " "
        }
    }
    
    return result.trimmingCharacters(in: .whitespaces)
}

func calculateDuration(startTime: String, endTime: String) -> Double {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    guard let startTime = dateFormatter.date(from: startTime),
          let endTime = dateFormatter.date(from: endTime) else {
        fatalError("Failed to convert string to date")
    }

    return ((endTime.timeIntervalSince(startTime) / 3600) * 100).rounded() / 100
}


func playTTS(ttsString: String) {
    let process = Process()
        process.launchPath = "/usr/bin/say"
        process.arguments = [ttsString]
        process.launch()
        process.waitUntilExit()
}


func sendFirstMessage() -> Bool {
    let startUp = UserDefaults.standard.bool(forKey: "startUp")
    if !startUp {
        UserDefaults.standard.setValue(true, forKey: "startUp")
        UserDefaults.standard.synchronize()
        return true
    }
    else {
        return false
    }
}
