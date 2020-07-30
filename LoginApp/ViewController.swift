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

class ViewController: UIViewController, LoginButtonDelegate, GIDSignInDelegate {
    
    @IBOutlet var signInButtonGoogle: UIButton!
  
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
    
    @objc func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error {
            print("Failed to log into Google: ", err)
            return
        }
        
        print("Successfully log in into Google!", user!)
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accsesToken = user.authentication.accessToken else { return }
        let credeintials = FirebaseAuth.GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accsesToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credeintials) { (user, error) in
            if let err = error {
                print("Failed to create a Firebase user Google account", err )
            }
            print("Success logged into Google")
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        signInButtonGoogle.addTarget(self, action: #selector(googleLogin(_:)) , for: UIControl.Event.touchUpInside)
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

