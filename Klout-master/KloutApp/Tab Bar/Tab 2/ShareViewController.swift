//
//  ShareViewController.swift
//  KloutApp
//
//  Created by Kyle Burns on 3/2/21.
//

import UIKit
import XLPagerTabStrip

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var cardAccounts = [Account](arrayLiteral: Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "Add accounts to see your Kard", posts: "", followers: "", following: ""))
    var noCards = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 111
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title:"Your Kards")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        for account in Globals.user.accounts {
            if(account.accountName != ""){
                cardAccounts[count] = Account(socialMediaIcon: account.socialMediaIcon, socialMediaName: account.socialMediaName, accountName: account.accountName, posts: "", followers: "", following: "")
                count+=1
            }
        }
        if(count == 0){
            noCards = true
            return 1
        }
        else{
            return count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareCell") as! ShareTableViewCell
        
        if(noCards){
            cell.socialImageView.image = UIImage(named: "redQuestionMark")
        }
        else{
            cell.socialImageView.image = cardAccounts[indexPath.row].socialMediaIcon
            cell.usernameLabel.text = "@\(cardAccounts[indexPath.row].accountName)"
        }
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
