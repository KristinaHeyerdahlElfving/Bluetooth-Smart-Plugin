//
//  bleDeviceControl.m
//  testTabbedApp
//
//  Created by Kristina Heyerdahl Elfving on 02.10.12.
//  Copyright (c) 2012 Kristina Heyerdahl Elfving. All rights reserved.
//



#import "bleDeviceControl.h"

@implementation bleDeviceControl

@synthesize delegate;
@synthesize temperature;
@synthesize battery;
@synthesize healththermometerPeripherals;
@synthesize currentPeripheral;
@synthesize chosenPeripheral;


// when the serivice discovery is done
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // alloc 
    healththermometerPeripherals = [[NSMutableArray alloc] initWithObjects:nil];
    
    // the service scan might have failed
    // if successful, error = nil
    if (!error) {
        NSLog(@"didDiscoverServices. Service discovery on peripheral : %@ UUID: %@ service: %@ OK !", peripheral, peripheral.UUID, peripheral.services);
 
        
        int i = 0;
        for(CBService *service in peripheral.services) {
            NSLog(@"Service %d : %@ UUID: %@",i, service, service.UUID);
            
            
            [peripheral discoverCharacteristics:Nil forService:service];
            i++;
            
            // the peripheral has health thermometer
            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"1809"]]) {

                NSLog(@"service UUID er 1809? %@  %@", service.UUID, peripheral.name);
                
                if (![healththermometerPeripherals containsObject:peripheral]) {
                    [healththermometerPeripherals addObject:peripheral];
                                        
                }
                
            }
        }
        
        [self.delegate updatedCharacteristic:peripheral sUUID:nil cUUID:nil data:nil];

        
    }
    // if the service scan failed
    else {
        NSLog(@"Service discovery on peripheral : %@ UUID: %@ Failed !", peripheral, peripheral.UUID);
       
    }
    
}


// when characteristic discovery is done
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    // So we now have done a services scan and it might have worked, or it might have failed.
    if (!error) {
        NSLog(@"Service discovery on peripheral : %@ UUID: %@ OK !", peripheral, peripheral.UUID);
        
        
        int i = 0;
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"[%d] - Characteristic : %@ UUID: %@ handle: ",i,characteristic,characteristic.UUID);
            
            i++;
        }
    }
    
}


// TODO
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    
    
}


// TODO
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {


}


// TODO
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

// invoked from readValueForCharacteristic or ..
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Peripheral - didUpdateValueForCharacteristic");

    if (!error) {
        for (CBService *service in peripheral.services) {
            
            for (CBCharacteristic *c in service.characteristics) {
                if ([c isEqual:characteristic]) {
                    
                    NSLog(@"characteristic UUID: %@", c.UUID);
                    
                    // if the characteristic is temperature
                    if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2a1c"]]) {

                        // convert temperature
                        [self convertTemperature:characteristic.value];

                    }
                    // battery
                    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180f"]]) {
                        
                
                        [self convertBattery:characteristic.value.description];

                        
                    }
                    if([service.UUID isEqual:[CBUUID UUIDWithString:@"180a"]] && [c.UUID isEqual:[CBUUID UUIDWithString:@"2a29"]])
                    {
                        
                    // Read manufacturer name
                        NSLog(@"Found a Device Manufacturer Name Characteristic - Read manufacturer name");

                        [self manufacturername:characteristic.value.description];
                                    
                        
                    }
                
                    else {
                        NSLog(@"NB - must handle characteristic with service UUID %@ and characteristic UUID %@", service.UUID, c.UUID);
                        
                    }
                }
            }
        }
    }
    else {
        NSLog(@"Error didUpdateValueForCharacteristic : %@",error);
        
    }
}

-(void) manufacturername:(NSString *)nsdataobject
{

    
    NSString *a = nsdataobject.description;

    
    //53494e54 4546
    
    NSString *b = @"4645544e4953";
    
    [b UTF8String];

    
    
    NSLog(@"Manufacturer Name = %@", a);
    
    
}
// fix temperature
-(void) convertTemperature:(NSString *)nsdataobject
{
    
    NSLog(@"convert temperature:%@", nsdataobject);
        
    NSString *a = nsdataobject.description;
    
    NSMutableString *finalString = [NSMutableString string];
    
    // test if the temperature is correct?
    if(a.length < 8){
        NSLog(@"Error. Did not get the correct temperature from peripheral.");
        [finalString appendString:@"Error. Did not get the correct temperature from peripheral."];

        //[manage test:finalString];
        self.temperature = finalString;
        
    }
    else {
        
        // 3 copies of data
        NSMutableString *part1 = [NSMutableString stringWithString:a];
        NSMutableString *part2 = [NSMutableString stringWithString:a];
        NSMutableString *part3 = [NSMutableString stringWithString:a];
        
        // part 1
        NSRange range;
        range.location = 0;
        range.length = 3;
        [part1 deleteCharactersInRange:range];
        range.location = 2;
        range.length = 12 ;
        [part1 deleteCharactersInRange:range];
        //NSLog(@"1 del :%@", part1);

        
        // part 2
        range.location = 0;
        range.length = 5;
        [part2 deleteCharactersInRange:range];
        range.location = 2;
        range.length = 10;
        [part2 deleteCharactersInRange:range];
        //NSLog(@"2 del :%@", part2);

        
        // part 3
        range.location = 0;
        range.length = 7;
        [part3 deleteCharactersInRange:range];
        range.location = 2;
        range.length = 8;
        [part3 deleteCharactersInRange:range];
        //NSLog(@"3 del :%@", part3);

        // put them together
        [part3 appendString:part2];
        //[part3 appendString:@","];
        [part3 appendString:part1];
        
        
        //NSLog(@"result from fixing bits %@",part3);
        
        // convert hexadecimal to decimal
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:part3];
        
        [scanner scanHexInt:&result];
        
        //NSLog(@"convert to int %@", part3);
        
        // adding a comma....
        
        // convert unsigned int to int
        int resultCopy = (int) result;
        
        // copy to a string
        NSString *resultStr;
        finalString = [NSMutableString string];
        
        resultStr = [NSString stringWithFormat:@"%d",resultCopy];
        
        [finalString appendString:resultStr];
        [finalString insertString:@"," atIndex:2];
        
              
        // the temperature is ready!
        self.temperature = finalString;

    }
    
}
// fix batterylevel
-(void) convertBattery:(NSString *)string
{
    
    NSString *batteryLevel = string;
    //NSLog(@"battery devicecontrol: %@", batteryLevel);
    
    
    NSMutableString *batteryLevel2 = [NSMutableString stringWithString:batteryLevel];
    
    NSRange range;
    range.location = 0;
    range.length = 1;
    [batteryLevel2 deleteCharactersInRange:range];
    range.location = 2;
    range.length = 5;
    [batteryLevel2 deleteCharactersInRange:range];
    
    //NSLog(@"før skifte fra hex: %@", batteryLevel2);

    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:batteryLevel2];
    
    [scanner scanHexInt:&result];
    int resultCopy = (int) result;
    
    NSString *resultStr;
    
    resultStr = [NSString stringWithFormat:@"%d",resultCopy];
    
    NSMutableString *finalString = [NSMutableString string];
    
    resultStr = [NSString stringWithFormat:@"%d",resultCopy];
    
    [finalString appendString:resultStr];
    
    
    //NSLog(@"etter skifte, konvertert til desimal: %d", resultCopy);
    self.battery = finalString;
    
    
    //NSLog(@"updated temperature: %@", finalString);
    
}




- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"Peripheral - didWriteValueForCharacteristic");
    if(error){
        NSLog(@"Error didWriteValueForCharacteristic : %@",error);

    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
   
}


// write to characteristic
-(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data {
    
    NSLog(@"Sending %@ to peripheral", data);

    for (CBService *service in peripheral.services) {
        NSLog(@"Service %@",service.UUID);

        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                NSLog(@"Characteristic %@",characteristic.UUID);
                
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    
                    // write characteristic
                    NSLog(@"Found Service, characteristic, writing value");
                    
                    // writing
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];

                }
            }
        }
    }
}

// read characteristic
-(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID {
    NSLog(@"Reading from peripheral, services %@", peripheral.services);
    
    for ( CBService *service in peripheral.services ) {
        NSLog(@"Service %@",service.UUID);
        NSLog(@"Service %@",peripheral.services);

        if([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                NSLog(@"Charateristic %@",characteristic.UUID);

                
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    // Everything is found, read characteristic ! 
                    NSLog(@"Found Service,Characteristic, reading value");
                    
                    // metoden readValueForCharacteristic
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}


// notification for characteristic
-(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable {
    NSLog(@"Setting notification for peripheral, services %@", peripheral.services);
    for ( CBService *service in peripheral.services ) {
        
        NSLog(@"Service %@",service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                NSLog(@"Characteristic %@",characteristic.UUID);
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]])
                {

                    // set notification
                    NSLog(@"Found Service,Characteristic, setting notification state");
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                    
                }
                
            }
        }
    }
}

// notification for service
// used to find batterylevel
-(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID enable:(BOOL)enable {
    NSLog(@"Setting notification for peripheral, services %@", peripheral.services);
    

    
    
    for ( CBService *service in peripheral.services ) {
        NSLog(@"peripheral service %@",peripheral.services);

        NSLog(@"Service UUID %@",service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                
                    
                // set notification
                NSLog(@"Found Service setting notification state");
                [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                    
                
            }
        }
    }
}



@end
