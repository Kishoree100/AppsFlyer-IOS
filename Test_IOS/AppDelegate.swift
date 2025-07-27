//
//  AppDelegate.swift
//  Test_IOS
//
//  Created by Kishoree Londhe on 07/02/25.
//

import WebKit
import UIKit
import AppsFlyerLib
import UserNotifications
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppsFlyerLibDelegate, DeepLinkDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().appInviteOneLinkID = "OHAM"
        AppsFlyerLib.shared().appsFlyerDevKey = "CpYt7yYGtdMfBHMPqBohs7"
        AppsFlyerLib.shared().appleAppID = "1619950106"
        
        // Wait for App Tracking Transparency authorization
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        registerForPushNotifications(application: application)
        
        // Set AppsFlyer delegates
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        
        // Subscribe to UIApplication didBecomeActiveNotification
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        
        return true
    }
    
    func registerForPushNotifications(application: UIApplication) {
           let center = UNUserNotificationCenter.current()
           center.delegate = self

           center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
               if granted {
                   DispatchQueue.main.async {
                       application.registerForRemoteNotifications()
                   }
               } else {
                   print("Push Notifications permission denied")
               }
           }
       }
    
    func application(
           _ application: UIApplication,
           didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
       ) {
           let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
           print("Device Token: \(token)")

           // Send the APNs token to AppsFlyer for uninstall tracking
           AppsFlyerLib.shared().registerUninstall(deviceToken)
       }

       func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           print("Failed to register for push notifications: \(error.localizedDescription)")
       }
    
    
    @objc func didBecomeActiveNotification() {
        // Customer User ID
        let CUID = "user123"
        UserDefaults.standard.set(CUID, forKey: "CUID")

        
        let customUserId = UserDefaults.standard.string(forKey: "CUID")
          
          if let customUserId = customUserId, !customUserId.isEmpty {
             
              AppsFlyerLib.shared().customerUserID = customUserId
              
              // Start AppsFlyer SDK
              AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
                  if let error = error {
                      print("AppsFlyer start error: \(error)")
                      return
                  }
              })
          } else {
              print("No valid customerUserID found")
          }
        
        // Request tracking authorization on iOS 14 and above
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .denied:
                    print("Authorization Status is denied")
                case .notDetermined:
                    print("Authorization Status is not determined")
                case .restricted:
                    print("Authorization Status is restricted")
                case .authorized:
                    print("Authorization Status is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
            }
        }
    }
    
    // Handle Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }

    // Handle URI schemes
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }

    // UDL - didResolveDeepLink
    

    func didResolveDeepLink(_ result: DeepLinkResult) {
        var DL_Value: String?
        switch result.status {
        case .notFound:
            NSLog("[AFSDK] Deep link not found")
            return
        case .failure:
            print("Error %@", result.error!)
            return
        case .found:
            NSLog("[AFSDK] Deep link found")
        }
        
        guard let deepLinkObj: DeepLink = result.deepLink else {
            NSLog("[AFSDK] Could not extract deep link object")
            return
        }
        
        if let referrerId = deepLinkObj.clickEvent["deep_link_sub2"] as? String {
            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(referrerId)")
        } else {
            NSLog("[AFSDK] Could not extract referrerId")
        }
        
        let deepLinkStr = deepLinkObj.toString()
        NSLog("[AFSDK] DeepLink data is: \(deepLinkStr)")
        
        if deepLinkObj.isDeferred {
            NSLog("[AFSDK] This is a deferred deep link")
        } else {
            NSLog("[AFSDK] This is a direct deep link")
        }
        
        DL_Value = deepLinkObj.deeplinkValue
        
        // If deep_link_value doesn't exist, check onelink
        
        if DL_Value == nil || DL_Value == "" {
            if let DL1 = deepLinkObj.clickEvent["DeepLink"] as? String {
                DL_Value = DL1
            } else {
                print("[AFSDK] Could not extract deep_link_value from deep link object with unified deep linking")
                return
            }
        }
        if DL_Value == "Deeplink" { // Replace DL value as per link
               navigateToDeepLinkViewController()
           }
       }
    
    func navigateToDeepLinkViewController() {
        if let window = self.window {
            let deepLinkVC = DeepLinkViewController()
            let navigationController = UINavigationController(rootViewController: deepLinkVC)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }

    

    // Get conversion Data OCDS()
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("AppsFlyer Conversion Data: \(conversionInfo)")
        
        if let conversionData = conversionInfo as? [String: Any] {
            if let status = conversionData["af_status"] as? String {
                if status == "Non-organic" {
                    if let sourceID = conversionData["media_source"],
                       let campaign = conversionData["campaign"] {
                        NSLog("[AFSDK] This is a Non-Organic install. Media source: \(sourceID), Campaign: \(campaign)")
                    }
                } else {
                    NSLog("[AFSDK] This is an organic install.")
                }
                
                if let isFirstLaunch = conversionData["is_first_launch"] as? Bool, isFirstLaunch {
                    NSLog("[AFSDK] First Launch")
                    if !conversionData.keys.contains("deep_link_value") && conversionData.keys.contains("DeepLink") {
                        if let DDL = conversionData["DDL"] as? String {
                            NSLog("This is a deferred deep link opened using conversion data")
                           
                        }
                    }
                } else {
                    NSLog("[AFSDK] Not First Launch")
                }
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("AppsFlyer Conversion Data Failed: \(error.localizedDescription)")
    }

    // UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
}

