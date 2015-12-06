//
//  Weather_OpenWeatherMap.swift
//  Weather App 2
//
//  Created by Adrian Ferenc on 05.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation
import UIKit

class Weather_OpenWeatherMap: Weather {
    
    var temperature: Double;
    var temperatureScale: TemperatureScale;
    var weatherDescription: String = "";
    var weatherIcon: UIImage = UIImage();
    
    required init() {
        self.temperature = 0.0;
        self.temperatureScale = TemperatureScale.KELVIN;
    }
    
    func setTemperature(temperature: Double, temperatureScale: TemperatureScale) {
        self.temperature = Utility.convertTemperature(temperature, sourceScale: temperatureScale, targetScale: TemperatureScale.CELSIUS);
    }
    
    func setWeatherIcon(iconUrl: String) {
        if(Utility.isConnectedToNetwork()){
            if let url = NSURL(string: iconUrl) {
                if let data = NSData(contentsOfURL: url) {
                    self.weatherIcon = UIImage(data: data)!
                }
            }
        }
    }
}