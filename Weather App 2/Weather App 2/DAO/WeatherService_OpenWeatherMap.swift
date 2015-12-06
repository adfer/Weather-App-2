//
//  WeatherService_OpenWeatherMap.swift
//  Weather App 2
//
//  Created by Adrian Ferenc on 05.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation

class WeatherService_OpenWeatherMap: AbstractWeatherService {
    
    var delegate: WeatherServiceDelegate?;
    
    func getWeather(cityName: String){
        
        Utility.debug(DebugType.INFO, textToLog: "Pobieranie pogody dla miasta \(cityName)");
        
        let escapedCityName = cityName.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet());
        var apiKey: String! = "";
        var weatherConditionIconPath = "";
        var weatherConditionIconFileType = "";
        var myDict: NSDictionary?;
        if let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path);
        }
        if let dict = myDict {
            apiKey = dict.valueForKey("openweathermap.org")?.valueForKey("apiKey") as! String;
            weatherConditionIconPath = dict.valueForKey("openweathermap.org")?.valueForKey("weatherConditionIconPath") as! String;
            weatherConditionIconFileType = dict.valueForKey("openweathermap.org")?.valueForKey("weatherConditionIconFileType") as! String;
        }
        let apiPath = "http://api.openweathermap.org/data/2.5/weather?q=\(escapedCityName!)&APPID=\(apiKey)";
        let url = NSURL(string: apiPath);
        let session = NSURLSession.sharedSession();
        let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if data != nil {
            let json = JSON(data: data!);
            let cityNameFromService = json["name"].string;
            let temperature = json["main"]["temp"].double!;
            let latitude = json["coord"]["lat"].double;
            let longitude = json["coord"]["lon"].double;
            let weatherDescription = json["weather"][0]["description"].string;
            let weatherConditionIcon = "\(weatherConditionIconPath)\(json["weather"][0]["icon"].string!)\(weatherConditionIconFileType)";
            if cityNameFromService != nil  && weatherDescription != nil {

                let city = City(cityName: cityNameFromService!, latitude: latitude!, longitude: longitude!);

                let weather = Weather_OpenWeatherMap();
                weather.setTemperature(temperature, temperatureScale: TemperatureScale.KELVIN);
                weather.setWeatherIcon(weatherConditionIcon);
                weather.weatherDescription = weatherDescription!;
                
                city.weather = weather;

                if self.delegate != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.setCity(city);
                        self.delegate?.setWeather(city.weather);
                    })
                }
            }
            }
        }
        
        task.resume();
        
    }
    
    func getWeather(latitude: Double, longitude: Double){
        
        Utility.debug(DebugType.INFO, textToLog: "Pobieranie pogody dla miasta o współrzędnych \(latitude) \(longitude)");
        
        if Utility.isConnectedToNetwork() {
            
            var apiKey: String! = "";
            var weatherConditionIconPath = "";
            var weatherConditionIconFileType = "";
            var myDict: NSDictionary?;
            if let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist") {
                myDict = NSDictionary(contentsOfFile: path);
            }
            if let dict = myDict {
                apiKey = dict.valueForKey("openweathermap.org")?.valueForKey("apiKey") as! String;
                weatherConditionIconPath = dict.valueForKey("openweathermap.org")?.valueForKey("weatherConditionIconPath") as! String;
                weatherConditionIconFileType = dict.valueForKey("openweathermap.org")?.valueForKey("weatherConditionIconFileType") as! String;
            }
            let apiPath = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&APPID=\(apiKey)";
            let url = NSURL(string: apiPath);
            let session = NSURLSession.sharedSession();
            let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if data != nil{
                    let json = JSON(data: data!);
                    let cityNameFromService = json["name"].string;
                    let temperature = json["main"]["temp"].double;
                    let latitude = json["coord"]["lat"].double;
                    let longitude = json["coord"]["lon"].double;
                    let weatherDescription = json["weather"][0]["description"].string;
                    let weatherConditionIcon = "\(weatherConditionIconPath)\(json["weather"][0]["icon"].string!)\(weatherConditionIconFileType)";
                    if cityNameFromService != nil  && weatherDescription != nil {
                        let city = City(cityName: cityNameFromService!, latitude: latitude!, longitude: longitude!);
                        
                        let weather = Weather_OpenWeatherMap();
                        weather.setTemperature(temperature!, temperatureScale: TemperatureScale.KELVIN);
                        weather.setWeatherIcon(weatherConditionIcon);
                        weather.weatherDescription = weatherDescription!;
                        
                        city.weather = weather;
                        
                        if self.delegate != nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.delegate?.setCity(city);
                                self.delegate?.setWeather(city.weather);
                            })
                        }
                    }
                }
            }
            
            task.resume();
            
        }
        
    }
}