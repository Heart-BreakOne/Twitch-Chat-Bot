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

    let twitchChatClosure = { () -> Void in
        while true {
            let twitchChat = TwitchChat()
            sleep(600)
        }
    }
    twitchChatClosure()

    /*let _ = TwitchChat()
    
    // Continuous loop to keep the program running.
    while true {
        DispatchQueue.global().async {
            // Background tasks if needed
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Loop delay
        }
    }*/
}

main()
