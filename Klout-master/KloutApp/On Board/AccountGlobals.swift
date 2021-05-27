//
//  AccountGlobals.swift
//  KloutApp
//
//  Created by Kyle Burns on 5/5/21.
//

import Foundation
import UIKit

class Globals {
    struct user{
        static var accounts = [Account](arrayLiteral:
                                    Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: "", posts: "", followers: "", following: ""),
                                    Account(socialMediaIcon: #imageLiteral(resourceName: "instagramicon"), socialMediaName: "Instagram", accountName: "", posts: "", followers: "", following: ""),
                                    Account(socialMediaIcon: #imageLiteral(resourceName: "youtubeicon"), socialMediaName: "Youtube", accountName: "", posts: "", followers: "", following: ""),
                                    Account(socialMediaIcon: #imageLiteral(resourceName: "twittericon"), socialMediaName: "Twitter", accountName: "", posts: "", followers: "", following: ""),
                                    Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "", posts: "", followers: "", following: ""))
        static var accountSnapshots: [[String: Any]] = []
        static var snapMedia: String = ""
    }
}
