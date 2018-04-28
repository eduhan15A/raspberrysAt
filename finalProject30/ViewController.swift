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
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate {
 var context: NSManagedObjectContext!
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var txbDate: UITextField!
    var ids = [String]()
    var longitudes = [String]()
    var latitudes = [String]()
    var elevations = [String]()
    var dates = [String]()
    var temperatures = [String]()
    var devices = [String]()
    var locationManager: CLLocationManager!
    var temperaturaSeleccionada:Temperatures!
    
    @IBAction func consultar(_ sender: UIButton) {
        self.view.endEditing(true)
       // print(txbDate.text!)
        var dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short

        
        guard var selectedDate = dateFormatter.date(from: txbDate.text!) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        guard var dateDown = dateFormatter.date(from: txbDate.text!) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        guard var dateUp = dateFormatter.date(from: txbDate.text!) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        //print(dateDown)
       // selectedDate = selectedDate.addingTimeInterval(60.0 * 60 * 7)
        dateDown = dateDown.addingTimeInterval( 60.0 * -30)
        dateUp = dateUp.addingTimeInterval(60.0 * 30)
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        print(dateFormatter.string(from:selectedDate))
        print(dateFormatter.string(from:dateDown))
        print(dateFormatter.string(from:dateUp))
        let url = URL(string: "http://www.itesi.xyz/webservices/damAPI/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "{\"action\" :\"GetTemperatureFromDate\",\"dateDown\":\""+dateFormatter.string(from:dateDown)+"\",\"dateUp\":\""+dateFormatter.string(from:dateUp)+"\"}";
        print(postString)
        
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
            print(responseString)
            self.printDots(response:responseString!)
            self.saveTemperatures()
        }
        task.resume()

        
    }
    
    func saveTemperatures(){
        if( ids.count>0){
            for i in 0 ... ids.count-1{
                print(devices[i])
                let newTemperature = Temperatures(context: context)
                newTemperature.idMedition = ids[i]
                newTemperature.length = longitudes[i]
                newTemperature.latitude = latitudes[i]
                newTemperature.elevation = elevations[i]
                newTemperature.datetime = dates[i]
                newTemperature.temperature = temperatures[i]
                newTemperature.device = devices[i]
                
                do{
                    try
                        context.save()
                    print("saved")
                } catch{ print("Error")}
            }
                
            }
        
        }
        
    @IBAction func backMateria (_ segue: UIStoryboardSegue){
        if segue.identifier == "backFromListTemperatures"{
            let controller = segue.source as! TemperaturesTableViewController
            temperaturaSeleccionada = controller.temperaturaSeleccionada
         //   materia.text = materiaSeleccionada.nombre
            print(temperaturaSeleccionada)
            
             map.removeAnnotations(map.annotations)
            let artwork = Artwork(title: temperaturaSeleccionada.device!,
                                  locationName: temperaturaSeleccionada.temperature!+"°C "+temperaturaSeleccionada.datetime!,
                                  discipline: "",
                                  coordinate: CLLocationCoordinate2D(latitude: Double(temperaturaSeleccionada.latitude!)!, longitude: Double(temperaturaSeleccionada.length!)!))
            map.addAnnotation(artwork)
        }
        
        
    }
    @IBAction override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "segueIdentifierMainToTemperatures"{
            let listarMateriasTableViewController = segue.destination as! TemperaturesTableViewController
            listarMateriasTableViewController.origen = "TabTemperatureViewController"
        }
        
    }
    
    
    
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
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        context = appDelegate.mOContext
        

        
       getCurrentTemperatures()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    @IBAction func getCurrentTemperatures(_ sender: UIButton) {
        getCurrentTemperatures()
    }
    func getCurrentTemperatures(){
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
        
    }
    @IBAction func textFieldEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(ViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        txbDate.text = dateFormatter.string(from:sender.date)
    }
 
    
    
    func printDots(response:String)-> Bool{
       
         ids = [String]()
        longitudes = [String]()
         latitudes = [String]()
         elevations = [String]()
         dates = [String]()
         temperatures = [String]()
         devices = [String]()
        //map.removeAnnotations(map.annotations)
       /* let annotationsToRemove = map.annotations.filter { $0 !== map.userLocation }
        map.removeAnnotations( annotationsToRemove )*/
        
        map.removeAnnotations(map.annotations)
        
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
        if( ids.count>0){
        for i in 0 ... ids.count-1{
            print(devices[i])
            print(temperatures[i])
            
            let artwork = Artwork(title: devices[i],
                                  locationName: temperatures[i]+"°C "+dates[i],
                                  discipline: "",
                                  coordinate: CLLocationCoordinate2D(latitude: Double(latitudes[i])!, longitude: Double(longitudes[i])!))
            map.addAnnotation(artwork)
            }
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


