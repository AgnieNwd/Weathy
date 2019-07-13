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
    var CurrentlyData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        // Load any saved cities, otherwise load sample data.
        if let savedCities = loadCities() {
            cities += savedCities
        }
        else {
            loadSampleCities()
        }
    }
    
    
    //MARK: Private Methods
    
    private func loadSampleCities() {
        
        let city1 = City(name: "Paris", temperature: "27")
        let city2 = City(name: "New York", temperature: "33")
        let city3 = City(name: "London", temperature: "25")
        
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
        cell.detailTextLabel?.text = "\(cityObject.temperature) °C"
        
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
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    func updateWeatherForLocation(location:String, completion: @escaping () -> ()) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    //Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                    Weather.getCurrentl(withLocation: location.coordinate, completion: { (results:[String : Any]?) in
                        
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

}

extension CityTableViewController: SearchCityTableViewDelegate {
    func didSelectedNewCity(_ newCity: String) {
//        print(newCity)
        updateWeatherForLocation(location: newCity, completion: {
            print("le forcast de city table\(self.CurrentlyData)")
            let temperature = "\(self.CurrentlyData["temperature"] as? Double ?? -1.0)"
            let newCity = City(name: newCity, temperature: temperature)
            
            self.cities.append(newCity)
            self.tableView.reloadData()
            self.navigationController?.popViewController(animated: true)
            
            self.saveCities()
        })
    }
}
