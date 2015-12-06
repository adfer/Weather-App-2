//
//  City.swift
//  Weather App 2
//  
//  Contains information about city
//
//  Created by Adrian Ferenc on 05.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

class City {
    
    var cityName: String;
    var latitude: Double;
    var longitude: Double;
    var weather: Weather?;
    
    init(cityName: String, latitude: Double, longitude: Double){
    
        self.cityName = cityName;
        self.latitude = latitude;
        self.longitude = longitude;
    
    }
    
}