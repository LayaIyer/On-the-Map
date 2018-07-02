//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/18/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController, LocationSelectionDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dataProvider: DataProvider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadStarted), name: .reloadStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCompleted), name: .reloadCompleted, object: nil)
        dataProvider.delegate = self as LocationSelectionDelegate
        tableView.dataSource = dataProvider
        tableView.delegate = dataProvider
        activityIndicator.isHidden = true
        
        loadStudentsInformation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadStarted () {
        performUIUpdatesOnMain {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    @objc func reloadCompleted() {
        performUIUpdatesOnMain {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        loadStudentsInformation()
    }
    
    @IBAction func createNewPin(_ sender: AnyObject){
        overrideCurrentPin()
    }
    
    @IBAction func logout(_ sender: Any) {
        Client.shared().logout { (success, error) in
            if success {
                self.dismiss(animated:true, completion: nil)
            } else {
                self.showErrorAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
    
    
    // MARK: - LocationSelectionDelegate
    
    func didSelectLocation(info: StudentInformation) {
        openWithSafari(info.mediaURL)
    }
    
    func overrideCurrentPin(){
        let alert = UIAlertController(title: "Overwrite Pin", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Overwrite", style: .destructive, handler: { void in
            self.goToCreatePinViewController()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func goToCreatePinViewController(){
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CreatePinViewController") as? CreatePinViewController{
            present(viewController, animated: true, completion: nil)
        }
    }
    
    @objc private func loadStudentsInformation() {
        NotificationCenter.default.post(name: .reloadStarted, object: nil)
        Client.shared().studentsInformation { (studentsInformation, error) in
            if let error = error {
                self.showErrorAlert(title: "Error", message: error.localizedDescription)
                NotificationCenter.default.post(name: .reloadCompleted, object: nil)
                return
            }
            if let studentsInformation = studentsInformation {
                StudentsLocation.shared.studentsInformation = studentsInformation
            }
            NotificationCenter.default.post(name: .reloadCompleted, object: nil)
        }
    }
}
