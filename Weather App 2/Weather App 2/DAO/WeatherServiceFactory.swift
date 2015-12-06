//
//  WeatherServiceFactory.swift
//  Weather App 2
//
//  Created by Adrian Ferenc on 05.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

enum WeatherService{
    
    case OPEN_WEATHER_MAP;
    
}

class WeatherServiceFactory {
    class func factoryFor(type : WeatherService) -> AbstractWeatherService {
        Utility.debug(DebugType.INFO, textToLog: "Create weather service.");
        Utility.debug(DebugType.INFO, textToLog: "Weather service type: \(type)");
        
        switch type {
        case WeatherService.OPEN_WEATHER_MAP:
            return WeatherService_OpenWeatherMap();
        }
    }
}