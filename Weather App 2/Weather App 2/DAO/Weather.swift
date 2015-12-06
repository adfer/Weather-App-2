//
//  Weather.swift
//  Weather App 2
//
//  Abstract class for weather data
//
//  Created by Adrian Ferenc on 05.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation
import UIKit

protocol Weather{

    var temperature: Double{ get set };
    var temperatureScale: TemperatureScale { get set };
    var weatherDescription: String { get set };
    var weatherIcon: UIImage { get set }
    
    func setTemperature(temperature: Double, temperatureScale: TemperatureScale);

    func setWeatherIcon(iconUrl: String);
    
}