//
//  WeatherTableViewController.swift
//  Sweafther
//
//  Created by Agnieszka Niewiadomski on 08/07/2019.
//  Copyright © 2019 niewia_a. All rights reserved.
//

import UIKit
import CoreLocation

struct hourlyData {
    let temperature: String
    let icon: String
}

class WeatherTableViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    //MARK: Properties
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var degre: String = ""
    var city: City!
    var forecastData = [Weather]()
    var hourlyForecastData = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.setTitle("Close", for: .normal)
        titleLabel.text = city.name
        summaryLabel.text = city.summary
        iconImage.image = UIImage(named: city.icon)
        tempLabel.text = "\((city.temperature as NSString).integerValue) \(degre)"

        updateWeatherForLocation(location: city.name)
    }
    
    //MARK: Actions
    
    func updateWeatherForLocation(location:String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                    
                    Weather.getHourlyData(typeTemp: "°C", withLocation: location.coordinate, completion: { (results:[[String:Any]]?) in
                        if let weatherHourlyData = results {
                            self.hourlyForecastData = weatherHourlyData
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
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
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        
        return dateFormatter.string(from: date!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let weatherObject = forecastData[indexPath.section]
        let temp = SwitchDegreType(obj: weatherObject)
        cell.textLabel?.text = weatherObject.summary
        cell.detailTextLabel?.text = "\(Int(temp)) \(degre)"
        cell.imageView?.image = UIImage.scaleImageToSize(img: UIImage(named: weatherObject.icon)!, size: CGSize(width: 35.0, height: 35.0))
        
        return cell
    }
    
    func SwitchDegreType(obj: Weather)->Double {
        if degre == "°F" {
                let temp = Double(obj.temperature)
                let newTemp = (temp * 1.8) + 32
                //print("en °F \(newTemp) pour la ville de \(city.name)")
                return newTemp
        } else {
              return obj.temperature
        }
    }
}

extension WeatherTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyForecastData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Hourly Cell", for: indexPath) as! WheatherCollectionViewCell

        let weatherObject = hourlyForecastData[indexPath.row]

        let date = NSDate(timeIntervalSince1970: weatherObject["time"] as! TimeInterval)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"

        cell.hourlyLabel.text = "\(dateFormatter.string(from: date as Date))H"
        cell.hourlyIconImage.image = UIImage(named: "\(weatherObject["icon"]!)")
        cell.temperatureLabel.text = "\(Int(weatherObject["temperature"]! as! Double))°"

        
        return cell
    }
    
    
}
