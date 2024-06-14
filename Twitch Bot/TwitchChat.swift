
//  TwitchChat.swift
//  Created by Michael Forrest on 09/06/2021.

import Foundation

//let thxArray = ["thanks", "thank you", "thx", "thank you very much"]

class TwitchChat: IRCServerDelegate, IRCChannelDelegate {
    
    let session = URLSession(configuration: .default)
    var user: IRCUser
    var server: IRCServer?
    var channel: IRCChannel?
    let twitchHostname = "irc.chat.twitch.tv"
    let twitchPort = 6667
    var chName: String
    
    init() {
        
        // Fetch Twitch data
        let (token, fetchedChName, bot, real, nick) = getTwitchData()
        self.chName = fetchedChName
        
        // Initialize IRCUser
        self.user = IRCUser(
            // Use your own details here:
            username: bot,
            realName: real,
            nick: nick,
            password: token
        )
        
        establishConnection()
    }
    
    private func establishConnection() {
        // Initialize IRCServer and IRCChannel
        self.server = IRCServer(
            hostname: twitchHostname,
            port: twitchPort,
            user: self.user,
            session: session
        )
        self.channel = server?.join(chName)

        server?.delegate = self
        channel?.delegate = self
        //let formattedTime = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        //channel?.send("\(formattedTime) - DoritosChip")
        // channel?.send("DoritosChip")
        if sendFirstMessage() {
            channel?.send("I'm in, DON'T FORGET TO DISABLE SHIELD MODE.")
        }
        
    }
    
    func terminate() {
        // Send QUIT message to IRC server
        server?.send("QUIT :Shutting down")
        
        // Clear delegates to avoid retain cycles
        server?.delegate = nil
        channel?.delegate = nil
        
        // Release resources or perform any additional cleanup tasks if needed
        
    }
    
    // Server messages containing user lists, connection confirmation
    func didRecieveMessage(_ server: IRCServer, message: String) {
        // Handle server messages
        //print(message)
        if message == "Welcome, GLHF!" {
            channel?.send(sendRdmStr(key: "typos"))
        }
    }
    
    func didRecieveMessage(_ channel: IRCChannel, message: String) {
        // print(message)
        // Handle channel messages
        let components = message.components(separatedBy: ": ")
        if components.count == 2 {
            let user = components[0]
            let command = components[1]
            /*
             for thxWord in thxArray {
             if command.lowercased().hasPrefix(thxWord) {
             channel.send("@\(user), you're welcome DoritosChip")
             return
             }
             }
             */
            if user.lowercased() == "captaintvbot" {
                if command.lowercased().contains("battle is ready to begin!") {
                    if canPlaySound() {
                        playTTS(ttsString: "The battle is ready to begin!")
                    }
                }
            }
            if !(command.first == "!") && (command != "DoritosChip") && (command != "BOP"){
                return
            }
            
            let commandComponents = command.components(separatedBy: " ")
            var commandName = ""
            var argument = ""
            if let first = commandComponents.first {
                commandName = first
            }
            if commandComponents.count >= 2 {
                argument = commandComponents[1]
            }
            print("\nUser: \(user)")
            print("Command: \(commandName)")
            print("Argument: \(argument)")
            
            verifyCommand(channel: channel, user: user, command: commandName, argument: argument)
            if (user == getStreamer() || user == "") && (commandName == "!log") {
                let data = command.components(separatedBy: " ")
                if (data.count != 3) {
                    channel.send("Can't log DoritosChip")
                    return
                }
                channel.send(logBattle(captainName: data[1], outcome: data[2]))
            }
            else if (user == getStreamer() || user == "") && (commandName == "!p") {
                let data = command.components(separatedBy: " ")
                if (data.count != 3) {
                    channel.send("!p x y")
                    return
                }
                channel.send(calcAmount(numbers: data))
            }
            else if commandName == "!levelup" || commandName == "!level" || commandName == "!levelupcaptain" || commandName == "!levelcaptain" {
                let data = command.components(separatedBy: " ")
                channel.send(calculateLevel(data: data, commandName: commandName, user: user))
            }
        }
    }
}

func verifyCommand(channel: IRCChannel, user: String, command: String, argument: String) {
    let (_, _, bot, _, _) = getTwitchData()
    if (user.lowercased() == bot.lowercased()) {
        return
    }
    let command = command.lowercased()
    let argument = argument.lowercased()
    
    switch command {
    case "!battle":
        playBattle()
    case "!code", "bop":
        channel.send("\(sendCode())")
    case "!setcode":
        let streamer = getStreamer()
        if streamer == user || user == "" {
            channel.send(setCode(code: argument))
        }
    case "!streamraiders", "!join", "!sr":
        channel.send("\(user) Join the fight at https://www.streamraiders.com/t/\(getStreamer())")
    case "!streak":
        channel.send(sendStreak())
    case "!power":
        let streamer = getStreamer()
        if streamer == user || user == "" {
            channel.send(calculatePower(power: argument))
        }
    case "!scene", "!scenes":
        playTTS(ttsString: "Change scenes!")
    case "!mute", "!muted":
        playTTS(ttsString: "Check mic")
    case "!c2f", "!f2c":
        channel.send(convertTemperature(cmd: command, temp: argument))
    case "!rules":
        channel.send("@\(user) the rules are very simple: No tank souls, no spies, no erasing tactical markers and follow the markers if there are any.")
    case "!setmode":
        let streamer = getStreamer()
        if streamer == user || user == "" {
            channel.send(setGameMode(mode: argument))
        }
    case "!ping":
        channel.send("pong")
    case "!stats":
        if(argument == "doritoschip") {
            channel.send("DoritosChip Winning rate is 100% DoritosChip")
        } else {
            channel.send(checkStats(from: argument))
        }
    case "!log":
        break
    case "!levelup", "!level", "!levelupcaptain", "!levelcaptain":
        break
    case "!setsound":
        let streamer = getStreamer()
        if streamer == user || user == "" {
            channel.send(setSound(state: argument))
        }
    case "!commands", "!command":
        channel.send(sendCommands())
    case "!box":
        channel.send(sendRdmStr(key: "phrases"))
    case "!rulebook":
        channel.send(sendRuleBook())
    case "!flipeurocoin":
        channel.send("You flip a Euro coin and get \(Bool.random() ? "heads." : "tails.")")
    case "!lurk":
         channel.send("DoritosChip \(user) enjoy lurking DoritosChip")
    case "!unlurk":
         channel.send("DoritosChip \(user), welcome back to Streamlandia! DoritosChip")
    case "!tanksoul":
         channel.send(redeemTankSoul(user: user))
    case "!myunit":
         channel.send("@\(user)\(getUnitOfTheDay())")
    case "doritoschip", "!doritoschip":
         channel.send(getDoritos())
    case "!cockroach":
         channel.send(sendRdmStr(key: "cockroaches"))
    case "!rigged":
        channel.send("Stream Raiders is rigged u.u")
    case "!souls", "!soul":
        channel.send(sendRdmStr(key: "souls_command"))
    case "!archer", "!barbarian", "!bomber", "!buster", "!flag", "!healer", "!lancer", "!paladin", "!rogue", "!saint", "!tank", "!vampire", "!warrior":
        channel.send(getSoulInfo(key: command))
    default:
        return
    }
        
    /*
    case "!predict":
         channel.send("We are still collecting enough data to reliably predict battles DoritosChip")
    case "!quote":
         channel.send(sendRdmStr(key: "gameTips"))
    case "!permalist":
         if (argument == "") {
             channel.send("I can't put DoritosChip on the permalist")
             return
         } else {
             let streamer = getStreamer()
             if (streamer == user || user == "") {
                 channel.send(updateList(username: argument, listId: "permalist"))
             }
         }
    case "!watchlist":
         if (argument == "") {
             channel.send("I can't put DoritosChip on the watchlist")
             return
         } else {
             let streamer = getStreamer()
             if (streamer == user || user == "") {
                 channel.send(updateList(username: argument, listId: "watchlist"))
             }
         }
    case "!mvp":
        getMvp(username: user) { result in
            channel.send(result)
        }
    case "!chest":
         let streamer = getStreamer()
         channel.send("@\(streamer), a chatter wants to know about a captain that is on a \(argument) chest battle, because you are lazy I can't do it myself, do it for them.")
    
    case "!dungeonleaderboard", "!dungeonsleaderboard":
        getDungeonLeaderboard() { leaderBoard in
            channel.send(leaderBoard[0])
            if leaderBoard[1] != "" {
                channel.send(leaderBoard[1])
            }
        }
    case "!unban":
         let streamer = getStreamer()
         if (streamer == user || user == "") {
             unbanUser(username: argument) { result in
                 channel.send(result)
             }
         } else {
             channel.send("Only the captain can do that :p")
         }
    case "!ban":
         let streamer = getStreamer()
         if (argument == "") {
             channel.send("I can't ban DoritosChip")
             return
         }
         else if (streamer == user || user == "") {
             banUser(username: argument) { result in
                 channel.send(result)
             }
         }
         else {
             channel.send("Only the captain can do that :p")
         }
    */
}
