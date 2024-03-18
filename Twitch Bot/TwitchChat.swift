
//  TwitchChat.swift
//  Created by Michael Forrest on 09/06/2021.

import Foundation

class TwitchChat: IRCServerDelegate, IRCChannelDelegate {
    let session = URLSession(configuration: .default)
    let user: IRCUser
    let server: IRCServer
    let channel: IRCChannel

    init() {
        // Fetch Twitch data
        let (token, chName, bot, real, nick) = getTwitchData()
        
        // Initialize IRCUser
        self.user = IRCUser(
            // Use your own details here:
            username: bot,
            realName: real,
            nick: nick,
            password: token
        )

        // Initialize IRCServer and IRCChannel
        self.server = IRCServer(
            hostname: "irc.chat.twitch.tv",
            port: 6667,
            user: self.user,
            session: session
        )
        // Join the channel you want. This seems to be case-sensitive.
        self.channel = server.join(chName)

        server.delegate = self
        channel.delegate = self

        // Send a message:
        channel.send("DoritosChip")
    }

    func didRecieveMessage(_ server: IRCServer, message: String) {
        print("Server message:", message)
    }

    func didRecieveMessage(_ channel: IRCChannel, message: String) {
        print("Channel message:", message)
    }
}


func handleTwitch() throws {
    sleep(3)
}


