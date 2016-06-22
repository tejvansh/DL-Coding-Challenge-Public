//
//  ViewController.h
//  WeatherCast
//
//  Created by Tejvansh Singh Chhabra on 6/22/16.
//  Copyright © 2016 Tejvansh Singh Chhabra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    NSDictionary *currentObservation;
    NSArray *arrForeCasts;
    IBOutlet UILabel *lblCity, *lblCond, *lblTime, *lblRealFeel, *lblFormat, *lblTemperature;
    IBOutlet UIImageView *imgIcon;
    IBOutlet UITableView *tableForecasts;
    IBOutlet NSLayoutConstraint *constraintHeight;
}

@end

