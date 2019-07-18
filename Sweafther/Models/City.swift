//  Sweafther
//
//  City.swift
//
//  Created by Agnieszka Niewiadomski on 09/07/2019.
//  Copyright © 2019 niewia_a. All rights reserved.
//

import Foundation
import os.log

class City: NSObject, NSCoding {
    
    //MARK: Properties
    var name: String
    var temperature: String
    var summary: String
    var icon: String

    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("cities")

    
    //MARK: Initialization
    init(name: String, temperature: String, summary: String, icon: String) {
        self.name = name
        self.temperature = temperature
        self.summary = summary
        self.icon = icon
    }
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let temperature = "temperature"
        static let summary = "summary"
        static let icon = "icon"
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(temperature, forKey: PropertyKey.temperature)
        aCoder.encode(summary, forKey: PropertyKey.summary)
        aCoder.encode(icon, forKey: PropertyKey.icon)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a City object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let temperature = aDecoder.decodeObject(forKey: PropertyKey.temperature) as? String else {
            os_log("Unable to decode the temperature for a City object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let summary = aDecoder.decodeObject(forKey: PropertyKey.summary) as? String else {
            os_log("Unable to decode the summary for a City object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let icon = aDecoder.decodeObject(forKey: PropertyKey.icon) as? String else {
            os_log("Unable to decode the icon for a City object.", log: OSLog.default, type: .debug)
            return nil
        }
        
//        let temperature = aDecoder.decodeString(forKey: PropertyKey.temperature)
        
        // Must call designated initializer.
        self.init(name: name, temperature: temperature, summary: summary, icon: icon )
        
    }
}
