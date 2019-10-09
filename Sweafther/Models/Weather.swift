//  Sweafther
//
//  Weather.swift
//  JSON
//
//  Created by Agnieszka Niewiadomski on 08/07/2019.
//  Copyright © 2019 niewia_a. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather {
    let summary:String
    let icon:String
    let temperatureMax:Double
    let temperatureMin:Double
    let uvIndex:Int
    let visibility:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let temperatureMax = json["temperatureMax"] as? Double else {throw SerializationError.missing("tempMax is missing")}
        
        guard let temperatureMin = json["temperatureMin"] as? Double else {throw SerializationError.missing("tempMin is missing")}
        
        guard let uvIndex = json["uvIndex"] as? Int else {throw SerializationError.missing("uvIndex is missing")}

        guard let visibility = json["visibility"] as? Double else {throw SerializationError.missing("visibility is missing")}

        self.summary = summary
        self.icon = icon
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.uvIndex = uvIndex
        self.visibility = visibility

    }
    
    
    static let basePath = "https://api.darksky.net/forecast/ff331d5b21fa1b70b769b58658e1f27f/"

    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        let url = basePath + "\(location.latitude),\(location.longitude)?lang=en&units=si"
        let request = URLRequest(url: URL(string: url)!)
        print(url)

        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
//                        print("json<<<<\(json)")

                        if let dailyForecasts = json["daily"] as? [String:Any] {
//                            print("dailyForecasts<<<<\(dailyForecasts)")
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
//                                print("dailyData<<<<\(dailyData)")

                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
//                                        print("weatherObject<<<<\(weatherObject)")

                                        forecastArray.append(weatherObject)
                                    }
                                }
//                                print("forecastArray<<<<\(forecastArray)")
                            }
                        }
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
            }
            
            
        }
        
        task.resume()
        
    }
    
    static func getCurrently(typeTemp: String, withLocation location:CLLocationCoordinate2D, completion: @escaping ([String : Any]?) -> ()) {
        var url = basePath + "\(location.latitude),\(location.longitude)?lang=en"
        if typeTemp == "°C" {
            url = url + "&units=si"
        }
        let request = URLRequest(url: URL(string: url)!)
        //print(url)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastCurrent = [String:Any]()
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                       // print("json<<<<\(json)")
                        
                        if let currentlyForecasts = json["currently"] as? [String:Any] {
                           // print("json<<<<\(currentlyForecasts)")
                            forecastCurrent = [
                                "time" : currentlyForecasts["time"]!,
                                "temperature" : currentlyForecasts["temperature"]!,
                                "summary" : currentlyForecasts["summary"]!,
                                "icon" : currentlyForecasts["icon"]!,
                                "humidity" : currentlyForecasts["humidity"]!,
                                "pressure" : currentlyForecasts["pressure"]!,
                                "windSpeed" : currentlyForecasts["windSpeed"]!
                            ]
                           //print("forecastCurrent<<<<\(forecastCurrent)")
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastCurrent)

            }
        }
        
        task.resume()
    }
    
    static func getHourlyData(typeTemp: String, withLocation location:CLLocationCoordinate2D, completion: @escaping ([[String:Any]]?) -> ()) {
        var url = basePath + "\(location.latitude),\(location.longitude)?lang=en"
        if typeTemp == "°C" {
            url = url + "&units=si"
        }
        let request = URLRequest(url: URL(string: url)!)
        print(url)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in

            var hourlyForecastArray = [[String:Any]]()
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        
                        if let hourleyForecasts = json["hourly"] as? [String:Any] {
//                            print("hourleyForecasts<<<<\(hourleyForecasts)")

                            if let hourlyData = hourleyForecasts["data"] as? [[String:Any]] {
//                                print("hourlyData<<<<\(hourlyData)")

                                for dataPoint in hourlyData {
//                                    print("dataPoint<<<<\(dataPoint)")

                                    let weatherObject: [String: Any] = [
                                        "time" : dataPoint["time"]!,
                                        "temperature" : dataPoint["temperature"]!,
                                        "summary" : dataPoint["summary"]!,
                                        "icon" : dataPoint["icon"]!
                                    ]
                                    
                                    hourlyForecastArray.append(weatherObject)

                                }
                               // print("hourlyForecastArray<<<<\(hourlyForecastArray)")
                                
                            }
                        }
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(hourlyForecastArray)
            }
        }
        
        task.resume()
    }
    
}
