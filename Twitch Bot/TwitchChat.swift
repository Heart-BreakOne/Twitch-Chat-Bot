
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
        
        // let formattedTime = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        // channel?.send("\(formattedTime) - DoritosChip")
        // channel?.send("DoritosChip")
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
            if user == getStreamer() && (commandName == "!log") {
                let data = command.components(separatedBy: " ")
                if (data.count != 4) {
                    channel.send("Can't log DoritosChip")
                    return
                }
                channel.send(logBattle(eventId: data[1], captainName: data[2], outcome: data[3]))
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
    case "!unban":
        if argument != "" {
            unbanUser(username: argument) { result in
                channel.send(result)
            }
        } else {
            unbanUser(username: user) { result in
                channel.send(result)
            }
        }
    case "!ban":
        let streamer = getStreamer()
        if (argument == "") {
            channel.send("I can't ban DoritosChip")
            return
        }
        else if (streamer == user) {
            banUser(username: argument) { result in
                channel.send(result)
            }
        }
        else {
            channel.send("Only the captain can do that :p")
        }
    case "!streak":
        channel.send(sendStreak())
    case "!setcode":
        let streamer = getStreamer()
        if (streamer == user) {
            channel.send(setCode(code: argument))
        }
    case "!quote":
        channel.send(sendRdmStr(key: "gameTips"))
    case "!code":
        channel.send("\(sendCode())")
    case "bop":
        channel.send("\(sendCode())")
    case "!box":
        channel.send(sendRdmStr(key: "phrases"))
    case "!permalist":
        if (argument == "") {
            channel.send("I can't put DoritosChip on the permalist")
            return
        } else {
            let streamer = getStreamer()
            if (streamer == user) {
                channel.send(updateList(username: argument, listId: "permalist"))
            }
        }
    case "!watchlist":
        if (argument == "") {
            channel.send("I can't put DoritosChip on the watchlist")
            return
        } else {
            let streamer = getStreamer()
            if (streamer == user) {
                channel.send(updateList(username: argument, listId: "watchlist"))
            }
        }
    case "!commands", "!command":
        channel.send(sendCommands())
    case "!ping":
        channel.send("pong")
        //case "!predict":
        // channel.send("We are still collecting enough data to reliably predict battles DoritosChip")
    case "!stats":
        if(argument == "doritoschip") {
            channel.send("DoritosChip Winning rate is 100% DoritosChip")
        } else {
            channel.send(checkStats(from: argument))
        }
    case "!streamraiders", "!join", "!sr":
        channel.send("\(user) Join the fight at https://www.streamraiders.com/t/\(getStreamer())")
    case "!lurk":
        channel.send("DoritosChip \(user) enjoy lurking DoritosChip")
    case "!unlurk":
        channel.send("DoritosChip \(user), welcome back to Streamlandia! DoritosChip")
    case "doritoschip", "!doritoschip":
        channel.send(getDoritos())
    case "!log":
        break
    case "!levelup", "!level", "!levelupcaptain", "!levelcaptain":
        break
    case "!mvp":
        
        getMvp(username: user) { result in
            channel.send(result)
        }
    case "!myunit":
        channel.send("@\(user)\(getUnitOfTheDay())")
    case "!chest":
        let streamer = getStreamer()
        channel.send("@\(streamer), a chatter wants to know about a captain that is on a \(argument) chest battle, because you are lazy I can't do it myself, do it for them.")
    case "!rules":
        channel.send("@\(user) the rules are very simple: No tank souls, no spies, no erasing tactical markers and follow the markers if there are any.")
    case "!setmode":
        let streamer = getStreamer()
        if streamer == user {
            channel.send(setGameMode(mode: argument))
        }
    case "!dungeonleaderboard", "!dungeonsleaderboard":
        getDungeonLeaderboard() { leaderBoard in
            channel.send(leaderBoard[0])
            if leaderBoard[1] != "" {
                channel.send(leaderBoard[1])
            }
        }
    case "!power":
        let streamer = getStreamer()
        if streamer == user {
            channel.send(calculatePower(power: argument))
        }
    case "!tanksoul":
        channel.send(redeemTankSoul(user: user))
    default:
        channel.send("DoritosChip \(command) is not a command yet DoritosChip")
    }
}
