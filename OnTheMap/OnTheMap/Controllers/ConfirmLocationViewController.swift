//
//  ConfirmLocationViewController.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/25/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ConfirmLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    var studentInformation: StudentInformation?
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self as? MKMapViewDelegate
        
        
        if let studentLocation = studentInformation {
            let location = Location(
                objectId: "",
                uniqueKey: nil,
                firstName: studentLocation.firstName,
                lastName: studentLocation.lastName,
                mapString: studentLocation.mapString,
                mediaURL: studentLocation.mediaURL,
                latitude: studentLocation.latitude,
                longitude: studentLocation.longitude,
                createdAt: "",
                updatedAt: ""
            )
            showLocations(location: location)
        }
        
        activityIndicator.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func finish(_ sender: Any) {
        if let studentLocation = studentInformation {
            showNetworkOperation(true)
            if studentLocation.locationID == nil {
                // POST
                Client.shared().postStudentLocation(info: studentLocation, completionHandler: { (success, error) in
                    self.showNetworkOperation(false)
                    self.handleSyncLocationResponse(error: error)
                })
            } else {
                // PUT
                Client.shared().updateStudentLocation(info: studentLocation, completionHandler: { (success, error) in
                    self.showNetworkOperation(false)
                    self.handleSyncLocationResponse(error: error)
                })
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showLocations(location: Location) {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = extractCoordinate(location: location) {
            let annotation = MKPointAnnotation()
            annotation.title = location.locationLabel
            annotation.subtitle = location.mediaURL ?? ""
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    private func extractCoordinate(location: Location) -> CLLocationCoordinate2D? {
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }
    
    private func handleSyncLocationResponse(error: NSError?) {
        if let error = error {
            showErrorAlert(title: "Error", message: error.localizedDescription)
        } else {
            showInfo(withTitle: "Success", withMessage: "Student Location updated!", action: {
                self.goBackToMapController()
            })
        }
    }
    
    private func showNetworkOperation(_ show: Bool) {
        performUIUpdatesOnMain {
            self.buttonSubmit.isEnabled = !show
            self.mapView.alpha = show ? 0.5 : 1
            self.activityIndicator.isHidden = false
            show ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
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
    

    


