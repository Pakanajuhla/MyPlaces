//
//  MapViewController.swift
//  My Place
//
//  Created by Владислав on 08.08.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress (_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mapView = mapView {
            mapView.delegate = self
        }
        addressLabel.text = ""
        setupMapView()
    }
    
    @IBAction func centerViewInUserLocation() {
        if let mapView = mapView {
            mapManager.showUserLocation(mapView: mapView)
        }
    }
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func cancelVC() {
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
       
     private func setupMapView() {
            goButton.isHidden = true
         if let mapView = mapView {
             mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
                 mapManager.locationManager.delegate = self
             }
         if incomeSegueIdentifier == "showPlace" {
                 mapManager.setupPlaceMark(place: place, mapView: mapView)
                 mapPinImage.isHidden = true
                 addressLabel.isHidden = true
                 doneButton.isHidden = true
                 goButton.isHidden = false
             } else {
                 print("mapView is nil")
             }
           }
        }
    }
        
        extension MapViewController: MKMapViewDelegate {
            
            func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                guard !(annotation is MKUserLocation) else { return nil }
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
                
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                    annotationView?.canShowCallout = true
                }
                
                if let imageData = place.imageData {
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                    imageView.layer.cornerRadius = 10
                    imageView.clipsToBounds = true
                    imageView.image = UIImage(data: imageData)
                    annotationView?.rightCalloutAccessoryView = imageView
                }
                return annotationView
            }
            
            func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
                
                let center = mapManager.getCenterLocation(for: mapView)
                let geocoder = CLGeocoder()
                
                if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.showUserLocation(mapView: self.mapView)
                    }   
                }
                
                geocoder.cancelGeocode() // отмена отложеного действия
                geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
                    
                    guard let placemarks = placemarks else { return }
                    let placemark = placemarks.first
                    let streetName = placemark?.thoroughfare
                    let buildNumber = placemark?.subThoroughfare
                    
                    DispatchQueue.main.async {     // обновляем label, и передаем значения в label
                        if streetName != nil && buildNumber != nil {
                            self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                        } else if streetName != nil {
                            self.addressLabel.text = "\(streetName!)"
                        } else {
                            self.addressLabel.text = ""
                        }
                    }
                }
            }
            
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
                renderer.strokeColor = .blue
                return renderer
            }
        }
        
        extension MapViewController: CLLocationManagerDelegate {
            func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                mapManager.checklocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
            }
        }
  
