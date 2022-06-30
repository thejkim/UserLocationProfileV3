//
//  JKAlert.swift
//  WSMInventory
//
//  Created by Jay Kang on 5/25/22.
//

import UIKit

class JKAlert {
    static func showOK(title: String, message: String, on target: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default)))
        target.present(alert, animated: true)
    }
    
    static func showAndOpenURL(title: String, message: String, open url: URL?, on target: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let openSettings = UIAlertAction(title: "Open Settings", style: .default, handler: {(action ) in
            if let url = url {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(cancel)
        alert.addAction(openSettings)
        target.present(alert, animated: true)
    }
    
    
}
