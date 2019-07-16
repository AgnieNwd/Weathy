//
//  WeatherTableViewController.swift
//  Sweafther
//
//  Created by Agnieszka Niewiadomski on 08/07/2019.
//  Copyright © 2019 niewia_a. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherTableViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    //MARK: Properties
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var city: String = ""
    var forecastData = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("citttttttttty issssss \(city)")
        closeButton.setTitle("Close", for: .normal)
        titleLabel.text = city
        updateWeatherForLocation(location: city)
    }
    
    //MARK: Actions

//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        if let locationString = searchBar.text, !locationString.isEmpty {
//            updateWeatherForLocation(location: locationString)
//        }
//    }
    
    func updateWeatherForLocation(location:String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        
                        // check if weather is here
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
                        
                    })
                }
            }
        }
    }

    @IBAction func actionClose() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table Weather view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return forecastData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        return dateFormatter.string(from: date!)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let weatherObject = forecastData[indexPath.section]
        
        cell.textLabel?.text = weatherObject.summary
        cell.detailTextLabel?.text = "\(Int(weatherObject.temperature)) °C"
        cell.imageView?.image = UIImage(named: weatherObject.icon)
        
        return cell
    }
}
