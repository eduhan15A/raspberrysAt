//
//  ViewController.swift
//  finalProject30
//
//  Created by Eduardo Lujan on 23/04/18.
//  Copyright © 2018 Eduardo Lujan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var ids = [String]()
    var longitudes = [String]()
    var latitudes = [String]()
    var elevations = [String]()
    var dates = [String]()
    var temperatures = [String]()
    var devices = [String]()
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.showsUserLocation = true
        map.isZoomEnabled = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        map.delegate = self
        
        let url = URL(string: "http://www.itesi.xyz/webservices/damAPI/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "{\"action\":\"GetTemperature\"}";
       request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            self.printDots(response:responseString!)
        }
        task.resume()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func printDots(response:String)-> Bool{
        print("responseString = \(response)")
        do {
            let data = response.data(using: .utf8)
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let blogs = json["Data"] as? [[String: Any]] {
                for blog in blogs {
                    if let name = blog["idMedition"] as? String {
                        ids.append(name)
                    }
                    if let name = blog["length"] as? String {
                        longitudes.append(name)
                    }
                    if let name = blog["latitude"] as? String {
                        latitudes.append(name)
                    }
                    if let name = blog["elevation"] as? String {
                        elevations.append(name)
                    }
                    if let name = blog["datetime"] as? String {
                        dates.append(name)
                    }
                    if let name = blog["temperature"] as? String {
                        temperatures.append(name)
                    }
                    if let name = blog["device"] as? String {
                        devices.append(name)
                    }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
        }
        
      //  print(devices)
       // print(temperatures)
        
        for i in 0 ... ids.count-1{
            print(devices[i])
            print(temperatures[i])
            
            let artwork = Artwork(title: devices[i],
                                  locationName: temperatures[i]+"°C "+dates[i],
                                  discipline: "",
                                  coordinate: CLLocationCoordinate2D(latitude: Double(latitudes[i])!, longitude: Double(longitudes[i])!))
            map.addAnnotation(artwork)
        }
        
        return true
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
        
        self.map.setRegion(region, animated: true)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Artwork else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}


