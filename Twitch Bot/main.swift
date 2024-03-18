//
//  main.swift
//  Twitch bot
//
//  Created by leon on 3/16/24.
//

import Foundation

func main() {
    print("Press ENTER to continue.\n\"clear\" to delete your data.\n\"exit\" to close the application.")
    let cmd = readLine()

    switch cmd {
    case "clear":
        deleUserData()
    case "exit":
        exit(0)
    default:
        break
    }

    updateUserData()

    /*
    let msg = addWatchList(username: "maria")

    banUser(username: "angel") { result in
        print(result)
    }
    unbanUser(username: "angel") { result in
        print(result)
    }
     */
    let _ = TwitchChat()
    
    // Continuous loop to keep the program running.
    while true {
        DispatchQueue.global().async {
            // twitchChat.sendMessage("Hello, world!")
        }
        sleep(3)
    }
}

main()
