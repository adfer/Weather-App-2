//
//  MapWithSearchViewController.swift
//  Weather App 2
//
//  Created by Adrian Ferenc on 04.12.2015.
//  Copyright © 2015 Adrian Ferenc. All rights reserved.
//

import UIKit
import MapKit

extension UIView {
    /**
     Usage: insert view.fadeTransition right before changing content
     - parameter duration: duration of fade animation
     */
    func fadeTransition(duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.addAnimation(animation, forKey: kCATransitionFade)
    }
}

class MapWithSearchViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, WeatherServiceDelegate{
    
    @IBOutlet weak var mapView: MKMapView!;
    
    @IBOutlet weak var searchCityTextField: UITextField!;
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var weatcherStateIcon: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var subView: UIView!
    
    var mapAnnotations: [MKAnnotation] = [MKAnnotation]();
    
    let fadeTransitionDuration = 0.4;
    
    var touchedPoint = CLLocationCoordinate2D();
    
    var locationChangedByTouch = false;
    
    var city: City?;
    
    //init weather service
    var weatherService: AbstractWeatherService = WeatherServiceFactory.factoryFor(WeatherService.OPEN_WEATHER_MAP);
    
    //user localization
    
    let locationManager = CLLocationManager();
    
    var userLocation = CLLocation();

    
    override func viewDidLoad() {
        super.viewDidLoad();

        //check authorization for getting location of device
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.requestWhenInUseAuthorization();
            self.locationManager.startUpdatingLocation();
        }
        
        self.searchCityTextField.delegate = self;
        self.weatherService.delegate = self;
        
        //change sub-view which is displayed on map
        self.subView.layer.cornerRadius = 10;
        self.subView.layer.masksToBounds = true;
        
        //set up map view
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "getWeatherForTouchedPlace:")
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.mapView.addGestureRecognizer(singleTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    func getWeatherForTouchedPlace(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.locationInView(self.mapView);
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView);
        self.touchedPoint = newCoordinates;
        self.locationChangedByTouch = true;
        self.weatherService.getWeather(newCoordinates.latitude, longitude: newCoordinates.longitude);
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //hide keyboard
        self.searchCityTextField.resignFirstResponder();
        self.view.endEditing(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        Utility.debug(DebugType.INFO, textToLog: "Text from text field: \(self.searchCityTextField.text!)");
        //hide keyboard
        self.searchCityTextField.resignFirstResponder();
        self.weatherService.getWeather(textField.text!);
        return true;
    }
    
    func setWeather(weather: Weather!) {
        Utility.debug(DebugType.INFO, textToLog: "Setting weather informations for ");
        Utility.debug(DebugType.INFO, textToLog: "\(self.city?.cityName) \(weather.temperature) \(weather.weatherDescription)");
        temperatureLabel.fadeTransition(fadeTransitionDuration);
        temperatureLabel.text = Utility.getTemperatureAsString(TemperatureScale.CELSIUS, temperature:  weather.temperature);
        descriptionLabel.fadeTransition(fadeTransitionDuration);
        descriptionLabel.text = weather.weatherDescription;
        self.weatcherStateIcon.image = weather.weatherIcon;
    }
    
    func setCity(city: City!) {
        Utility.debug(DebugType.INFO, textToLog: "Setting city informations: \(city.cityName)");
        self.city = city;
        cityLabel.fadeTransition(fadeTransitionDuration);
        cityLabel.text = self.city!.cityName;
    
        if Utility.isConnectedToNetwork() {
            var center : CLLocationCoordinate2D;
            var span : MKCoordinateSpan;
            var annotationCoordinates: CLLocationCoordinate2D;
            if(locationChangedByTouch){
                span = MKCoordinateSpan(latitudeDelta: self.mapView.region.span.longitudeDelta, longitudeDelta: self.mapView.region.span.latitudeDelta);
                center = CLLocationCoordinate2D(latitude: self.touchedPoint.latitude + (span.latitudeDelta / 10), longitude: self.touchedPoint.longitude);
                annotationCoordinates = CLLocationCoordinate2D(latitude: self.touchedPoint.latitude, longitude: self.touchedPoint.longitude);
            }
            else{
                span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1);
                center = CLLocationCoordinate2D(latitude: city.latitude + (span.latitudeDelta / 10), longitude: city.longitude);
                annotationCoordinates = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude);
            }
            let region = MKCoordinateRegion(center: center, span: span);
            self.mapView.setRegion(region, animated: true);
            
            //add annotation icon representing this city
            self.mapView.removeAnnotations(mapAnnotations);
            self.mapAnnotations.removeAll();
            let annotation = MKPointAnnotation();
            annotation.coordinate = annotationCoordinates;
            self.mapAnnotations.append(annotation);
            self.mapView.addAnnotations(mapAnnotations);
            
            self.locationChangedByTouch = false;
        }
        else {
            self.noInternetConnectionAlert();
        }
    }

    func noInternetConnectionAlert(){
        
        let noInternetConnectionAlert = UIAlertController(title: NSLocalizedString("NO_INTERNET_CONNECTION_TITLE", comment:""), message: "NO_INTERNET_CONNECTION_MESSAGE", preferredStyle: UIAlertControllerStyle.Alert);
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: UIAlertActionStyle.Default, handler: nil);
        
        noInternetConnectionAlert.addAction(okAction);
        
        
        self.presentViewController(noInternetConnectionAlert, animated: true, completion: nil);
        
    }
    
    @IBAction func myLocationAction(sender: UIButton) {
    
        if Utility.isConnectedToNetwork() {
            self.weatherService.getWeather(self.userLocation.coordinate.latitude,longitude: self.userLocation.coordinate.longitude);
        }
        else {
            self.noInternetConnectionAlert();
        }
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, error) -> Void in
            if error != nil {
                Utility.debug(DebugType.ERROR, textToLog: "Error while getting default location: \(error)");
                return;
            }
            if placemarks!.count > 0{
                let pm = placemarks![0] as CLPlacemark;
                self.locationManager.stopUpdatingLocation();
                self.userLocation = pm.location!;
                self.getWeatherForDefaultLocation();
            }
        }
    }
    
    func getWeatherForDefaultLocation(){
        self.weatherService.getWeather(self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude);
    }
    
}

