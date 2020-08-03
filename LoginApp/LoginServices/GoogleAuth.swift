//
//  GoogleAuth.swift
//  LoginApp
//
//  Created by Nikita Kalyuzhnyy on 03.08.2020.
//  Copyright © 2020 Nikita Kalyuzhnyy. All rights reserved.
//

import Foundation
import GoogleSignIn
import FirebaseAuth


class GoogleAuth: NSObject, GIDSignInDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        GIDSignIn.sharedInstance()?.delegate = self
        
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
    
    
    
}
