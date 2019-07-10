//  Sweafther
//
//  City.swift
//
//  Created by Agnieszka Niewiadomski on 09/07/2019.
//  Copyright © 2019 niewia_a. All rights reserved.
//

import Foundation

class City {
    
    //MARK: Properties
    
    var name: String
    let temperature: Double

    
    //MARK: Initialization
    
    init(name: String, temperature: Double) {
        self.name = name
        self.temperature = temperature
    }
}
