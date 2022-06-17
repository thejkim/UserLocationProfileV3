//
//  LoadUrlVC.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/15/22.
//

import UIKit
import WebKit

class LoadUrlVC: UIViewController {
    
    var targetUrlStr: String?
    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let targetUrlStr = targetUrlStr else { return }
        guard let url = URL(string: targetUrlStr) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            let request = URLRequest(url: url)
            
            webview.load(request)
        }
    }
    


}
