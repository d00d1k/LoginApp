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

class ViewController: UIViewController {
    
    var googleSignIn = GIDSignIn.sharedInstance()
    
    @IBOutlet weak var signInButtonGoogle: UIButton!
    @IBOutlet weak var signInFacebookButton: UIButton!
    
    @IBAction func googleLoginButtonAction(_ sender: UIButton) {
        self.googleLogin()
    }
    
    @IBAction func signInButtonFacebook(_ sender: UIButton ) {
        
        self.facebookLogin()
        
        let loginButton = FBLoginButton()

        loginButton.permissions = ["public_profile", "email"]
        loginButton.delegate = self
        loginButton.isHidden = true
        view.addSubview(loginButton)
        
        loginButton.sendActions(for: UIControl.Event.touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func googleLogin() {
        
        self.googleSignIn?.presentingViewController = self
        self.googleSignIn?.signIn()
    }
    
}

extension ViewController: LoginButtonDelegate {
    
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
    
    func facebookLogin() {
        
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
        }
    }
}
