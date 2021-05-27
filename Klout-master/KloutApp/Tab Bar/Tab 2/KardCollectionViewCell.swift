

import UIKit
import QuartzCore
import HFCardCollectionViewLayout
import GoogleSignIn

class KardCollectionViewCell: HFCardCollectionViewCell {
    
    var cardAccounts = [Account](arrayLiteral: Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "Add accounts to see your Kard", posts: "", followers: "", following: ""),
                                 Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "Add accounts to see your Kard", posts: "", followers: "", following: ""),
                                 Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "Add accounts to see your Kard", posts: "", followers: "", following: ""),
                                 Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "Add accounts to see your Kard", posts: "", followers: "", following: ""),
                                 Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "Add accounts to see your Kard", posts: "", followers: "", following: ""))
    var noCards = false
    
    var cardCollectionViewLayout: HFCardCollectionViewLayout?
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet var buttonFlip: UIButton?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var labelText: UILabel?
    @IBOutlet var imageIcon: UIImageView?
    
    @IBOutlet var backView: UIView?
    @IBOutlet var buttonFlipBack: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonFlip?.isHidden = true
        self.tableView?.scrollsToTop = false
        
        self.cellTitleLabel.text = "asdasdasd"
        
        if let name = GIDSignIn.sharedInstance()?.currentUser.profile.givenName {
            cellTitleLabel.text = "\(name)'s Klout"
        }
        
        //let uid = GIDSignIn.sharedInstance()?.currentUser.userID
        let dimension = round(130 * UIScreen.main.scale);
        let pic = GIDSignIn.sharedInstance()?.currentUser.profile.imageURL(withDimension: UInt(dimension))
        cellImageView.af.setImage(withURL: pic!)
        
        self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "TableCell")
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.allowsSelectionDuringEditing = false
        self.tableView?.rowHeight = 111
        self.tableView?.reloadData()
        
    }
    
    func cardIsRevealed(_ isRevealed: Bool) {
        self.buttonFlip?.isHidden = !isRevealed
        self.tableView?.scrollsToTop = isRevealed
    }
    
    @IBAction func buttonFlipAction() {
        if let backView = self.backView {
            // Same Corner radius like the contentview of the HFCardCollectionViewCell
            backView.layer.cornerRadius = self.cornerRadius
            backView.backgroundColor = self.backgroundColor
            backView.layer.masksToBounds = true
            
            self.cardCollectionViewLayout?.flipRevealedCard(toView: backView)
        }
    }
    
    
}

extension KardCollectionViewCell : UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
            cell.socialImageView.image = UIImage(systemName: "person.circle")!
        }
        else{
            cell.socialImageView.image = cardAccounts[indexPath.row].socialMediaIcon
            cell.usernameLabel.text = "@\(cardAccounts[indexPath.row].accountName)"
        }

        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // nothing
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let anAction = UITableViewRowAction(style: .default, title: "An Action")
//        {
//            (action, indexPath) -> Void in
//            // code for action
//        }
//        return [anAction]
//    }
    
}
