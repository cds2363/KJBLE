//
//  KJBLEDevice.h
//  KJBLE
//
//  Created by chadongsu on 2016/03/29.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString* const kBLECharacteristicValue;

extern NSString* const kNotifyBLEPeripheralUpdateValueForCharacteristic;
extern NSString* const kNotifyBLEReady;

typedef NS_ENUM(NSInteger, DeviceState) {
	DeviceStateDisconnected = 0,
	DeviceStateConnected,
	DeviceStateOthers,
};

@interface KJBLEDevice : NSObject <CBPeripheralDelegate>

@property (nonatomic, assign) DeviceState state;
@property (nonatomic, strong) NSString *talkString;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral advertisement:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (CBPeripheral *)peripheral;
- (NSArray *)services;

- (NSString *)deviceName;
- (NSString *)valueOfServices;
- (NSString *)valueOfRSSI;

@end
