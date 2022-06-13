//
//  JKAlert.swift
//  WSMInventory
//
//  Created by Jay Kang on 5/25/22.
//

import UIKit

class JKAlert {
    static func show(title: String, message: String, on target: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default)))
        target.present(alert, animated: true)
    }
}
