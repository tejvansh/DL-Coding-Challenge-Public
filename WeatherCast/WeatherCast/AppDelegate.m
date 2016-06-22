//
//  AppDelegate.m
//  WeatherCast
//
//  Created by Tejvansh Singh Chhabra on 6/22/16.
//  Copyright © 2016 Tejvansh Singh Chhabra. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize settings;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSDictionary *storedSettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];
    
    // Set default settings with "Fahrenheit" as default format, realfeel feature on and location as detroit, which will be changed to user's location in the app later.
    if(storedSettings == nil) {
        settings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                    @"Detroit", @"city", @"Fahrenheit", @"format", [NSNumber numberWithDouble: 42.335345], @"location_lat", [NSNumber numberWithDouble:-83.049229], @"location_long", [NSNumber numberWithBool:YES], @"realFeel" , nil];
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"settings"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        settings = [storedSettings mutableCopy];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
