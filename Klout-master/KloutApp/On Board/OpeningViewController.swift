//
//  OpeningViewController.swift
//  KloutApp
//
//  Created by Kyle Burns on 2/23/21.
//

import UIKit
import GoogleSignIn
import Firebase

class OpeningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(GIDSignIn.sharedInstance()?.currentUser != nil){
            self.performSegue(withIdentifier: "toTabBar", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "toSignIn", sender: self)
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
