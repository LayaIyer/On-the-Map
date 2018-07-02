//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/23/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadStarted), name: .reloadStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCompleted), name: .reloadCompleted, object: nil)
        // Do any additional setup after loading the view.
        loadUserInfo()
        loadStudentsInformation()
        activityIndicator.isHidden = true
        showStudentsInformation(StudentsLocation.shared.studentsInformation)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    @IBAction func reload(_ sender: Any) {
        loadStudentsInformation()
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


    @objc func reloadStarted() {
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
            self.mapView.alpha = 0.5
        }
    }
    
    @objc func reloadCompleted() {
        performUIUpdatesOnMain {
            self.activityIndicator.stopAnimating()
            self.mapView.alpha = 1
            self.showStudentsInformation(StudentsLocation.shared.studentsInformation)
        }
    }
    
    func showStudentsInformation(_ studentsInformation: [StudentInformation]) {
        mapView.removeAnnotations(mapView.annotations)
        for info in studentsInformation where info.latitude != 0 && info.longitude != 0 {
            let annotation = MKPointAnnotation()
            annotation.title = info.labelName
            annotation.subtitle = info.mediaURL
            annotation.coordinate = CLLocationCoordinate2DMake(info.latitude, info.longitude)
            _ = annotation
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        
        view.canShowCallout = true
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            if let string = view.annotation?.subtitle! {
                openWithSafari(string)
            }
        }
    }
    
    private func loadUserInfo() {
        _ = Client.shared().studentInfo(completionHandler: { (studentInfo, error) in
            if let error = error {
                self.showErrorAlert(title: "Error", message: error.localizedDescription)
                return
            }
            Client.shared().userName = studentInfo?.user.name ?? ""
        })
    }
    
    @IBAction func overrideCurrentPin(){
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
            }
            if let studentsInformation = studentsInformation {
                StudentsLocation.shared.studentsInformation = studentsInformation
            }
        }
        NotificationCenter.default.post(name: .reloadCompleted, object: nil)
    }
    
}
    



