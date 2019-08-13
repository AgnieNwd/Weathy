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
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var InfosWing: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var degre: String = ""
    var city: City!
    var forecastData = [Weather]()
    var hourlyForecastData = [[String:Any]]()

    var container: UIView = UIView()
    var loadingView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        lunchLoader()
        
        closeButton.setTitle("Close", for: .normal)
        titleLabel.text = city.name
        summaryLabel.text = city.summary
        iconImage.image = UIImage(named: city.icon)
        tempLabel.text = "\((city.temperature as NSString).integerValue) \(degre)"
        InfosWing.text = "Wind Speed : \((city.windSpeed as NSString).doubleValue) mph humidity : \(city.humidity) % pressure : \(city.pressure) hPa"
        updateWeatherForLocation(location: city.name, completion:{
            self.hideLoader()
        })
    }
    
    //MARK: Actions
    
    func updateWeatherForLocation(location:String, completion: @escaping () -> ()) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        if let weatherData = results {
                            self.forecastData = weatherData
                            self.tableViewHeightConstraint.constant = CGFloat(weatherData.count * 44) + CGFloat(weatherData.count * 28)
                            
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
                                completion()
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
    
    func lunchLoader() {
        print("loadeer")
        self.view.viewWithTag(1)?.isHidden = true

        activityIndicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        activityIndicator.center = self.view.center
        activityIndicator.backgroundColor = (UIColor (white: 0.3, alpha: 0.1))
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.layer.cornerRadius = 10

        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        self.view.viewWithTag(1)?.isHidden = false
        activityIndicator.stopAnimating()
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

        // Cells of table view (daily)
        let weatherObject = forecastData[indexPath.section]
        let temp = SwitchDegreType(obj: weatherObject.temperature)
        cell.textLabel?.text = weatherObject.summary
        cell.detailTextLabel?.text = "\(Int(temp)) \(degre)"
        cell.imageView?.image = UIImage.scaleImageToSize(img: UIImage(named: weatherObject.icon)!, size: CGSize(width: 35.0, height: 35.0))
        
        return cell
    }
    
    func SwitchDegreType(obj: Double)->Double {
        if degre == "°F" {
                let temp = Double(obj)
                let newTemp = (temp * 1.8) + 32
                return newTemp
        } else {
              return obj
        }
    }
}

extension WeatherTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyForecastData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Hourly Cell", for: indexPath) as! WheatherCollectionViewCell

        // First cell of collection view (hourly)
        if indexPath.row == 0 {
            cell.hourlyLabel.text = "Now"
            cell.hourlyIconImage.image = UIImage(named: city.icon)
            cell.temperatureLabel.text = "\((city.temperature as NSString).integerValue)°"
        }
        // Others cells from "now"
        else {
            let weatherObject = hourlyForecastData[indexPath.row]
            let temp = SwitchDegreType(obj: weatherObject["temperature"] as! Double)
            let date = NSDate(timeIntervalSince1970: weatherObject["time"] as! TimeInterval)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH"

            cell.hourlyLabel.text = "\(dateFormatter.string(from: date as Date))H"
            cell.hourlyIconImage.image = UIImage(named: "\(weatherObject["icon"]!)")
            cell.temperatureLabel.text = "\(Int(temp))°"
        }
        
        return cell
    }
    
    
}
