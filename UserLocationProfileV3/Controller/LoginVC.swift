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
            JKAlert.showOK(title: Constants.AlertMessages.USER_REGISTER_FAIL_TITLE, message: Constants.AlertMessages.USER_REGISTER_FAIL_MESSAGE, on: self)
        }
    }

}
