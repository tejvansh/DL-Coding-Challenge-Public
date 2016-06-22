//
//  SettingsViewController.m
//  WeatherCast
//
//  Created by Tejvansh Singh Chhabra on 6/22/16.
//  Copyright © 2016 Tejvansh Singh Chhabra. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()
{
    NSMutableArray *data;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    data = [[NSMutableArray alloc] init];
    NSString *city   = [appDelegate.settings objectForKey:@"city"];
    NSString *format = [appDelegate.settings objectForKey:@"format"];
    NSNumber *feel   = [appDelegate.settings objectForKey:@"realFeel"];

    NSString *strFeel = @"Hide Real Feel";
    if(feel.boolValue)
        strFeel = @"Show Real Feel";
    
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Location", @"title", city, @"subtitle", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Temperature Format", @"title", format, @"subtitle", nil]];
    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Real Feel", @"title", strFeel, @"subtitle", nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weatherCell" forIndexPath:indexPath];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"weatherCell"];
        
    }
    cell.textLabel.text = [[data objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.detailTextLabel.text = [[data objectAtIndex:indexPath.row] valueForKey:@"subtitle"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            
            break;
            
        case 1:
            [self swapTemperatureFormat];
            break;
            
        case 2:
            [self swapRealFeel];
            break;
            
        default:
            break;
    }
}

- (void)swapTemperatureFormat {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *format = [appDelegate.settings objectForKey:@"format"];
    if([format isEqualToString:@"Celsius"]) {
        NSMutableDictionary *dictData = [[data objectAtIndex:1] mutableCopy];
        [dictData setValue:@"Fahrenheit" forKey:@"subtitle"];
        [data replaceObjectAtIndex:1 withObject:dictData];
        [appDelegate.settings setObject:@"Fahrenheit" forKey:@"format"];
    }
    else {
        NSMutableDictionary *dictData = [[data objectAtIndex:1] mutableCopy];
        [dictData setValue:@"Celsius" forKey:@"subtitle"];
        [data replaceObjectAtIndex:1 withObject:dictData];
        [appDelegate.settings setObject:@"Celsius" forKey:@"format"];
    }

    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.settings forKey:@"settings"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.tableView reloadData];
}

- (void)swapRealFeel {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSNumber *feel = [appDelegate.settings objectForKey:@"realFeel"];
    
    NSString *strFeel = @"Hide Real Feel";
    if(!feel.boolValue)
        strFeel = @"Show Real Feel";
    
    NSMutableDictionary *dictData = [[data objectAtIndex:2] mutableCopy];
    [dictData setValue:strFeel forKey:@"subtitle"];
    [data replaceObjectAtIndex:2 withObject:dictData];
    
    [appDelegate.settings setObject:[NSNumber numberWithBool:!feel.boolValue] forKey:@"realFeel"];
    
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.settings forKey:@"settings"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.tableView reloadData];
}

#pragma mark - TableView Delegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

#pragma mark - Back Button Action Method

-(IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
