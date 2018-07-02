//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/17/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self as? UITextFieldDelegate
        password.delegate = self as? UITextFieldDelegate
        activityIndicator.isHidden = true
    }

    
    

    @IBAction func loginPressed(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        enableControllers(false)
        
        guard let emailtext = email.text, !emailtext.isEmpty else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            enableControllers(true)
            showErrorAlert(title: "Field required", message: "Please fill in your password.")
            return
        }
        guard  let password = password.text, !password.isEmpty else {
            activityIndicator.stopAnimating()
            enableControllers(true)
            showErrorAlert(title: "Field required", message: "Please fill in your password.")
            return
        }
        
        authenticateUser(email: emailtext, password: password)
        
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        openWithSafari("https://auth.udacity.com/sign-up")
        }
    
    private func authenticateUser(email: String, password: String) {
        
        Client.shared().authenticateWith(userEmail: email, andPassword: password) { (success, errorMessage) in
            if success {
                self.performUIUpdatesOnMain {
                    self.email.text = ""
                    self.password.text = ""
                }
                
                self.performSegue(withIdentifier: "showMap", sender: nil)
            } else {
                self.performUIUpdatesOnMain {
                    self.showErrorAlert(title: "Login falied", message: errorMessage!)
                }
            }
            self.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            self.enableControllers(true)
        }
    }
    
    private func enableControllers(_ enable: Bool) {
        enableUI(views: email, password, login, signUp, enable: enable)
    }
}




    
    
    
    
    
    
    
    
    

