//
//  AppDelegate.swift
//  LoginApp
//
//  Created by Nikita Kalyuzhnyy on 21.07.2020.
//  Copyright © 2020 Nikita Kalyuzhnyy. All rights reserved.
//

import GoogleSignIn
import FirebaseCore
import Firebase
import UIKit
import FBSDKCoreKit
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = "975693140125-882hm9j6et1gddkjl16vmj8b51hcbl0u.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
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
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}



