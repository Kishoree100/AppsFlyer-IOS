//
//  ViewController.swift
//  Test_IOS
//
//  Created by Kishoree Londhe on 07/02/25.
//
import UIKit
import AppsFlyerLib


class ViewController: UIViewController, DeepLinkDelegate {
    
    // UI elements
    let appsFlyerIdLabel = UILabel()
    let deepLinkStatusLabel = UILabel()
    let deepLinkLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let headingLabel = UILabel()
        headingLabel.text = "AppsFlyer Test App"
        headingLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headingLabel.textColor = .white
        headingLabel.textAlignment = .center
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headingLabel)
        
        // AppsFlyer ID Label
        appsFlyerIdLabel.text = "AppsFlyer UID: Loading..."
        appsFlyerIdLabel.font = UIFont.systemFont(ofSize: 16)
        appsFlyerIdLabel.textColor = .white
        appsFlyerIdLabel.textAlignment = .center
        appsFlyerIdLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appsFlyerIdLabel)
               

        // Deep Link Status Label
        deepLinkStatusLabel.text = "DeepLink Status: Waiting..."
        deepLinkStatusLabel.font = UIFont.boldSystemFont(ofSize: 16)
        deepLinkStatusLabel.textColor = .yellow
        deepLinkStatusLabel.textAlignment = .center
        deepLinkStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deepLinkStatusLabel)

        // Deep Link Label
        deepLinkLabel.text = "DeepLink Value: Waiting..."
        deepLinkLabel.font = UIFont.systemFont(ofSize: 16)
        deepLinkLabel.textColor = .white
        deepLinkLabel.textAlignment = .center
        deepLinkLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deepLinkLabel)
        
        
        let purchaseButton = UIButton(type: .system)
        purchaseButton.setTitle("Purchase Event", for: .normal)
        purchaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        purchaseButton.backgroundColor = UIColor.systemBlue
        purchaseButton.setTitleColor(.white, for: .normal)
        purchaseButton.layer.cornerRadius = 10
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        purchaseButton.addTarget(self, action: #selector(trackPurchaseEvent), for: .touchUpInside)
        view.addSubview(purchaseButton)
        
        let inviteButton = UIButton(type: .system)
        inviteButton.setTitle("User Invite", for: .normal)
        inviteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        inviteButton.backgroundColor = UIColor.systemGreen
        inviteButton.setTitleColor(.white, for: .normal)
        inviteButton.layer.cornerRadius = 10
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
        view.addSubview(inviteButton)

        NSLayoutConstraint.activate([
            headingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            appsFlyerIdLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appsFlyerIdLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 20),
            appsFlyerIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appsFlyerIdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            


            deepLinkStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deepLinkStatusLabel.topAnchor.constraint(equalTo: appsFlyerIdLabel.bottomAnchor, constant: 20),
            deepLinkStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deepLinkStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            deepLinkLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deepLinkLabel.topAnchor.constraint(equalTo: deepLinkStatusLabel.bottomAnchor, constant: 20),
            deepLinkLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deepLinkLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            purchaseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            purchaseButton.topAnchor.constraint(equalTo: deepLinkLabel.bottomAnchor, constant: 40),
            purchaseButton.widthAnchor.constraint(equalToConstant: 200),
            purchaseButton.heightAnchor.constraint(equalToConstant: 40),
           
                        inviteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        inviteButton.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 20),
                        inviteButton.widthAnchor.constraint(equalToConstant: 200),
                        inviteButton.heightAnchor.constraint(equalToConstant: 50)
                    
        ])

        // Display AppsFlyer ID
        displayAppsFlyerUID()

        // Set Deep Link Delegate
        AppsFlyerLib.shared().deepLinkDelegate = self
    }
    


    func displayAppsFlyerUID() {
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        appsFlyerIdLabel.text = "AppsFlyer UID: \(appsFlyerUID)"
        print("AppsFlyer UID: \(appsFlyerUID)")
    }

    @objc func trackPurchaseEvent() {
        let eventValues: [String: Any] = [
            AFEventParamRevenue: 10.50,
            AFEventParamCurrency: "USD",
            AFEventParamContentId: "123456",
            AFEventParamContentType: "Product"
        ]

        AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: eventValues)
        print("Purchase event logged")
        
        let alert = UIAlertController(title: "Event Tracked", message: "Purchase event has been logged successfully.", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
    }
    
    @objc func inviteTapped() {
        print("[DEBUG] Invite button tapped")

        AppsFlyerShareInviteHelper.generateInviteUrl(
            linkGenerator: { (generator: AppsFlyerLinkGenerator) -> AppsFlyerLinkGenerator in
                
                generator.addParameterValue("target_page", forKey: "deep_link_value")
                generator.addParameterValue("code123", forKey: "deep_link_sub1")
                generator.setCampaign("Test_campaign")
                generator.setChannel("User_invite")
                
             generator.addParameterValue("AppsFlyer", forKey: "af_og_title")
                generator.addParameterValue("This is for testing", forKey: "af_og_description")
               generator.addParameterValue("https://google.com",forKey: "af_og_image")
              // generator.brandDomain = "brand.domain.com"

                return generator
            },
            completionHandler: { (url: URL?) in
                if let inviteUrl = url {
                    print("[AFSDK] Generated Invite URL: \(inviteUrl.absoluteString)")
                    
                    
                    DispatchQueue.main.async {
                        let activityVC = UIActivityViewController(activityItems: [inviteUrl], applicationActivities: nil)
                        self.present(activityVC, animated: true, completion: nil)
                    }
                } else {
                    print("[AFSDK] Invite URL is nil")
                }
            }
        )
    }


    // MARK: - DeepLink Handling
    func didResolveDeepLink(_ result: DeepLinkResult) {
        print("[DEBUG] didResolveDeepLink triggered")

        var DL_Value: String?
        var deepLinkStatusText = "Unknown"

        switch result.status {
        case .notFound:
            deepLinkStatusText = "Not Found"
            print("[DEBUG] Deep link not found")
        case .failure:
            deepLinkStatusText = "Error"
            print("[DEBUG] Error %@", result.error!)
        case .found:
            deepLinkStatusText = "Found"
            print("[DEBUG] Deep link found")
        }

        DispatchQueue.main.async {
            self.deepLinkStatusLabel.text = "DeepLink Status: \(deepLinkStatusText)"
        }

        guard let deepLinkObj: DeepLink = result.deepLink else {
            print("[DEBUG] Could not extract deep link object")
            return
        }

        print("[DEBUG] DeepLink Object: \(deepLinkObj.toString())")

        if let referrerId = deepLinkObj.clickEvent["deep_link_sub2"] as? String {
            print("[DEBUG] Referrer ID: \(referrerId)")
        }

        DL_Value = deepLinkObj.deeplinkValue

        if DL_Value == nil || DL_Value == "" {
            if let DL1 = deepLinkObj.clickEvent["DeepLink"] as? String {
                DL_Value = DL1
            } else {
                print("[DEBUG] Could not extract deep_link_value")
                return
            }
        }

        print("[DEBUG] Extracted Deep Link Value: \(DL_Value ?? "NULL")")

        DispatchQueue.main.async {
            self.deepLinkLabel.text = "DeepLink Value: \(DL_Value ?? "N/A")"
        }
    }
}
