//
//  GoogleAuthenticator.swift
//  LoginApp
//
//  Created by Nikita Kalyuzhnyy on 28.07.2020.
//  Copyright © 2020 Nikita Kalyuzhnyy. All rights reserved.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

class GoogleAuthentication: NSObject, GIDSignInDelegate {

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
}
