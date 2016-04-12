//
//  KJBLEManager.h
//  KJBLE
//
//  Created by chadongsu on 2016/03/29.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kBLEDevice;

extern NSString* const kNotifyBLEManagerReady;
extern NSString* const kNotifyBLEDeviceFound;
extern NSString* const kNotifyBLEDeviceConnected;
extern NSString* const kNotifyBLEDeviceConnectFailed;
extern NSString* const kNotifyBLEDeviceDisconnected;

@class KJBLEDevice;

@interface KJBLEManager : NSObject

+ (instancetype)defaultManager;

- (void)testScans;
- (void)scanStop;
- (void)refresh;
- (NSArray *)nearByDevicesList;
- (void)connectDevice:(KJBLEDevice *)device;
- (void)disconnectDevice:(KJBLEDevice *)device;

@end
