//
//  Utility.swift
//  Weather App 2
//
//  Created by Adrian Ferenc on 05.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import Foundation
import SystemConfiguration

enum DebugType{
    
    case INFO;
    case WARNING;
    case ERROR;
}

enum TemperatureScale{
    
    case CELSIUS;
    case KELVIN;
    case FAHRENHEIT;
    
}

public class Utility{
    
    static func debug(type: DebugType, textToLog: String){
        switch type {
        case DebugType.INFO:
            print(textToLog);
        default:
            print(textToLog);
        }
    }
    
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    static func convertTemperature(sourceTemperature: Double, sourceScale: TemperatureScale, targetScale: TemperatureScale) -> Double{
        
        switch targetScale{
        case TemperatureScale.CELSIUS:
            switch sourceScale{
                
            case TemperatureScale.KELVIN:
                return convertKelvinToCelsius(sourceTemperature);
                
            case TemperatureScale.FAHRENHEIT:
                return convertFahrenheitToCelsius(sourceTemperature);
                
            default:
                Utility.debug(DebugType.ERROR, textToLog: "\(sourceScale) temperature scale is not supported as a source temperature scale.")
                return 0.0;
                
            }
        default:
            Utility.debug(DebugType.ERROR, textToLog: "\(targetScale) temperature scale is not supported as a target temperature scale!")
            return 0.0
        }
        
    }
    
    static func convertKelvinToCelsius(kelvinTemperature: Double) -> Double{
        let kelvinConstant = 273.15;
        return roundToPlaces(Double(kelvinTemperature - kelvinConstant), places: 1);
    }
    
    static func convertFahrenheitToCelsius(fahrenheitTemperature: Double) -> Double{
        let fahrenheitConstant1 = 32.0;
        let fahrenheitConstant2 = 1.8;
        return roundToPlaces(Double((fahrenheitTemperature - fahrenheitConstant1) / fahrenheitConstant2), places: 1);
    }
    
    static func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places));
        return round(value * divisor) / divisor;
    }
    
    static func getTemperatureAsString(temperatureScale: TemperatureScale, temperature: Double) -> String{
        var result = "\(temperature)";
        switch temperatureScale{
        case TemperatureScale.CELSIUS:
            result = result + "\u{00B0}C";
        case TemperatureScale.KELVIN:
            result = result + "\u{00B0}K";
        case TemperatureScale.FAHRENHEIT:
            result = result + "\u{00B0}F";
        }
        return result;
    }
}