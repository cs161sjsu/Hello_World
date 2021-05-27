//
//  StatisticsViewController.swift
//  KloutApp
//
//  Created by Kyle Burns on 2/23/21.
//

import UIKit
import Alamofire
import AlamofireImage
import GoogleSignIn
import Firebase

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var alertTextView: UITextField!
    
    var refreshControl = UIRefreshControl()
    
    var accountToSend = Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: "", posts: "", followers: "", following: "")
    
    var platform = "tiktok"
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(accountToSend.socialMediaName == "Instagram"){
            platform = "instagram"
        }
        else if(accountToSend.socialMediaName == "Youtube"){
            platform = "youtube"
        }
        
        populateUserData()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 111
        
        nameLabel.text = GIDSignIn.sharedInstance()?.currentUser.profile.givenName
        //let uid = GIDSignIn.sharedInstance()?.currentUser.userID
        let dimension = round(130 * UIScreen.main.scale);
        let pic = GIDSignIn.sharedInstance()?.currentUser.profile.imageURL(withDimension: UInt(dimension))
        profileImageView.af.setImage(withURL: pic!)
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func populateUserData(){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            else if let data = snapshot?.data() {
                for (index, account) in Globals.user.accounts.enumerated() {
                    if(account.socialMediaName == "Youtube"){
                        if let youtube = data["youtube"] as? String {
                            if(youtube != ""){
                                self.addYoutubeAccount(name: youtube, index: index)
                            }
                        }
                    }
                    else if(account.socialMediaName == "TikTok"){
                        if let tiktok = data["tiktok"] as? String {
                            if(tiktok != ""){
                                self.addTikTokAccount(name: tiktok, index: index)
                            }
                        }
                    }
                    else if(account.socialMediaName == "Instagram"){
                        if let instagram = data["instagram"] as? String {
                            if(instagram != ""){
                                self.addInstagramAccount(name: instagram, index: index)
                            }
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
                
        }
        
    }
    
    
    
    @IBAction func onShowMenu(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alertController.addAction(UIAlertAction(title: "", style: .default, handler: { alertAction in
//            // Handle Take Photo here
//            }))
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { alertAction in
            GIDSignIn.sharedInstance()?.signOut()
            Globals.user.accounts = [Account](arrayLiteral:
            Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: "", posts: "", followers: "", following: ""),
            Account(socialMediaIcon: #imageLiteral(resourceName: "instagramicon"), socialMediaName: "Instagram", accountName: "", posts: "", followers: "", following: ""),
            Account(socialMediaIcon: #imageLiteral(resourceName: "youtubeicon"), socialMediaName: "Youtube", accountName: "", posts: "", followers: "", following: ""),
            Account(socialMediaIcon: #imageLiteral(resourceName: "twittericon"), socialMediaName: "Twitter", accountName: "", posts: "", followers: "", following: ""),
            Account(socialMediaIcon: #imageLiteral(resourceName: "twitchicon"), socialMediaName: "Twitch", accountName: "", posts: "", followers: "", following: ""))
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginNavigationController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            }))
        
        alertController.modalPresentationStyle = .popover
        self.present(alertController, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Globals.user.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(Globals.user.accounts[indexPath.row].accountName.count == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccountCell") as! AddAccountTableViewCell
            cell.socialImageView.image = Globals.user.accounts[indexPath.row].socialMediaIcon
            if(Globals.user.accounts[indexPath.row].socialMediaName == "Twitter" || Globals.user.accounts[indexPath.row].socialMediaName == "Twitch"){
                cell.cellTextLabel.text = "Coming Soon"
            }
            else{
                cell.cellTextLabel.text = "Add Account +"
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsCell") as! StatisticsTableViewCell
            cell.socialImageView.image = Globals.user.accounts[indexPath.row].socialMediaIcon
            cell.usernameLabel.text = "@\(Globals.user.accounts[indexPath.row].accountName)"
            cell.followersLabel.text = formatNumbers(value: Globals.user.accounts[indexPath.row].followers)
            cell.followingLabel.text = formatNumbers(value: Globals.user.accounts[indexPath.row].following)
            cell.postsLabel.text = formatNumbers(value: Globals.user.accounts[indexPath.row].posts)

            if(Globals.user.accounts[indexPath.row].socialMediaName == "Youtube"){
                cell.quantityLabel1.text = "Videos"
                cell.quantityLabel2.text = "Subscribers"
                cell.quantityLabel3.text = "Views"
            }
            else if(Globals.user.accounts[indexPath.row].socialMediaName == "Instagram"){
                cell.quantityLabel1.text = "Posts"
                cell.quantityLabel2.text = "Followers"
                cell.quantityLabel3.text = "Following"
            }
            else if(Globals.user.accounts[indexPath.row].socialMediaName == "Twitter"){
                cell.quantityLabel1.text = "Tweets"
                cell.quantityLabel2.text = "Followers"
                cell.quantityLabel3.text = "Following"
            }
            else if(Globals.user.accounts[indexPath.row].socialMediaName == "TikTok"){
                cell.quantityLabel1.text = "Posts"
                cell.quantityLabel2.text = "Followers"
                cell.quantityLabel3.text = "Likes"
            }
            return cell
        }
        
        
    }
    
    func checkForSnapshots(name: String, platform: String){
        let docRef = db.collection("snapshots").document("\(platform)_\(name)")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //snapshot collection already exists
            } else {
                //Firestore.firestore().collection("snapshots").document("\(platform)_\(name)").collection("snapshots").document("").set
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let unknownCell = tableView.cellForRow(at: indexPath)
        if(unknownCell is StatisticsTableViewCell){
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsCell") as! StatisticsTableViewCell
            
            accountToSend = Globals.user.accounts[indexPath.row]
            
            var platform = "tiktok"
            Globals.user.snapMedia = "tiktok"
            //Send arrays of snapshots accordingly
            if(accountToSend.socialMediaName == "Instagram"){
                platform = "instagram"
                Globals.user.snapMedia = "instagram"
            }
            else if(accountToSend.socialMediaName == "Youtube"){
                platform = "youtube"
                Globals.user.snapMedia = "youtube"
            }
            
//            let db = Firestore.firestore()
//            db.collection("snapshots").document("\(platform)_\(accountToSend.accountName)").collection("snapshots").getDocuments(completion: { (snap, err) in
//                if let err = err {
//                    print("Error grabbing snapshot documents: \(err)")
//                }
//                else if let data = snap?.documents {
//                    for document in data {
//                        document.documentID
//                        let doc = ["\(document.documentID)" : document.data()]
//                        Globals.user.accountSnapshots.append(doc)
//                        //self.snapshotsToSend.append(document.data())
//                    }
//                }
//            })
            
            //self.performSegue(withIdentifier: "toAccountStatistics", sender: self)
        }
        else if(unknownCell is AddAccountTableViewCell){
            if(!(Globals.user.accounts[indexPath.row].socialMediaName == "Twitter" || Globals.user.accounts[indexPath.row].socialMediaName == "Twitch")){
                let alertController = UIAlertController(title: "Add \(Globals.user.accounts[indexPath.row].socialMediaName) Account", message: "", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: configurationTextField)
                let addAction = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                    //Add user code
                    let username = self.alertTextView.text!.replacingOccurrences(of: "@", with: "")
                    
                    if(Globals.user.accounts[indexPath.row].socialMediaName == "Instagram"){
                        self.addInstagramAccount(name: username, index: indexPath.row)
                    }
                    else if(Globals.user.accounts[indexPath.row].socialMediaName == "Twitter"){
                        self.addTwitterAccount(name: username, index: indexPath.row)
                    }
                    else if(Globals.user.accounts[indexPath.row].socialMediaName == "Youtube"){
                        self.addYoutubeAccount(name: username, index: indexPath.row)
                    }
                    else if(Globals.user.accounts[indexPath.row].socialMediaName == "TikTok"){
                        self.addTikTokAccount(name: username, index: indexPath.row)
                    }
                    else if(Globals.user.accounts[indexPath.row].socialMediaName == "Twitch"){
                        self.addTwitchAccount(name: username, index: indexPath.row)
                    }
                    
                    }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                        //code here
                    
                    }

                    alertController.addAction(addAction)
                    alertController.addAction(cancelAction)

                self.present(alertController, animated: true, completion: nil)
                
//                accountToSend = Globals.user.accounts[indexPath.row]
//                self.performSegue(withIdentifier: "toAccountStatistics", sender: self)
            }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAccountStatistics") {
            let vc = segue.destination as! AccountStatisticsViewController
            vc.userAccount = accountToSend
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        Globals.user.accountSnapshots.removeAll()
    }

    
    func addYoutubeAccount(name: String, index: Int){
        let apiKey = "AIzaSyBwUa_x6V8IcDLR4n1PS_vwMTUPUJk7c6E"
        //Check for snapshot collection

        let docRef = db.collection("snapshots").document("youtube_\(name)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //snapshot collection already exists so check for last snapshot
                print("EXISTS SDIOFNSDOFNSDF")
                let lastSnapshot = document.get("last") as! Int
                let currentSnapshot = self.getUnixTime()
                let elapsed = currentSnapshot - lastSnapshot
                //time from last snapshot is less than 1 minute away
                if(elapsed < 60){
                    
                    let snapRef = docRef.collection("snapshots").document("\(lastSnapshot)")
                    
                    snapRef.getDocument { (snap, error) in
                        if let snap = snap, snap.exists {
                            if let subscribers = (snap.get("subscribers") as? String) {
                                Globals.user.accounts[index].followers = subscribers
                            }
                            if let views = (snap.get("views") as? String) {
                                Globals.user.accounts[index].following = views
                            }
                            if let videos = (snap.get("videos") as? String) {
                                Globals.user.accounts[index].posts = videos
                            }
                            Globals.user.accounts[index].accountName = name
//                            Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: name, posts: "\(posts)", followers: "\(followers)", following: "\(likes)"))
                            self.tableView.reloadData()
                        }
                    }
                }
                //time is more than 1 min from last snapshot
                else{
                    if let url = URL(string: "https://youtube.googleapis.com/youtube/v3/channels?part=id&forUsername=\(name)&key=\(apiKey)") {
                                //API Call
                                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                                let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                                let task = session.dataTask(with: request) { (data, response, error) in
                                    //This will run when the network request returns
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else if let data = data {
                                        do {
                                            let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                            //Grabs data array from API if it is valid, otherwise displays an error
                                            guard let APIdata = dataDictionary["items"] as? [[String:Any]] else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid username)")
                                                return
                                            }
                                            guard let id = APIdata[0]["id"] as? String else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid id)")
                                                return
                                            }
                                            
                                            
                                            if let url = URL(string: "https://youtube.googleapis.com/youtube/v3/channels?part=statistics&id=\(id)&key=\(apiKey)") {
                                                        //API Call
                                                        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                                                        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                                                        let task = session.dataTask(with: request) { (data, response, error) in
                                                            //This will run when the network request returns
                                                            if let error = error {
                                                                print(error.localizedDescription)
                                                            } else if let data = data {
                                                                do {
                                                                    let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                                                    //Grabs data array from API if it is valid, otherwise displays an error
                                                                    guard let APIdata = dataDictionary["items"] as? [[String:Any]] else {
                                                                        if let errorResults = dataDictionary["error"] as? String {
                                                                            print("Error: \(errorResults)")
                                                                        }
                                                                        print("API data not found(invalid id result)")
                                                                        return
                                                                    }
                                                                    guard let APIStats = APIdata[0]["statistics"] as? [String:Any] else {
                                                                        if let errorResults = dataDictionary["error"] as? String {
                                                                            print("Error: \(errorResults)")
                                                                        }
                                                                        print("API data not found(invalid stats)")
                                                                        return
                                                                    }
                                                                    guard let subscriberCount = APIStats["subscriberCount"] as? String else {
                                                                        if let errorResults = dataDictionary["error"] as? String {
                                                                            print("Error: \(errorResults)")
                                                                        }
                                                                        print("API data not found(invalid id)")
                                                                        return
                                                                    }
                                                                    guard let viewCount = APIStats["viewCount"] as? String else {
                                                                        if let errorResults = dataDictionary["error"] as? String {
                                                                            print("Error: \(errorResults)")
                                                                        }
                                                                        print("API data not found(invalid id)")
                                                                        return
                                                                    }
                                                                    guard let videoCount = APIStats["videoCount"] as? String else {
                                                                        if let errorResults = dataDictionary["error"] as? String {
                                                                            print("Error: \(errorResults)")
                                                                        }
                                                                        print("API data not found(invalid id)")
                                                                        return
                                                                    }
                                                                    print(subscriberCount)
                                                                    print(viewCount)
                                                                    print(videoCount)
                                                                    
                                                                    //self.accounts.remove(at: index)
                                                                    Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "youtubeicon"), socialMediaName: "Youtube", accountName: name, posts: videoCount, followers: subscriberCount, following: viewCount))
                                                                    let timestamp = self.getUnixTime()
                                                                    
                                                                    guard let userId = Auth.auth().currentUser?.uid else { return }
                                                                    self.db.collection("users").document(userId).updateData(["youtube" : name])
                                                                    
                                                                    self.db.collection("snapshots").document("youtube_\(name)").collection("snapshots").document("\(timestamp)").setData([
                                                                        "subscribers": subscriberCount,
                                                                        "videos": videoCount,
                                                                        "views": viewCount
                                                                    ])
                                                                    self.db.collection("snapshots").document("youtube_\(name)").updateData(["last" : timestamp,
                                                                                                                                       "subscribers": subscriberCount,
                                                                                                                                       "videos": videoCount,
                                                                                                                                       "views": viewCount])
                                                                    self.tableView.reloadData()
                                                                }
                                                                    
                                                                catch (_) {
                                                                    //City name is not valid/has no data from API
                                                                    print("Error: API Data Blocked")
                                                                }
                                                            }
                                                        }
                                                        task.resume()
                                                    }
                                                    else{
                                                        //Case where URL contains invalid items such as emojis
                                                        print("Invalid ID")
                                                    }
                                            
                                            
                                            
                                            
                                        }
                                            
                                        catch (_) {
                                            //City name is not valid/has no data from API
                                            print("Error: API Data Blocked")
                                        }
                                    }
                                }
                                task.resume()
                            }
                            else{
                                //Case where URL contains invalid items such as emojis
                                print("Invalid URL")
                            }
                }
            } else {
                //snapshot does not exist, so create one
                if let url = URL(string: "https://youtube.googleapis.com/youtube/v3/channels?part=id&forUsername=\(name)&key=\(apiKey)") {
                            //API Call
                            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                            let task = session.dataTask(with: request) { (data, response, error) in
                                //This will run when the network request returns
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let data = data {
                                    do {
                                        let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                        //Grabs data array from API if it is valid, otherwise displays an error
                                        guard let APIdata = dataDictionary["items"] as? [[String:Any]] else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid username)")
                                            return
                                        }
                                        guard let id = APIdata[0]["id"] as? String else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid id)")
                                            return
                                        }
                                        
                                        
                                        if let url = URL(string: "https://youtube.googleapis.com/youtube/v3/channels?part=statistics&id=\(id)&key=\(apiKey)") {
                                                    //API Call
                                                    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                                                    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                                                    let task = session.dataTask(with: request) { (data, response, error) in
                                                        //This will run when the network request returns
                                                        if let error = error {
                                                            print(error.localizedDescription)
                                                        } else if let data = data {
                                                            do {
                                                                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                                                //Grabs data array from API if it is valid, otherwise displays an error
                                                                guard let APIdata = dataDictionary["items"] as? [[String:Any]] else {
                                                                    if let errorResults = dataDictionary["error"] as? String {
                                                                        print("Error: \(errorResults)")
                                                                    }
                                                                    print("API data not found(invalid id result)")
                                                                    return
                                                                }
                                                                guard let APIStats = APIdata[0]["statistics"] as? [String:Any] else {
                                                                    if let errorResults = dataDictionary["error"] as? String {
                                                                        print("Error: \(errorResults)")
                                                                    }
                                                                    print("API data not found(invalid stats)")
                                                                    return
                                                                }
                                                                guard let subscriberCount = APIStats["subscriberCount"] as? String else {
                                                                    if let errorResults = dataDictionary["error"] as? String {
                                                                        print("Error: \(errorResults)")
                                                                    }
                                                                    print("API data not found(invalid id)")
                                                                    return
                                                                }
                                                                guard let viewCount = APIStats["viewCount"] as? String else {
                                                                    if let errorResults = dataDictionary["error"] as? String {
                                                                        print("Error: \(errorResults)")
                                                                    }
                                                                    print("API data not found(invalid id)")
                                                                    return
                                                                }
                                                                guard let videoCount = APIStats["videoCount"] as? String else {
                                                                    if let errorResults = dataDictionary["error"] as? String {
                                                                        print("Error: \(errorResults)")
                                                                    }
                                                                    print("API data not found(invalid id)")
                                                                    return
                                                                }
                                                                print(subscriberCount)
                                                                print(viewCount)
                                                                print(videoCount)
                                                                
                                                                //self.accounts.remove(at: index)
                                                                Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "youtubeicon"), socialMediaName: "Youtube", accountName: name, posts: videoCount, followers: subscriberCount, following: viewCount))
                                                                let timestamp = self.getUnixTime()
                                                                
                                                                guard let userId = Auth.auth().currentUser?.uid else { return }
                                                                self.db.collection("users").document(userId).updateData(["youtube" : name])
                                                                
                                                                self.db.collection("snapshots").document("youtube_\(name)").collection("snapshots").document("\(timestamp)").setData([
                                                                    "subscribers": subscriberCount,
                                                                    "videos": videoCount,
                                                                    "views": viewCount
                                                                ])
                                                                self.db.collection("snapshots").document("youtube_\(name)").setData(["last" : timestamp,
                                                                                                                                      "subscribers": subscriberCount,
                                                                                                                                      "videos": videoCount,
                                                                                                                                      "views": viewCount])
                                                                self.tableView.reloadData()
                                                            }
                                                                
                                                            catch (_) {
                                                                //City name is not valid/has no data from API
                                                                print("Error: API Data Blocked")
                                                            }
                                                        }
                                                    }
                                                    task.resume()
                                                }
                                                else{
                                                    //Case where URL contains invalid items such as emojis
                                                    print("Invalid ID")
                                                }
                                        
                                        
                                        
                                        
                                    }
                                        
                                    catch (_) {
                                        //City name is not valid/has no data from API
                                        print("Error: API Data Blocked")
                                    }
                                }
                            }
                            task.resume()
                        }
                        else{
                            //Case where URL contains invalid items such as emojis
                            print("Invalid URL")
                        }
                //Firestore.firestore().collection("snapshots").document("\(platform)_\(name)").collection("snapshots").document("").set
            }
        }
    }
    
    
    
    
    
    
    
    
    func addTikTokAccount(name: String, index: Int){
        
        //Check for snapshot collection

        let docRef = db.collection("snapshots").document("tiktok_\(name)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //snapshot collection already exists so check for last snapshot
                print("EXISTS SDIOFNSDOFNSDF")
                let lastSnapshot = document.get("last") as! Int
                let currentSnapshot = self.getUnixTime()
                let elapsed = currentSnapshot - lastSnapshot
                //time from last snapshot is less than 1 minute away
                if(elapsed < 60){
                    
                    let snapRef = docRef.collection("snapshots").document("\(lastSnapshot)")
                    
                    snapRef.getDocument { (snap, error) in
                        if let snap = snap, snap.exists {
                            if let followers = (snap.get("followers") as? String) {
                                Globals.user.accounts[index].followers = followers
                            }
                            if let likes = (snap.get("likes") as? String) {
                                Globals.user.accounts[index].following = likes
                            }
                            if let posts = (snap.get("posts") as? String) {
                                Globals.user.accounts[index].posts = posts
                            }
                            Globals.user.accounts[index].accountName = name
//                            Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: name, posts: "\(posts)", followers: "\(followers)", following: "\(likes)"))
                            self.tableView.reloadData()
                        }
                    }
                }
                //time is more than 1 min from last snapshot
                else{
                    if let url = URL(string: "https://tiktok.com/@\(name)") {
                                //API Call
                                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                                let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                                let task = session.dataTask(with: request) { (data, response, error) in
                                    //This will run when the network request returns
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else if let data = data {
                                        do {
                                            //Grabs data array from API if it is valid, otherwise displays an error popup
                                            
                                            
                                            guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
                                                print("can't cast html data to string")
                                                return
                                            }
                                           
                                            //print(htmlString)
                                            let leftSideFollowers = """
                                            {"followerCount":
                                            """
                                            let rightSideFollowers = """
                                            ,"followingCount":
                                            """
                                            let leftSidePosts = """
                                            "videoCount":
                                            """
                                            let rightSidePosts = """
                                            ,"diggCount"
                                            """
                                            let leftSideLikes = """
                                            heart":
                                            """
                                            let rightSideLikes = """
                                            ,"heartCount"
                                            """
                                            
                                            guard let leftRangeFollower = htmlString.range(of: leftSideFollowers) else {
                                                print("cannot find follower left range")
                                                return
                                            }
                                            guard let rightRangeFollower = htmlString.range(of: rightSideFollowers) else {
                                                print("cannot find follower right range")
                                                return
                                            }
                                            guard let leftRangePosts = htmlString.range(of: leftSidePosts) else {
                                                print("cannot find following left range")
                                                return
                                            }
                                            guard let rightRangePosts = htmlString.range(of: rightSidePosts) else {
                                                print("cannot find following right range")
                                                return
                                            }
                                            guard let leftRangeLikes = htmlString.range(of: leftSideLikes) else {
                                                print("cannot find likes left range")
                                                return
                                            }
                                            guard let rightRangeLikes = htmlString.range(of: rightSideLikes) else {
                                                print("cannot find likes right range")
                                                return
                                            }
                                            let followerResult = htmlString[leftRangeFollower.upperBound..<rightRangeFollower.lowerBound]
                                            let postsResult = htmlString[leftRangePosts.upperBound..<rightRangePosts.lowerBound]
                                            let likesResult = htmlString[leftRangeLikes.upperBound..<rightRangeLikes.lowerBound]
                                            
                                            //print("Followers: \(followerResult) Following: \(followingResult) Likes: \(likesResult)")
                                            //self.accounts.remove(at: index)
                                            Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: name, posts: "\(postsResult)", followers: "\(followerResult)", following: "\(likesResult)"))
                                            guard let userId = Auth.auth().currentUser?.uid else { return }
                                            let timestamp = self.getUnixTime()
                                            self.db.collection("users").document(userId).updateData(["tiktok" : name])
                                            self.db.collection("snapshots").document("tiktok_\(name)").collection("snapshots").document("\(timestamp)").setData([
                                                "followers": followerResult,
                                                "posts": postsResult,
                                                "likes": likesResult
                                            ])
                                            self.db.collection("snapshots").document("tiktok_\(name)").updateData(["last" : timestamp,
                                                                                                              "followers": followerResult,
                                                                                                              "posts": postsResult,
                                                                                                              "likes": likesResult])
                                            self.tableView.reloadData()
                                        }
                                            
                                        catch (_) {
                                            //City name is not valid/has no data from API
                                            print("Error: API Data Blocked")
                                        }
                                    }
                                }
                                task.resume()
                            }
                            else{
                                //Case where URL contains invalid items such as emojis
                                print("Invalid URL")
                            }
                }
            } else {
                //snapshot does not exist, so create one
                if let url = URL(string: "https://tiktok.com/@\(name)") {
                            //API Call
                            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                            let task = session.dataTask(with: request) { (data, response, error) in
                                //This will run when the network request returns
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let data = data {
                                    do {
                                        //Grabs data array from API if it is valid, otherwise displays an error popup
                                        
                                        
                                        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
                                            print("can't cast html data to string")
                                            return
                                        }
                                       
                                        //print(htmlString)
                                        let leftSideFollowers = """
                                        {"followerCount":
                                        """
                                        let rightSideFollowers = """
                                        ,"followingCount":
                                        """
                                        let leftSidePosts = """
                                        "videoCount":
                                        """
                                        let rightSidePosts = """
                                        ,"diggCount"
                                        """
                                        let leftSideLikes = """
                                        heart":
                                        """
                                        let rightSideLikes = """
                                        ,"heartCount"
                                        """
                                        
                                        guard let leftRangeFollower = htmlString.range(of: leftSideFollowers) else {
                                            print("cannot find follower left range")
                                            return
                                        }
                                        guard let rightRangeFollower = htmlString.range(of: rightSideFollowers) else {
                                            print("cannot find follower right range")
                                            return
                                        }
                                        guard let leftRangePosts = htmlString.range(of: leftSidePosts) else {
                                            print("cannot find following left range")
                                            return
                                        }
                                        guard let rightRangePosts = htmlString.range(of: rightSidePosts) else {
                                            print("cannot find following right range")
                                            return
                                        }
                                        guard let leftRangeLikes = htmlString.range(of: leftSideLikes) else {
                                            print("cannot find likes left range")
                                            return
                                        }
                                        guard let rightRangeLikes = htmlString.range(of: rightSideLikes) else {
                                            print("cannot find likes right range")
                                            return
                                        }
                                        let followerResult = htmlString[leftRangeFollower.upperBound..<rightRangeFollower.lowerBound]
                                        let postsResult = htmlString[leftRangePosts.upperBound..<rightRangePosts.lowerBound]
                                        let likesResult = htmlString[leftRangeLikes.upperBound..<rightRangeLikes.lowerBound]
                                        
                                        //print("Followers: \(followerResult) Following: \(followingResult) Likes: \(likesResult)")
                                        //self.accounts.remove(at: index)
                                        Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: name, posts: "\(postsResult)", followers: "\(followerResult)", following: "\(likesResult)"))
                                        guard let userId = Auth.auth().currentUser?.uid else { return }
                                        let timestamp = self.getUnixTime()
                                        self.db.collection("users").document(userId).updateData(["tiktok" : name])
                                        self.db.collection("snapshots").document("tiktok_\(name)").collection("snapshots").document("\(timestamp)").setData([
                                            "followers": followerResult,
                                            "posts": postsResult,
                                            "likes": likesResult
                                        ])

                                        self.db.collection("users").document(userId).updateData(["tiktok" : name])
                                        self.db.collection("snapshots").document("tiktok_\(name)").setData(["last" : timestamp,
                                                                                                       "followers": followerResult,
                                                                                                       "posts": postsResult,
                                                                                                       "likes": likesResult])
                                        self.tableView.reloadData()
                                    }
                                        
                                    catch (_) {
                                        //City name is not valid/has no data from API
                                        print("Error: API Data Blocked")
                                    }
                                }
                            }
                            task.resume()
                        }
                        else{
                            //Case where URL contains invalid items such as emojis
                            print("Invalid URL")
                        }
                //Firestore.firestore().collection("snapshots").document("\(platform)_\(name)").collection("snapshots").document("").set
            }
        }

    }
    
    func addTwitterAccount(name:String, index: Int){
        if let url = URL(string: "https://twitter.com/\(name)") {
            
        }
        
    }
    
    func addTwitchAccount(name:String, index: Int){
        if let url = URL(string: "https://twitch.com/\(name)") {
                    //API Call
                    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                    let task = session.dataTask(with: request) { (data, response, error) in
                        //This will run when the network request returns
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let data = data {
                            do {
                                //Grabs data array from API if it is valid, otherwise displays an error popup
                                
                                
                                guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
                                    print("can't cast html data to string")
                                    return
                                }
                               
                                print(htmlString)
                                let leftSideFollowers = """
                                {"followerCount":
                                """
                                let rightSideFollowers = """
                                ,"followingCount":
                                """
                                let leftSideFollowing = """
                                followingCount":
                                """
                                let rightSideFollowing = """
                                ,"heart"
                                """
                                let leftSideLikes = """
                                heart":
                                """
                                let rightSideLikes = """
                                ,"heartCount"
                                """
                                
                                guard let leftRangeFollower = htmlString.range(of: leftSideFollowers) else {
                                    print("cannot find follower left range")
                                    return
                                }
                                guard let rightRangeFollower = htmlString.range(of: rightSideFollowers) else {
                                    print("cannot find follower right range")
                                    return
                                }
                                guard let leftRangeFollowing = htmlString.range(of: leftSideFollowing) else {
                                    print("cannot find following left range")
                                    return
                                }
                                guard let rightRangeFollowing = htmlString.range(of: rightSideFollowing) else {
                                    print("cannot find following right range")
                                    return
                                }
                                guard let leftRangeLikes = htmlString.range(of: leftSideLikes) else {
                                    print("cannot find likes left range")
                                    return
                                }
                                guard let rightRangeLikes = htmlString.range(of: rightSideLikes) else {
                                    print("cannot find likes right range")
                                    return
                                }
                                let followerResult = htmlString[leftRangeFollower.upperBound..<rightRangeFollower.lowerBound]
                                let followingResult = htmlString[leftRangeFollowing.upperBound..<rightRangeFollowing.lowerBound]
                                let likesResult = htmlString[leftRangeLikes.upperBound..<rightRangeLikes.lowerBound]
                                
                                //print("Followers: \(followerResult) Following: \(followingResult) Likes: \(likesResult)")
                                Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: name, posts: "\(followingResult)", followers: "\(followerResult)", following: "\(likesResult)"))
                                self.tableView.reloadData()
                            }
                                
                            catch (_) {
                                //City name is not valid/has no data from API
                                print("Error: API Data Blocked")
                            }
                        }
                    }
                    task.resume()
                }
                else{
                    //Case where URL contains invalid items such as emojis
                    print("Invalid URL")
                }
    }
    
    func addInstagramAccount(name: String, index: Int){
        
        //Check for snapshot collection

        let docRef = db.collection("snapshots").document("instagram_\(name)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //snapshot collection already exists so check for last snapshot
                print("EXISTS SDIOFNSDOFNSDF")
                let lastSnapshot = document.get("last") as! Int
                let currentSnapshot = self.getUnixTime()
                let elapsed = currentSnapshot - lastSnapshot
                //time from last snapshot is less than 10 minute away
                if(elapsed < 600){
                    
                    let snapRef = docRef.collection("snapshots").document("\(lastSnapshot)")
                    
                    snapRef.getDocument { (snap, error) in
                        if let snap = snap, snap.exists {
                            if let followers = (snap.get("followers") as? String) {
                                Globals.user.accounts[index].followers = followers
                            }
                            if let following = (snap.get("following") as? String) {
                                Globals.user.accounts[index].following = following
                            }
                            if let posts = (snap.get("posts") as? String) {
                                Globals.user.accounts[index].posts = posts
                            }
                            Globals.user.accounts[index].accountName = name
//                            Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: name, posts: "\(posts)", followers: "\(followers)", following: "\(likes)"))
                            self.tableView.reloadData()
                        }
                    }
                }
                //time is more than 10 min from last snapshot
                else{
                    if let url = URL(string: "https://www.instagram.com/\(name)/?__a=1") {
                                //API Call
                                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                                let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                                let task = session.dataTask(with: request) { (data, response, error) in
                                    //This will run when the network request returns
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else if let data = data {
                                        do {
                                            let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                            //Grabs data array from API if it is valid, otherwise displays an error popup
                                            guard let APIdata = dataDictionary["graphql"] as? [String:Any] else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid username)")
                                                return
                                            }
                                            guard let userData = APIdata["user"] as? [String:Any] else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid user data)")
                                                return
                                            }
                                            guard let followerData = userData["edge_followed_by"] as? [String:Any] else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid follower data)")
                                                return
                                            }
                                            guard let followerCount = followerData["count"] as? Int else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid follower count)")
                                                return
                                            }
                                            guard let followingData = userData["edge_follow"] as? [String:Any] else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid following data)")
                                                return
                                            }
                                            guard let followingCount = followingData["count"] as? Int else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid following count)")
                                                return
                                            }
                                            guard let postData = userData["edge_owner_to_timeline_media"] as? [String:Any] else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid post data)")
                                                return
                                            }
                                            guard let postCount = postData["count"] as? Int else {
                                                if let errorResults = dataDictionary["error"] as? String {
                                                    print("Error: \(errorResults)")
                                                }
                                                print("API data not found(invalid post count)")
                                                return
                                            }
                                            //print("follower count is \(followerCount)")
                                            //print("following count is \(followingCount)")
                                            //print("post count is \(postCount)")
                                            //self.instagramData = APIdata as! [[String:Any]]
                                            //update followers, posts, following here
                                           
                                            //self.accounts.remove(at: index)
                                            Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "instagramicon"), socialMediaName: "Instagram", accountName: name, posts: "\(postCount)", followers: "\(followerCount)", following: "\(followingCount)"))
                                            let timestamp = self.getUnixTime()

                                            guard let userId = Auth.auth().currentUser?.uid else { return }
                                            self.db.collection("users").document(userId).updateData(["instagram" : name])
                                            
                                            self.db.collection("snapshots").document("instagram_\(name)").collection("snapshots").document("\(timestamp)").setData([
                                                "followers": followerCount,
                                                "posts": postCount,
                                                "following": followingCount
                                            ])
                                            self.db.collection("snapshots").document("instagram_\(name)").updateData(["last" : timestamp,
                                                                                                                 "followers": followerCount,
                                                                                                                 "posts": postCount,
                                                                                                                 "following": followingCount])
                                            self.tableView.reloadData()
                                        }
                                            
                                        catch (_) {
                                            //City name is not valid/has no data from API
                                            print("Error: API Data Blocked")
                                        }
                                    }
                                }
                                task.resume()
                            }
                            else{
                                //Case where URL contains invalid items such as emojis
                                print("Invalid URL")
                            }
                }
            } else {
                //snapshot does not exist, so create one
                if let url = URL(string: "https://www.instagram.com/\(name)/?__a=1") {
                            //API Call
                            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                            let task = session.dataTask(with: request) { (data, response, error) in
                                //This will run when the network request returns
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let data = data {
                                    do {
                                        let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                        //Grabs data array from API if it is valid, otherwise displays an error popup
                                        guard let APIdata = dataDictionary["graphql"] as? [String:Any] else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid username)")
                                            return
                                        }
                                        guard let userData = APIdata["user"] as? [String:Any] else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid user data)")
                                            return
                                        }
                                        guard let followerData = userData["edge_followed_by"] as? [String:Any] else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid follower data)")
                                            return
                                        }
                                        guard let followerCount = followerData["count"] as? Int else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid follower count)")
                                            return
                                        }
                                        guard let followingData = userData["edge_follow"] as? [String:Any] else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid following data)")
                                            return
                                        }
                                        guard let followingCount = followingData["count"] as? Int else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid following count)")
                                            return
                                        }
                                        guard let postData = userData["edge_owner_to_timeline_media"] as? [String:Any] else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid post data)")
                                            return
                                        }
                                        guard let postCount = postData["count"] as? Int else {
                                            if let errorResults = dataDictionary["error"] as? String {
                                                print("Error: \(errorResults)")
                                            }
                                            print("API data not found(invalid post count)")
                                            return
                                        }
                                        //print("follower count is \(followerCount)")
                                        //print("following count is \(followingCount)")
                                        //print("post count is \(postCount)")
                                        //self.instagramData = APIdata as! [[String:Any]]
                                        //update followers, posts, following here
                                       
                                        //self.accounts.remove(at: index)
                                        Globals.user.accounts[index] = (Account(socialMediaIcon: #imageLiteral(resourceName: "instagramicon"), socialMediaName: "Instagram", accountName: name, posts: "\(postCount)", followers: "\(followerCount)", following: "\(followingCount)"))
                                        let timestamp = self.getUnixTime()
                                        
                                        guard let userId = Auth.auth().currentUser?.uid else { return }
                                        self.db.collection("users").document(userId).updateData(["instagram" : name])
                                        
                                        self.db.collection("snapshots").document("instagram_\(name)").collection("snapshots").document("\(timestamp)").setData([
                                            "followers": followerCount,
                                            "posts": postCount,
                                            "following": followingCount
                                        ])
                                        self.db.collection("snapshots").document("instagram_\(name)").setData(["last" : timestamp,
                                                                                                          "followers": followerCount,
                                                                                                          "posts": postCount,
                                                                                                          "following": followingCount])
                                        self.tableView.reloadData()
                                    }
                                        
                                    catch (_) {
                                        //City name is not valid/has no data from API
                                        print("Error: API Data Blocked")
                                    }
                                }
                            }
                            task.resume()
                        }
                        else{
                            //Case where URL contains invalid items such as emojis
                            print("Invalid URL")
                        }
                //Firestore.firestore().collection("snapshots").document("\(platform)_\(name)").collection("snapshots").document("").set
            }
        }

    }

    func formatNumbers(value: String) -> String{
        if(value.count <= 4){
            return value
        }
        else if(value.count == 5){
            let needed = value.prefix(3)
            return "\(needed.prefix(2)).\(needed.suffix(1))K"
        }
        else if(value.count == 6){
            let needed = value.prefix(4)
            return "\(needed.prefix(3)).\(needed.suffix(1))K"
        }
        else if(value.count == 7){
            let needed = value.prefix(2)
            return "\(needed.prefix(1)).\(needed.suffix(1))M"
        }
        else if(value.count == 8){
            let needed = value.prefix(3)
            return "\(needed.prefix(2)).\(needed.suffix(1))M"
        }
        else if(value.count == 9){
            let needed = value.prefix(4)
            return "\(needed.prefix(3)).\(needed.suffix(1))M"
        }
        else if(value.count == 10){
            let needed = value.prefix(2)
            return "\(needed.prefix(1)).\(needed.suffix(1))B"
        }
        else if(value.count == 11){
            let needed = value.prefix(3)
            return "\(needed.prefix(2)).\(needed.suffix(1))B"
        }
        else if(value.count == 12){
            let needed = value.prefix(4)
            return "\(needed.prefix(3)).\(needed.suffix(1))B"
        }
        else if(value.count == 13){
            let needed = value.prefix(2)
            return "\(needed.prefix(1)).\(needed.suffix(1))T"
        }
        else if(value.count == 14){
            let needed = value.prefix(3)
            return "\(needed.prefix(2)).\(needed.suffix(1))T"
        }
        else if(value.count == 15){
            let needed = value.prefix(4)
            return "\(needed.prefix(3)).\(needed.suffix(1))T"
        }
        else{
            return value
        }
    }
    
    func configurationTextField(textField: UITextField!){

            if let tField = textField {
                //Save reference to the UITextField
                self.alertTextView = tField
                alertTextView.placeholder = "ex: @pewdiepie"
            }
        
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

extension UIViewController {
    func getUnixTime() -> Int {
        let timeInterval = Int(NSDate().timeIntervalSince1970)
        
        return timeInterval
    }
}

//func addInstagramAccount(name:String, index: Int){
//    if let url = URL(string: "https://instagram.com/\(name)") {
//                //API Call
//                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
//                let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
//                let task = session.dataTask(with: request) { (data, response, error) in
//                    //This will run when the network request returns
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else if let data = data {
//                        do {
//                            //Grabs data array from API if it is valid, otherwise displays an error popup
//
//
//                            guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
//                                print("can't cast html data to string")
//                                return
//                            }
//
//                            print(htmlString)
//                            let leftSideFollowers = """
//                            <meta content="
//                            """
//                            let rightSideFollowers = " Followers, "
//                            let leftSideFollowing = """
//                            Followers,
//                            """
//                            let rightSideFollowing = """
//                            Following,
//                            """
//                            let leftSidePosts = """
//                             Following,
//                            """
//                            let rightSidePosts = """
//                            Posts - See
//                            """
//
//                            guard let leftRangeFollower = htmlString.range(of: leftSideFollowers) else {
//                                print("cannot find follower left range")
//                                return
//                            }
//                            guard let rightRangeFollower = htmlString.range(of: rightSideFollowers) else {
//                                print("cannot find follower right range")
//                                return
//                            }
//                            guard let leftRangeFollowing = htmlString.range(of: leftSideFollowing) else {
//                                print("cannot find following left range")
//                                return
//                            }
//                            guard let rightRangeFollowing = htmlString.range(of: rightSideFollowing) else {
//                                print("cannot find following right range")
//                                return
//                            }
//                            guard let leftRangePosts = htmlString.range(of: leftSidePosts) else {
//                                print("cannot find posts left range")
//                                return
//                            }
//                            guard let rightRangePosts = htmlString.range(of: rightSidePosts) else {
//                                print("cannot find posts right range")
//                                return
//                            }
//                            let followerResult = htmlString[leftRangeFollower.upperBound..<rightRangeFollower.lowerBound]
//                            let followingResult = htmlString[leftRangeFollowing.upperBound..<rightRangeFollowing.lowerBound]
//                            let postResult = htmlString[leftRangePosts.upperBound..<rightRangePosts.lowerBound]
//
//                            print("Followers:\(followerResult)Following:\(followingResult)Posts:\(postResult)")
//                            self.accounts.remove(at: index)
//                            self.accounts.insert(Account(socialMediaIcon: #imageLiteral(resourceName: "instagramicon"), socialMediaName: "Instagram", accountName: name, posts: "\(postResult)", followers: "\(followerResult)", following: "\(followingResult)"), at: 0)
//                            self.tableView.reloadData()
//                        }
//
//                        catch (_) {
//                            //City name is not valid/has no data from API
//                            print("Error: API Data Blocked")
//                        }
//                    }
//                }
//                task.resume()
//            }
//            else{
//                //Case where URL contains invalid items such as emojis
//                print("Invalid URL")
//            }
//}
