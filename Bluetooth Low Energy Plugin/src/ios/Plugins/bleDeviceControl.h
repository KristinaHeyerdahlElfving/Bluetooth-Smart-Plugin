//
//  bleDeviceControl.h
//  testTabbedApp
//
//  Created by Kristina Heyerdahl Elfving on 02.10.12.
//  Copyright (c) 2012 Kristina Heyerdahl Elfving. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol bleDeviceControlDelegate <NSObject>


-(void) updatedCharacteristic:(CBPeripheral *)peripheral sUUID:(CBUUID *)sUUID cUUID:(CBUUID *)cUUID data:(NSData *)data;

@end

@interface bleDeviceControl : NSObject <CBPeripheralDelegate>


@property (strong,nonatomic) id<bleDeviceControlDelegate> delegate;


@property (strong,nonatomic) NSString *temperature;
@property (strong,nonatomic) NSString *battery;


// used in first view in the peripheral picker
@property (strong,nonatomic) CBPeripheral *chosenPeripheral;

// the currently chosen peripheral - used to show correct info when multiple peripherals are connected
@property (strong,nonatomic) CBPeripheral *currentPeripheral;


// contains all the connected peripherals with a health thermometer
@property (retain, nonatomic) NSMutableArray *healththermometerPeripherals;


-(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data;

-(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID;

-(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable;

-(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID enable:(BOOL)enable;

-(void)convertTemperature:(NSData *)data;

@end