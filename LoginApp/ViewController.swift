//
//  ViewController.swift
//  LoginApp
//
//  Created by Nikita Kalyuzhnyy on 21.07.2020.
//  Copyright © 2020 Nikita Kalyuzhnyy. All rights reserved.
//

import GoogleSignIn
import FBSDKLoginKit
import UIKit
import FirebaseAuth

class ViewController: UIViewController, LoginButtonDelegate {

    @IBOutlet var signInButtonGoogle: GIDSignInButton!
 
    @IBAction func signInButtonFacebook(_ sender: Any) {
        
        if let token = AccessToken.current, !token.isExpired {
            
            let token = token.tokenString
            
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                     parameters: ["fields": "email, name"],
                                                     tokenString: token,
                                                     version: nil,
                                                     httpMethod: .get)
            
            request.start(completionHandler: { connection, result, error in
                print("\(result ?? "")")
            })

        } else {
            let loginButton = FBLoginButton()
            loginButton.delegate = self
            loginButton.permissions = ["public_profile", "email"]
            
            loginButton.isHidden = true
            view.addSubview(loginButton)
            
            loginButton.sendActions(for: UIControl.Event.touchUpInside)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance()?.presentingViewController = self
        
    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                 parameters: ["fields": "email, name"],
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        request.start(completionHandler: { connection, result, error in
            print("\(result ?? "")")
        }
        )
        
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FirebaseAuth.FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FirebaseAuth.Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil  {
                print("Something went wrong with FB", error ?? "")
                return
            }
            
            print("FB successful", user ?? "")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }

}

