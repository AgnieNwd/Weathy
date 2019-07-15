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
    let temperature:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        
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
                                print("forecastArray<<<<\(forecastArray)")

                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
            
        }
        
        task.resume()
        
    }
    
    static func getCurrentl(typeTemp: String, withLocation location:CLLocationCoordinate2D, completion: @escaping ([String : Any]?) -> ()) {
        var url = basePath + "\(location.latitude),\(location.longitude)?lang=en"
        if typeTemp == "°C" {
            url = url + "&units=si"
        }
        let request = URLRequest(url: URL(string: url)!)
        print(url)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastCurrent = [String:Any]()
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        //print("json<<<<\(json)")
                        
                        if let currentlyForecasts = json["currently"] as? [String:Any] {
                            print("currentlyForecasts<<<<\(currentlyForecasts)")
                            
                            //for Cuurent in currentlyForecasts
                            forecastCurrent = [
                                "time" : currentlyForecasts["time"]!,
                                "temperature" : currentlyForecasts["temperature"]!,
                                "icon" : currentlyForecasts["icon"]!
                            ]
                            
                            print("forecastCurrent<<<<\(forecastCurrent)")
                            
                            
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
    
}
