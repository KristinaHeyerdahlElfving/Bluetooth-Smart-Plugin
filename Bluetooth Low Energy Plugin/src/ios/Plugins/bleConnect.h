//
//  bleConnect.h
//  testTabbedApp
//
//  Created by Kristina Heyerdahl Elfving on 01.10.12.
//  Copyright (c) 2012 Kristina Heyerdahl Elfving. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

//#import "bleAppDelegate.h"

@protocol bleConnectDelegate <NSObject>

@required
- (void) foundPeripheral:(CBPeripheral *)p advertisementData:(NSDictionary *)advertisementData;
- (void) connectedPeripheral:(CBPeripheral *)p;
- (void) failConnectPeripheral:(CBPeripheral *)p;
- (void) disconnectedPeripheral:(CBPeripheral *)p;

@end

@interface bleConnect : NSObject <CBCentralManagerDelegate> {
    
}

@property (nonatomic, strong) CBCentralManager *cBCM;
@property bool cBReady;
@property (nonatomic,assign) id<bleConnectDelegate> delegate;


// contains discovered peripherals
@property (retain, nonatomic) NSMutableArray *foundPeripherals;

// contains all the connected peripherals
@property (retain, nonatomic) NSMutableArray *connectedPeripherals;


@property (retain, nonatomic) NSMutableArray *batteryLevels;



@end

