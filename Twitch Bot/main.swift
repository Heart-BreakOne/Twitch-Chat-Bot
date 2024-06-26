//
//  main.swift
//  Twitch bot
//
//  Created by leon on 3/16/24.
//

import Foundation
import Dispatch

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
    //updateGameData()
    
    UserDefaults.standard.setValue(false, forKey: "startUp")
    UserDefaults.standard.synchronize()

    let twitchChatClosure = { () -> Void in
        while true {
            var twitchChat: TwitchChat? = TwitchChat()
    
            sleep(500)
            twitchChat?.terminate()
            twitchChat = nil
        }
    }
    let backgroundQueue = DispatchQueue(label: "com.example.backgroundQueue", qos: .background)
    backgroundQueue.async {
        while true {
            sleep(5000)
            //checkMidPatch()
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
