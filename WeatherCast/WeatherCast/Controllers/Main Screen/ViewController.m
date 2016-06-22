//
//  ViewController.m
//  WeatherCast
//
//  Created by Tejvansh Singh Chhabra on 6/22/16.
//  Copyright © 2016 Tejvansh Singh Chhabra. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UIImage+animatedGIF.h"
#import <CoreLocation/CoreLocation.h>

const NSString *kWundergroundKey = @"ef2c5bdff96bdac6";

@interface ViewController () <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Refresh Data based on settings changed values
    [self showWeatherData];
    [tableForecasts reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // show spinning activity indicator while load of location/weather information is in progress
    [self startActivityIndicator];
    
    // turn on location services so we can determine the current location
    [self locationManager];
}

- (void)showAlert:(BOOL)show withTitle:(NSString *)title withMessage:(NSString *)message stopActivityIndicator:(BOOL)stopActivityIndicator stopLocationServices:(BOOL)stopLocationServices logMessage:(id)systemLogInformation
{
    if(show) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *btnSettings = [UIAlertAction
                                      actionWithTitle:@"Settings"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                          [[UIApplication sharedApplication] openURL:url];                                    }];
        
        UIAlertAction *btnCancel = [UIAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        [alert addAction:btnSettings];
        [alert addAction:btnCancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if (stopActivityIndicator)
        [self stopActivityIndicator];
    
    if (stopLocationServices)
        [self stopUpdatingLocation];
    
    if (systemLogInformation)
        NSLog(@"%s %@", __FUNCTION__, @[message, systemLogInformation]);
}


#pragma mark - UIActivityIndicator Methods

- (void)startActivityIndicator
{
    // Initialize Activity Indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // Set position of indicator
    activityIndicator.center = self.view.center;
    
    // start the indicator
    [activityIndicator startAnimating];
    
    // add indicator to the view
    [self.view addSubview:activityIndicator];
}

- (void)stopActivityIndicator
{
    // stop indicator
    [activityIndicator stopAnimating];
    
    // remove indicator from the view
    [activityIndicator removeFromSuperview];
}

#pragma mark - CLLocationManager Location Methods

- (void) locationManager
{
    // Check if location manager is enabled in device
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        
        // Check for location manager authorization
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        
        // Update location manager
        [locationManager startUpdatingLocation];
    }
    else {
        // Show Alert to enable location service
       NSString *title    = @"Location Services Disabled";
        NSString *message = @"You currently have all location services for this device disabled. If you proceed, you will be showing past informations. To enable, Settings->Location->location services->on";
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *btnOK = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        [alert addAction:btnOK];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// Stop updating location
- (void)stopUpdatingLocation
{
    if (locationManager != nil)
    {
        [locationManager stopUpdatingLocation];
        locationManager = nil;
    }
}

- (void)requestWhenInUseAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:NO logMessage:@""];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }
}


#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // handle location errors
    NSString *title = @"Error";
    NSString *message = @"Unable to determine location. You must enable location services for this app in Settings.";
    
    // Display Alert
   [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:NO logMessage:error];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // Check if status is changed.
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
             NSString *title = @"Error";
             NSString *message = @"You must authorize this app to determine location of device for this app in Settings.";
             
            // Display Alert when location is disabled
            [self showAlert:NO withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:NO logMessage:@(status)];
        }
            break;
        default:{
            [locationManager startUpdatingLocation];
        }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *location;
    location =  [manager location];
    
    // Update user's location in settings
    [self updateLocationInSettings:location];
    
    // Retrieve Weather Info for user's location
    [self retrieveWeatherForLocation:location forCondition:@"conditions"];
    // Retrieve Weather Info for user's location for 10 days
    [self retrieveWeatherForLocation:location forCondition:@"forecast10day"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    // Update user's location in settings
    [self updateLocationInSettings:location];
    
    // Retrieve Weather Info for user's location
    [self retrieveWeatherForLocation:location forCondition:@"conditions"];
    // Retrieve Weather Info for user's location for 10 days
    [self retrieveWeatherForLocation:location forCondition:@"forecast10day"];
}

#pragma mark - Wunderground API Method

- (void)retrieveWeatherForLocation:(CLLocation *)location forCondition:(NSString *)condition
{
    NSString *strURL = @"";
    
    // get URL for current conditions
    if (location)
    {
        strURL = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/%@/q/%+f,%+f.json",
                     kWundergroundKey, condition,
                     location.coordinate.latitude,
                     location.coordinate.longitude];
    }
    
    NSURL *url          = [NSURL URLWithString:strURL];
    NSData *weatherData = [NSData dataWithContentsOfURL:url];
    
    if (weatherData == nil)
    {
        NSString *title   = @"Error";
        NSString *message = @"Unable to retrieve data from weather service";
        NSString *logMsg  = @"Weather Data is nil";
        
        [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:YES logMessage:logMsg];
        return;
    }
    
    // parse the JSON results
    NSError *error;
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    
    // if there was an error, show alert
    if (error != nil)
    {
        NSString *title   = @"Error";
        NSString *message = @"Error in parsing results from Weather Service";
        
        [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:YES logMessage:error];
        return;
    }
    
    // Check data type of returned object
    else if (![weatherResults isKindOfClass:[NSDictionary class]])
    {
        NSString *title   = @"Error";
        NSString *message = @"Unexpected results from weather service";
        
        [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:YES logMessage:weatherResults];
        
        return;
    }
    
    // Parse the data to get weather info
    NSDictionary *response = weatherResults[@"response"];
    if (response == nil || ![response isKindOfClass:[NSDictionary class]])
    {
        NSString *title   = @"Error";
        NSString *message = @"Unable to parse results from weather service";
        
        [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:YES logMessage:weatherResults];
        return;
    }
    
    // Check for error in response
    NSDictionary *errorDictionary = response[@"error"];
    if (errorDictionary != nil)
    {
        NSString *title   = @"Error";
        NSString *message = @"Error reported by weather service";
        
        if (errorDictionary[@"description"])
            message = [NSString stringWithFormat:@"%@: %@", message, errorDictionary[@"description"]];
        
        [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:YES logMessage:errorDictionary];
        
        // Check for key not found error in response
       if ([errorDictionary[@"type"] isEqualToString:@"keynotfound"])
        {
            NSLog(@"%s You must get a key for your app from http://www.wunderground.com/weather/api/", __FUNCTION__);
        }
        return;
    }
    
    if([condition isEqualToString:@"forecast10day"]) {
        // Get all observations from the response
        arrForeCasts = [[[weatherResults valueForKey:@"forecast"] valueForKey:@"simpleforecast"] valueForKey:@"forecastday"];
        
        // Check if there is any observation in the response
        if (arrForeCasts == nil)
        {
            NSString *title   = @"Error";
            NSString *message = @"No forecasts data found";
            
            [self showAlert:YES withTitle:title withMessage:message stopActivityIndicator:YES stopLocationServices:YES logMessage:weatherResults];
            
            return;
        }
        
        // show data in table
        [tableForecasts reloadData];
    }
    else {
        // get today's weather information
        currentObservation = [weatherResults valueForKey:@"current_observation"];

        // display weather information
        [self showWeatherData];
    }
    
    // Got the data
    [self showAlert:NO withTitle:@"" withMessage:@"" stopActivityIndicator:YES stopLocationServices:YES logMessage:@""];
}

#pragma mark - TableView Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrForeCasts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastCell" forIndexPath:indexPath];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"forecastCell"];
        
    }
    
    // display weather information
    UIImageView *cellImgIcon = [cell viewWithTag:101];
    UILabel *lblLowTemp      = [cell viewWithTag:102];
    UILabel *lblDay          = [cell viewWithTag:103];
    UILabel *lblHighTemp     = [cell viewWithTag:104];
    UILabel *lblCondition    = [cell viewWithTag:105];
    
    NSDictionary *weatherData = [arrForeCasts objectAtIndex:indexPath.row];
    
    UIImage *icon = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:[weatherData valueForKey:@"icon_url"]]];
    [cellImgIcon setImage:icon];
    
    if([self isSavedFormatCelsius]) {
        lblLowTemp.text  = [NSString stringWithFormat:@"%@ °C", [[weatherData valueForKey:@"low"]  valueForKey:@"celsius"]];
        lblHighTemp.text = [NSString stringWithFormat:@"%@ °C", [[weatherData valueForKey:@"high"] valueForKey:@"celsius"]];
    }
    else {
        lblLowTemp.text  = [NSString stringWithFormat:@"%@ °F", [[weatherData valueForKey:@"low"]  valueForKey:@"fahrenheit"]];
        lblHighTemp.text = [NSString stringWithFormat:@"%@ °F", [[weatherData valueForKey:@"high"] valueForKey:@"fahrenheit"]];
    }

    NSString *strDay = [NSString stringWithFormat:@"%@", [[weatherData valueForKey:@"date"] valueForKey:@"weekday"]];
    NSString *strDate = [NSString stringWithFormat:@"%@", [[weatherData valueForKey:@"date"] valueForKey:@"day"]];
    NSString *strMonth = [NSString stringWithFormat:@"%@", [[weatherData valueForKey:@"date"] valueForKey:@"monthname_short"]];
    NSString *strYear = [NSString stringWithFormat:@"%@", [[weatherData valueForKey:@"date"] valueForKey:@"year"]];
    
    // format date
    NSString *strFormattedDate = [NSString stringWithFormat:@"%@, %@ %@ %@", strDay, strDate, strMonth, strYear];
    lblDay.text = strFormattedDate;
    lblCondition.text  = [NSString stringWithFormat:@"%@", [weatherData valueForKey:@"conditions"]];

    return cell;
}

#pragma mark - TableView Delegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

#pragma mark - Settings save Methods

// save user locations in settings
- (void)updateLocationInSettings:(CLLocation *)location {
    [self saveCityForLocation:location];
    
    NSNumber *latitude  = [NSNumber numberWithDouble:[location coordinate].latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:[location coordinate].longitude];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.settings setValue:latitude  forKey:@"location_lat"];
    [appDelegate.settings setValue:longitude forKey:@"location_long"];
    
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.settings forKey:@"settings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// get city and save city in settings
- (void)saveCityForLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error) {
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
         AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         
         NSString *city = placemark.locality;
         if(city == nil)
             city = @"";
         
         lblCity.text = city;
         
         [appDelegate.settings setValue:city    forKey:@"city"];
         [[NSUserDefaults standardUserDefaults] setObject:appDelegate.settings forKey:@"settings"];
         [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
}

- (void)showWeatherData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSNumber *realFeel = [appDelegate.settings valueForKey:@"realFeel"];
    
    if(realFeel.boolValue)
        constraintHeight.constant = 0;
    else
        constraintHeight.constant = 25;
    
    lblFormat.text = @"°F";
    if([self isSavedFormatCelsius])
        lblFormat.text = @"°C";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    lblTime.text = currentTime;
    
    if(currentObservation != nil) {
        NSString *temperatureKey = @"dewpoint_f";
        if([self isSavedFormatCelsius])
            temperatureKey = @"dewpoint_c";
        
        NSString *feelslikeKey = @"feelslike_f";
        if([self isSavedFormatCelsius])
            feelslikeKey = @"feelslike_c";
        
        UIImage* mygif = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:[currentObservation valueForKey:@"icon_url"]]];
        [imgIcon setImage:mygif];
        
        lblCond.text = [currentObservation valueForKey:@"weather"];
        lblTemperature.text = [NSString stringWithFormat:@"%@", [currentObservation valueForKey:temperatureKey]];
        lblRealFeel.text = [NSString stringWithFormat:@"%@ %@", [currentObservation valueForKey:feelslikeKey], lblFormat.text];
    }
}

// check format saved in settings
- (BOOL)isSavedFormatCelsius
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *format = [appDelegate.settings valueForKey:@"format"];
    if([format isEqualToString:@"Celsius"])
        return YES;
    return NO;
}

@end
