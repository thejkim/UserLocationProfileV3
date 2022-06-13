//
//  LoginVC.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/12/22.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func loginBtnTouched(_ sender: UIButton) {
        // SAVE INTO CORE DATA
        if let usernameInput = usernameTF.text {
            if !CoreDataManager.sharedManager.userExists(by: usernameInput) {
                CoreDataManager.sharedManager.registerUser(username: usernameInput)
            }
            // navigate...
        } else {
            let alert = UIAlertController(title: "Register Failed", message: "Please enter username.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
