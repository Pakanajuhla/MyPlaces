//
//  MapManager.swift
//  My Place
//
//  Created by Владислав on 21.08.2023.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 10_000.00
    private var directionsArray: [MKDirections] = []
    
    func setupPlaceMark(place: Place, mapView: MKMapView) {  // настройка метки
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            guard let coordinate = placemarks?.first?.location?.coordinate else { return }
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            annotation.coordinate = coordinate
            self.placeCoordinate = coordinate
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {  
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checklocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled",
                          massage: "To enable it go: Settings -> Privacy -> Location services and turn on")
            }
        }
    }
    
    func checklocationAuthorization(mapView: MKMapView, segueIdentifier: String ) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:       // различные статусы
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()  // запрос при использовании авторизации
        case .restricted:
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled",
                          massage: "To enable it go: Settings -> Privacy -> Location services and turn on")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print ("New case")
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            self.showAlert(title: "Error", massage: "Current location is not found")
            return
        }
         
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", massage: "Destination location is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        directions.calculate { (response, error) in // возвращает расчитаный маршрут с данными, или ошибку
            if error != nil {
                print("Error")
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", massage: "Directions is not available")
                return
            }
            
            for route in response.routes {   // маршруты
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                print("Расстояние до места \(distance) км.")
                print("Время в пути составит \(timeInterval) сек.")
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request() // опеределение точки начала, и конца маршрута
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
        
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
    }
    
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude )
    }
    
    private func showAlert (title: String, massage: String) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}


