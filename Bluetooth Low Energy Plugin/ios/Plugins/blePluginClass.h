//
//  blePluginClass.h
//  blePlugin
//
//  Created by Kristina Heyerdahl Elfving on 15.03.13.
//  Copyright (c) 2013 Kristina Heyerdahl Elfving. All rights reserved.
//

//#import <Cordova/Cordova.h>
#import <Cordova/CDVViewController.h>
#import <Cordova/CDV.h>


#import <UIKit/UIKit.h>
#import "bleConnect.h"
#import "bleDeviceControl.h"
#import <CoreBluetooth/CoreBluetooth.h>





@interface blePluginClass : CDVPlugin <bleConnectDelegate, bleDeviceControlDelegate>


- (void) load:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void) blePSearch:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void) blePConnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void) blePDisconnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void) blePNotify:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;


// properties:


@property (strong, nonatomic) bleConnect *CBC;
@property (strong, nonatomic) bleDeviceControl *CBP;

@property (strong, nonatomic) CBPeripheral *peripheral;


@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;

@property (strong, nonatomic) NSString *currentCallbackId;
@property (strong, nonatomic) NSString *currentResultType;

@end


