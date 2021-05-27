//
//  AccountStatisticsViewController.swift
//  KloutApp
//
//  Created by Kyle Burns on 3/2/21.
//

import UIKit
import XLPagerTabStrip
import GoogleSignIn
import Firebase

class AccountStatisticsViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var socialMediaIcon: UIImageView!
    
    var userAccount = Account(socialMediaIcon: #imageLiteral(resourceName: "tiktokicon"), socialMediaName: "TikTok", accountName: "", posts: "", followers: "", following: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialMediaIcon.image = userAccount.socialMediaIcon
        
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .blue
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = .red
        }
        
        let selectedBarBackgroundView = UIView()
        selectedBarBackgroundView.backgroundColor = .gray
        view.insertSubview(selectedBarBackgroundView, belowSubview: buttonBarView)
        selectedBarBackgroundView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        selectedBarBackgroundView.bottomAnchor.constraint(equalTo: buttonBarView.bottomAnchor, constant: 0).isActive = true
        selectedBarBackgroundView.leadingAnchor.constraint(equalTo: buttonBarView.leadingAnchor, constant: 0).isActive = true
        selectedBarBackgroundView.trailingAnchor.constraint(equalTo: buttonBarView.trailingAnchor, constant: 0).isActive = true
        selectedBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadPagerTabStripView()
        
    }
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postsView") as! PostsViewController
        child_1.userAccount = userAccount
        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "followersView") as! FollowersViewController
        child_2.userAccount = userAccount
        let child_3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "followingView") as! FollowingViewController
        child_3.userAccount = userAccount
        return [child_1, child_2, child_3]
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
