//
//  DeepLinkViewController.swift
//  Test_IOS
//
//  Created by Kishoree Londhe on 23/02/25.
//

import Foundation
import UIKit

class DeepLinkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
        self.view.backgroundColor = .white
        
     
        let label = UILabel()
        label.text = "DeepLink Successful"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        
       
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
