//
//  blePluginClass.m
//  blePlugin
//
//  Created by Kristina Heyerdahl Elfving on 15.03.13.
//  Copyright (c) 2013 Kristina Heyerdahl Elfving. All rights reserved.
//

#import "blePluginClass.h"

@implementation blePluginClass

@synthesize CBC;
@synthesize CBP;

@synthesize peripheral;
@synthesize discoveredPeripheral;
@synthesize currentCallbackId;
@synthesize currentResultType;



/******************* Plugin functions ********************/


// handles set up
- (void) load:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

    NSLog(@"load");

    self.CBC = [bleConnect alloc];
    self.CBP = [bleDeviceControl alloc];
    if (self.CBC) {
        self.CBC.cBCM = [[CBCentralManager alloc] initWithDelegate:self.CBC queue:nil];
        self.CBC.delegate = self;
    }
    if(self.CBP){
        self.CBP.delegate = self;
    }
    
}

// search
- (void) blePSearch:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    NSString *callbackId = [arguments pop];
    self.currentCallbackId = callbackId;
    
    NSString *resultType = [arguments objectAtIndex:0];
    self.currentResultType = resultType;
    
    if (self.CBC.cBReady){
        [self.CBC.cBCM scanForPeripheralsWithServices:nil options:nil];
    }
    else{
        NSLog(@"Did not scan for peripherals.");
    }
}

// connect
- (void) blePConnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    NSLog(@"blePConnect");
    
    NSString *callbackId = [arguments pop];
    self.currentCallbackId = callbackId;
    
    
    NSString *resultType = [arguments objectAtIndex:0];
    self.currentResultType = resultType;

    if(self.discoveredPeripheral != nil){
        
        [self.CBC.cBCM connectPeripheral:self.discoveredPeripheral options:
         @{CBConnectPeripheralOptionNotifyOnConnectionKey: @NO,
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
        CBConnectPeripheralOptionNotifyOnNotificationKey: @NO}];
        
    }
    else{
        NSLog(@"blePConnect. self.discoveredPeripheral = nil");
    }
        
}

// disconnect
- (void) blePDisconnect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    NSLog(@"blePDisconnect");
    
    NSString *callbackId = [arguments pop];
    self.currentCallbackId = callbackId;
    
    
    NSString *resultType = [arguments objectAtIndex:0];
    self.currentResultType = resultType;
    
    NSLog(@"callbackid %@ resultType %@", callbackId, resultType);
    
    if(self.CBP.currentPeripheral != nil){
        
        [self.CBC.cBCM cancelPeripheralConnection:self.discoveredPeripheral];

    }else{
        NSLog(@"blePDisconnect. currentPeripheral = nil");
    }
    
}

// perform service scan
- (void) blePServiceScan:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    NSString *callbackId = [arguments pop];
    self.currentCallbackId = callbackId;
    
    
    NSString *resultType = [arguments objectAtIndex:0];
    self.currentResultType = resultType;

    
    [self.CBP.currentPeripheral discoverServices: nil];


}

// set notification for service
- (void) blePNotify:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

    NSLog(@"blePNotify");
    
    NSString *callbackId = [arguments pop];
    self.currentCallbackId = callbackId;
    
    
    NSString *resultType = [arguments objectAtIndex:0];
    self.currentResultType = resultType;

    
    if(self.CBP.currentPeripheral != nil){
        NSLog(@"blePNotify - Setting notification..");
        [self.CBP setNotificationForCharacteristic:self.CBP.currentPeripheral sUUID:@"180f" enable:TRUE];
        [self.CBP setNotificationForCharacteristic:self.CBP.currentPeripheral sUUID:@"1809" cUUID:@"2a1c" enable:TRUE];
        
    }
    else{
        NSLog(@"currentPeripheral er nil");
    }
    
    [CBP addObserver:self forKeyPath:@"temperature" options:NSKeyValueObservingOptionNew context:nil];
    [CBP addObserver:self forKeyPath:@"battery" options:NSKeyValueObservingOptionNew context:nil];

    
    NSString *data = [NSString stringWithFormat:@"displayInfo('%@','%@','%@');", nil, self.CBP.battery, nil];
    [self writeJavascript:data];

}

/******************* BLE functions ********************/


- (void) foundPeripheral:(CBPeripheral *)p advertisementData:(NSDictionary *)advertisementData
{
    NSLog(@"blePluginClass.found peripheral %@", p.name);
    
    self.discoveredPeripheral = p;
    [self.CBC.cBCM stopScan];

    CDVPluginResult *result;
    if ( [self.currentResultType isEqualToString:@"success"] ) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@",self.discoveredPeripheral.name]];
        [self writeJavascript:[result toSuccessCallbackString:self.currentCallbackId]];
    }
    else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Error"];
        [self writeJavascript:[result toErrorCallbackString:self.currentCallbackId]];
    }

}

-(void) connectedPeripheral:(CBPeripheral *)p
{
    
    NSLog(@"connectedPeripheral. connected to %@", p.name);
    
    self.CBP.currentPeripheral = p;
    
    // discover services
    [self.CBP.currentPeripheral setDelegate:self.CBP];
    [self.CBP.currentPeripheral discoverServices:[NSArray arrayWithObject: [CBUUID UUIDWithString:@"1809"]]];
    [self.CBP.currentPeripheral discoverServices:[NSArray arrayWithObject: [CBUUID UUIDWithString:@"180f"]]];
    
    NSLog(@"Discover services...");
    
}

-(void) failConnectPeripheral:(CBPeripheral *)p
{
    NSLog(@"failConnectPeripheral %@", p.name);
    
    CDVPluginResult *result;
    
    [self.currentResultType isEqualToString:@"success"];
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"Failed to connect to peripheral"]];
                
    [self writeJavascript:[result toSuccessCallbackString:self.currentCallbackId]];

}



-(void) disconnectedPeripheral:(CBPeripheral *)p
{
    NSLog(@"disconnectedPeripheral %@", p.name);
    
    self.CBP.currentPeripheral = nil;
    
    CDVPluginResult *result;
    
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@",self.discoveredPeripheral.name]];
        
    [self writeJavascript:[result toSuccessCallbackString:self.currentCallbackId]];

}


- (void) updatedCharacteristic:(CBPeripheral *)peripheral sUUID:(CBUUID *)sUUID cUUID:(CBUUID *)cUUID data:(NSData *)data
{
    NSLog(@"blePluginClass - updated characteristic");

    CDVPluginResult *result;
    
    if ( [self.currentResultType isEqualToString:@"success"] ) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@",self.discoveredPeripheral.name]];
        
        [self writeJavascript:[result toSuccessCallbackString:self.currentCallbackId]];
    }
    else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Error"];
        [self writeJavascript:[result toErrorCallbackString:self.currentCallbackId]];
    }
    
}

// Key-value observation - when the temperature is updated
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)CBP change:(NSDictionary *)change context:(void *)context
{
        
    CDVPluginResult *result;
    
    if ([keyPath isEqualToString:@"temperature"] )
    {
        NSLog(@"Temp er %@", self.CBP.temperature);
                
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@T",self.CBP.temperature]];
        
        [self writeJavascript:[result toSuccessCallbackString:self.currentCallbackId]];
        
        NSString *data = [NSString stringWithFormat:@"displayInfo('%@','%@','%@');", nil, nil, self.CBP.temperature];
        [self writeJavascript:data];

        
    }
    else if ([keyPath isEqualToString:@"battery"] )
    {
        
        NSLog(@"Battery er %@", self.CBP.battery);
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@B",self.CBP.battery]];
            
        [self writeJavascript:[result toSuccessCallbackString:self.currentCallbackId]];
       
        
        NSString *data = [NSString stringWithFormat:@"displayInfo('%@','%@','%@');", nil, self.CBP.battery, nil];
        
        [self writeJavascript:data];

    }
}


@end