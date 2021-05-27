//
//  LogInViewController.swift
//  KloutApp
//
//  Created by Kyle Burns on 2/23/21.
//

import UIKit
import GoogleSignIn
import Firebase

class LogInViewController: UIViewController, GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.viewControllers = [self]
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        if(GIDSignIn.sharedInstance()?.currentUser != nil){
            //signed in
            self.performSegue(withIdentifier: "toTabBar", sender: self)
        }
        else{
            GIDSignIn.sharedInstance()?.signIn()
            
            
            
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //print("user email: \(user.profile.email ?? "No Email")")
        if let error = error {
            print("Error with google sign in: \(error.localizedDescription)")
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authDataResult, error) in
            if let error = error {
                print("Error with google sign in credential: \(error.localizedDescription)")
                return
            } else {
                guard let userId = Auth.auth().currentUser?.uid else { return }
                guard let userEmail = Auth.auth().currentUser?.email else { return }
                //Firestore.firestore().collection("users").
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(userId)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        //user already exists
                        print("user exists")
                    } else {
                        Firestore.firestore().collection("users").document(userId).setData(["email" : userEmail])
                    }
                }
                self.performSegue(withIdentifier: "toTabBar", sender: self)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
