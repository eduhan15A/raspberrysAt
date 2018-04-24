//
//  ViewController.swift
//  finalProject30
//
//  Created by Eduardo Lujan on 23/04/18.
//  Copyright © 2018 Eduardo Lujan. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://free.currencyconverterapi.com/api/v5/countries")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        //let postString = "id=13&name=Jack"
       // request.httpBody = postString.data(using: .utf8)
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
        
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

