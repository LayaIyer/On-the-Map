//
//  CreatePinViewController.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/19/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

class CreatePinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var textFieldLink: UITextField!
    @IBOutlet weak var buttonFindLocation: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    var locationID: String? // based on this property, let's decide whether we're going to perform a POST or a PUT operation.
    lazy var geocoder = CLGeocoder()
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        activityIndicator.isHidden = true
        textFieldLink.delegate = self
        textFieldLocation.delegate = self
    }
    
    // MARK: Keyboard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if(textFieldLink.isFirstResponder){
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func findLocation(_ sender: Any) {
        
        let location = textFieldLocation.text!
        let link = textFieldLink.text!
        
        if location.isEmpty || link.isEmpty {
            showErrorAlert(title: "Error", message: "All fields are required")
            return
        }
        guard let url = URL(string: link), UIApplication.shared.canOpenURL(url) else {
            showErrorAlert(title: "Error", message: "Please provide a valid link")
            return
        }
        geocode(location: location)
    }
    
    // MARK: - Helpers
    
    private func geocode(location: String) {
        enableControllers(false)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        geocoder.geocodeAddressString(location) { (placemarkers, error) in
            
            self.enableControllers(true)
            self.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            
            if error != nil {
                self.showErrorAlert(title: "Error", message: "Geocoding has failed please provide a valid location.")
            } else {
                var location: CLLocation?
                
                if let placemarks = placemarkers, placemarks.count > 0 {
                    location = placemarks.first?.location
                }
                
                if let location = location {
                    self.syncStudentLocation(location.coordinate)
                } else {
                    self.showErrorAlert(title: "Error", message: "No Matching Location Found")
                }
            }
        }
    }
    
    private func syncStudentLocation(_ coordinate: CLLocationCoordinate2D) {
        enableControllers(true)
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ConfirmLocationViewController") as! ConfirmLocationViewController
        viewController.studentInformation = buildStudentInfo(coordinate)
        present(viewController, animated: true)
    }
    
    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInformation {
        let nameComponents = Client.shared().userName.components(separatedBy: " ")
        let firstName = nameComponents.first ?? ""
        let lastName = nameComponents.last ?? ""
        
        var studentInfo = [
            "uniqueKey": Client.shared().userKey,
            "firstName": firstName,
            "lastName": lastName,
            "mapString": textFieldLocation.text!,
            "mediaURL": textFieldLink.text!,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            ] as [String: AnyObject]
        
        if let locationID = locationID {
            studentInfo["objectId"] = locationID as AnyObject
        }
        return StudentInformation(studentInfo)
    }
    
    private func enableControllers(_ enable: Bool) {
        enableUI(views: textFieldLocation, textFieldLink, buttonFindLocation, enable: enable)
    }
    
    private func setUpNavBar(){
        //For title in navigation bar
        navigationItem.title = "Add Location"
        
        //For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = "CANCEL"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    @IBAction func cancel() {
        let alert = UIAlertController(title: "Cancel", message: "Would you like to cancel?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { void in self.goBackToMapController()}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func goBackToMapController(){
        dismiss(animated: true, completion: nil)
        }
    }
    

