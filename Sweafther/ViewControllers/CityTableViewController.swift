//
//  CityTableViewController.swift
//  Sweafther
//
//  Created by Agnieszka Niewiadomski on 09/07/2019.
//  Copyright © 2019 niewia_a. All rights reserved.
//

import UIKit
import os.log
import CoreLocation

class CityTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //MARK: Properties
    
    var cities = [City]()
    var CurrentlyData = [String : Any]()
    var degrePref = String()
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        degrePref = "°C"
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved cities, otherwise load sample data.
        if let savedCities = loadCities() {
            cities += savedCities
        }
        else {
            loadSampleCities()
        }
        //locationManager(manager, didUpdateLocations: [CLLocation(latitude: 49.2667, longitude: 2.4833)])
        reloadDataTemp()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: Private Methods
    
    private func loadSampleCities() {
        
        let city1 = City(name: "Paris", temperature: "27", icon: "clear-day")
        let city2 = City(name: "New York", temperature: "33", icon: "clear-day")
        let city3 = City(name: "London", temperature: "25", icon: "clear-day")
        
        cities += [city1, city2, city3]
    }
    
    private func saveCities() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(cities, toFile: City.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Cities successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Cities to save cities...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadCities() -> [City]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: City.ArchiveURL.path) as? [City]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell City", for: indexPath)
        
        // Configure the cell...
        let cityObject = cities[indexPath.row]

        cell.textLabel?.text = cityObject.name
        cell.detailTextLabel?.text = "\((cityObject.temperature as NSString).integerValue) \(degrePref)"
        cell.imageView?.image = UIImage.scaleImageToSize(img: UIImage(named: cityObject.icon)!, size: CGSize(width: 40.0, height: 40.0))

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            cities.remove(at: indexPath.row)
            saveCities()
            tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("selected city \(cities[indexPath.row].name)")
        
        let selectedCityName = cities[indexPath.row].name
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "WeatherTableViewController") as? WeatherTableViewController {
            viewController.city = selectedCityName
            navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
    
    func updateWeatherForLocation(location:String, completion: @escaping () -> ()) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    //Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                    Weather.getCurrentl(typeTemp: self.degrePref, withLocation: location.coordinate, completion: { (results:[String : Any]?) in
                        
                        // check if weather is here
                        if let weatherData = results {
                            self.CurrentlyData = weatherData
                            
                            DispatchQueue.main.async {
                                completion()
                            }
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SearchCityViewController {
            viewController.delegate = self
        }
    }
    
    // MARK: - func geoLocalisation
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print(location)
        //let location = CLLocation(latitude: 49.2667, longitude: 2.4833)
        fetchCityAndCountry(from: location) { city, country, error  in
            guard let city = city, let country = country, error == nil else { return }
            print("actuellemnt à " + city + ", " + country)
            let myCity = City(name: "\(city) (vous êtes ici)", temperature: "27", icon: "clear-day")
            self.cities += [myCity]
            self.tableView.reloadData()

        }
        
    }
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    // MARK: - Action

    @IBAction func typeOfTemp(_ sender: UIButton) {
        if degrePref == "°F" {
            sender.setTitle("°F", for: [])
            degrePref = "°C"
        }
        else {
            sender.setTitle("°C", for: [])
            degrePref = "°F"
        }
        reloadDataTemp()
    }
    
    
    func reloadDataTemp() {
        var i = 0
        for city in cities{
            updateWeatherForLocation(location: city.name, completion: {
                city.temperature = "\(Int(self.CurrentlyData["temperature"] as? Double ?? -1.0))"
                city.icon = "\(self.CurrentlyData["icon"] as? String ?? "nothing")"
                if self.cities.count - 1 == i
                {
                    self.tableView.reloadData()
                }
                i = i + 1
            })
        }
    }
    func checkCities(newCity: String)->Bool {
        for city in cities {
            if city.name == newCity {
                return true
            }
        }
        return false
    }
}

extension CityTableViewController: SearchCityTableViewDelegate {
    func didSelectedNewCity(_ newCity: String) {
//        print(newCity)
        let ifCtity = checkCities(newCity: newCity)
        if !ifCtity {
            updateWeatherForLocation(location: newCity, completion: {
                //print("le forcast de city table\(self.CurrentlyData)")
                let temperature = "\(Int(self.CurrentlyData["temperature"] as? Double ?? -1.0))"
                let icon = "\(self.CurrentlyData["icon"] as? String ?? "nothing")"
                let newCity = City(name: newCity, temperature: temperature, icon: icon)
                
                self.cities.append(newCity)
                self.tableView.reloadData()
                //self.navigationController?.popViewController(animated: true)
                
                self.saveCities()
            })
        }
        self.navigationController?.popViewController(animated: true)
    }
}


extension UIImage {
    
    class func scaleImageToSize(img: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
}
