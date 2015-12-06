//
//  AbstractWeatherService.swift
//  Weather App 2
//
//  Created by Adrian Ferenc on 05.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

protocol WeatherServiceDelegate{
    
    func setWeather(weather: Weather!);
    
    func setCity(city: City!);
    
}

protocol AbstractWeatherService{
    
    var delegate: WeatherServiceDelegate? { get set };
    
    func getWeather(cityName: String);
    
    func getWeather(latitude: Double, longitude: Double);
    
}