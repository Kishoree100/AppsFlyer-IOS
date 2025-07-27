//
//  SceneDelegate.swift
//  Test_IOS
//
//  Created by Kishoree Londhe on 07/02/25.
//

import UIKit
import AppsFlyerLib


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        
        if let userActivity = connectionOptions.userActivities.first {
                 AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
             }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

  

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        AppsFlyerLib.shared().start()
    }

   //Universal link
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                print("[DEBUG] Opened via Universal Link: \(userActivity.webpageURL?.absoluteString ?? "")")
            }

            AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        }

    // URI Scheme
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        AppsFlyerLib.shared().handleOpen(url, options: [:])
    }
    
    


}

