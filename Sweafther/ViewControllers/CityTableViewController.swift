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

class CityTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var cities = [City]()
    var locatedCity: City? = nil
    
    var CurrentlyData = [String : Any]()
    var degrePref = String()
    
    let locationManager = CLLocationManager()
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined {

                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            print("Please turn on location service")
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        
        degrePref = "°C"
        navigationItem.leftBarButtonItem = editButtonItem
        
        timer = Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(self.refreshEvery2Minutes), userInfo: nil, repeats: true)

        // Load any saved cities, otherwise load sample data.
        if let savedCities = loadCities() {
            cities += savedCities
        }
        else {
            loadSampleCities()
        }

        reloadCityData(completion:{})
    }
    
    //MARK: Private Methods
    
    private func loadSampleCities() {
        
        let city1 = City(name: "Paris", temperature: "27", summary: "", icon: "wind")
        let city2 = City(name: "New York", temperature: "33", summary: "", icon: "wind")
        let city3 = City(name: "London", temperature: "25", summary: "", icon: "wind")
        
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count + (locatedCity != nil ? 1 : 0)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell City", for: indexPath)
        
        if indexPath.row == 0, let locatedCity = locatedCity {
            cell.textLabel?.text = locatedCity.name
            cell.detailTextLabel?.text = "\((locatedCity.temperature as NSString).integerValue) \(degrePref)"
            cell.imageView?.image = UIImage.scaleImageToSize(img: UIImage(named: locatedCity.icon) ?? UIImage(named: "rain")!, size: CGSize(width: 40.0, height: 40.0))
        } else {
            let index = indexPath.row - (locatedCity != nil ? 1 : 0)
            let cityObject = cities[index]
            
            cell.textLabel?.text = cityObject.name
            cell.detailTextLabel?.text = "\((cityObject.temperature as NSString).integerValue) \(degrePref)"
            cell.imageView?.image = UIImage.scaleImageToSize(img: UIImage(named: cityObject.icon) ?? UIImage(named: "rain")!, size: CGSize(width: 40.0, height: 40.0))
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0, locatedCity != nil {
            return false
        }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "WeatherTableViewController") as? WeatherTableViewController {
            if indexPath.row == 0, let locatedCity = locatedCity {
                viewController.city = locatedCity
            } else {
                let index = indexPath.row - (locatedCity != nil ? 1 : 0)
                let selectedCity = cities[index]
                viewController.city = selectedCity
            }
            viewController.degre = degrePref
            navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
    
    func updateWeatherForLocation(location:String, completion: @escaping () -> ()) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    //Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                    Weather.getCurrently(typeTemp: self.degrePref, withLocation: location.coordinate, completion: { (results:[String : Any]?) in
                        
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
    func SwitchDegreType() {
       if degrePref == "°F" {
            for city in self.cities {
                let temp = Double(city.temperature)
                let newTemp = (temp! * 1.8) + 32
                //print("en °F \(newTemp) pour la ville de \(city.name)")
                city.temperature = String(newTemp)
            }
            if locatedCity != nil {
                let temp = Double(locatedCity!.temperature)
                let newTemp = (temp! * 1.8) + 32
                //print("en °F \(newTemp) pour la ville de \(locatedCity!.name)")
                locatedCity!.temperature = String(newTemp)
            }
        } else {
            for city in self.cities {
                let temp = Double(city.temperature)
                let newTemp = (temp! - 32) / 1.8
                //print("en °F \(newTemp) pour la ville de \(city.name)")
                city.temperature = String(newTemp)
            }
            if locatedCity != nil {
                let temp = Double(locatedCity!.temperature)
                let newTemp = (temp! - 32) / 1.8
                //print("en °C \(newTemp) pour la ville de \(locatedCity!.name)")
                locatedCity!.temperature = String(newTemp)
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

        SwitchDegreType()
        //reloadCityData()
        tableView.reloadData()
    }
    
    
    func reloadCityData(completion: @escaping () -> ()) {
        var i = 0
        if locatedCity != nil {
            updateWeatherForLocation(location: locatedCity?.name ?? "Paris", completion: {
                self.locatedCity?.temperature = "\(Int(self.CurrentlyData["temperature"] as? Double ?? -1.0))"
                self.locatedCity?.summary = "\(self.CurrentlyData["summary"] as? String ?? "void")"
                self.locatedCity?.icon = "\(self.CurrentlyData["icon"] as? String ?? "wind")"
            })
        }
        for city in cities{
            updateWeatherForLocation(location: city.name, completion: {
                city.temperature = "\(Int(self.CurrentlyData["temperature"] as? Double ?? -1.0))"
                city.summary = "\(self.CurrentlyData["summary"] as? String ?? "void")"
                city.icon = "\(self.CurrentlyData["icon"] as? String ?? "wind")"
                if self.cities.count - 1 == i
                {
                    self.tableView.reloadData()
                    DispatchQueue.main.async {
                        completion()
                    }
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
    
    // MARK: - Refresh
    
    @IBAction func refreshCityData(_ sender: UIRefreshControl) {
        reloadCityData(completion: {
            print("refresh")
            
            sender.endRefreshing()
        })
    }
    
    @objc func refreshEvery2Minutes(){
        reloadCityData(completion: {
            print("refresh 2 mintutes")
        })
        
    }
}

// MARK: - CLLocationManagerDelegate

extension CityTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print(location)
        
        fetchCityAndCountry(from: location) { city, country, error  in
            guard let city = city, let country = country, error == nil else { return }
            print("actuellemnt à " + city + ", " + country)
            self.updateWeatherForLocation(location: city, completion: {
                //print("le forcast de city table\(self.CurrentlyData)")

                let temperature = "\(Int(self.CurrentlyData["temperature"] as? Double ?? -1.0))"
                let summary = "\(self.CurrentlyData["summary"] as? String ?? "void")"
                let icon = "\(self.CurrentlyData["icon"] as? String ?? "wind")"
                self.locatedCity = City(name: "\(city) (you're here)", temperature: temperature, summary: summary, icon: icon)
                
                self.tableView.reloadData()
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("unable to acess your current location, error :\(error)")
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
                let summary = "\(self.CurrentlyData["summary"] as? String ?? "void")"
                let icon = "\(self.CurrentlyData["icon"] as? String ?? "wind")"
                let newCity = City(name: newCity, temperature: temperature, summary: summary, icon: icon)
                
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
