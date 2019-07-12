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
    let temperature: String

    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("cities")

    
    //MARK: Initialization
    init(name: String, temperature: String) {
        self.name = name
        self.temperature = temperature
    }
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let temperature = "temperature"
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(temperature, forKey: PropertyKey.temperature)
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
        
//        let temperature = aDecoder.decodeString(forKey: PropertyKey.temperature)
        
        // Must call designated initializer.
        self.init(name: name, temperature: temperature)
        
    }
}
