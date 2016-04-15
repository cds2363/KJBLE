//
//  KJBLEManager.m
//  KJBLE
//
//  Created by chadongsu on 2016/03/29.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#import "KJBLEManager.h"
#import "KJBLEDevice.h"

#pragma mark - Category
@interface KJBLEManager ()
@property (nonatomic, strong) CBCentralManager *centralManage;
@property (nonatomic, strong) NSMutableArray *devices;
@end

NSString* const kBLEDevice = @"KEY_BLE_DEVICE";

NSString* const kNotifyBLEManagerReady = @"BLE_MANAGER_READY";
NSString* const kNotifyBLEDeviceFound = @"BLE_DEVICE_FOUND";
NSString* const kNotifyBLEDeviceConnected = @"BLE_DEVICE_CONNECTED";
NSString* const kNotifyBLEDeviceConnectFailed = @"BLE_DEVICE_CONNECT_FAILED";
NSString* const kNotifyBLEDeviceDisconnected = @"BLE_DEVICE_DISCONNECTED";

@interface KJBLEManager (Manager) <CBCentralManagerDelegate>

@end

@implementation KJBLEManager

+ (instancetype)defaultManager {
	static KJBLEManager *_sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[KJBLEManager alloc] init];
	});
	
	return _sharedInstance;
}

- (instancetype)init {
	
	if(self = [super init]) {
		_centralManage = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		_devices = [[NSMutableArray alloc] initWithCapacity:0];
	}
	
	return self;
}

- (void)scanStart {
	if([_centralManage state] == CBCentralManagerStatePoweredOn) {
		[_centralManage scanForPeripheralsWithServices:nil options:nil];
	}
}

- (void)scanStop {
	if([_centralManage state] == CBCentralManagerStatePoweredOn) {
		[_centralManage stopScan];
	}
}

- (void)refresh {
	if([_centralManage state] == CBCentralManagerStatePoweredOn) {
		[_centralManage stopScan];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[_centralManage scanForPeripheralsWithServices:nil options:nil];
		});
	}
}

- (NSArray *)nearByDevicesList {
	return _devices;
}

- (void)connectDevice:(KJBLEDevice *)device {
	[_centralManage connectPeripheral:device.peripheral options:nil];
}

- (void)disconnectDevice:(KJBLEDevice *)device {
	[_centralManage cancelPeripheralConnection:device.peripheral];
}

@end

#pragma mark - Category
@implementation KJBLEManager (Manager)

#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	NSLog(@"%s", __FUNCTION__);
	
	switch(central.state) {
		case CBCentralManagerStatePoweredOff:	NSLog(@"CBCentralManagerStatePoweredOff");		break;
		case CBCentralManagerStatePoweredOn:
			NSLog(@"CBCentralManagerStatePoweredOn");
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBLEManagerReady object:nil];
			break;
		case CBCentralManagerStateResetting:	NSLog(@"CBCentralManagerStateResetting");		break;
		case CBCentralManagerStateUnauthorized:	NSLog(@"CBCentralManagerStateUnauthorized");	break;
		case CBCentralManagerStateUnknown:		NSLog(@"CBCentralManagerStateUnknown");			break;
		case CBCentralManagerStateUnsupported:	NSLog(@"CBCentralManagerStateUnsupported");		break;
		default:	break;
	}
}
/*
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"central[%@]", central);
	NSLog(@"dict:%@", dict);
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"central[%@]", central);
	NSLog(@"peripherals:%@", peripherals);
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"central[%@]", central);
	NSLog(@"peripherals:%@", peripherals);
}
*/

// BT端末で周りのBTモジュールが発見された場合に呼ばれるコールバックメソッド。
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", advertisementData);
	NSLog(@"RSSI - [%@]", RSSI);
	
	//	scan result
	KJBLEDevice *newDevice = [[KJBLEDevice alloc] initWithPeripheral:peripheral advertisement:advertisementData RSSI:RSSI];
	
	for (KJBLEDevice *device in _devices)	{
		if (memcmp((__bridge const void *)[device peripheral], (__bridge const void *)(peripheral), 16) == 0)	{
			[_devices removeObject:device];
		}
	}
	[_devices addObject:newDevice];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBLEDeviceFound object:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	
	[_devices enumerateObjectsUsingBlock:^(KJBLEDevice *obj, NSUInteger idx, BOOL *stop) {
		// 検出されたデバイスの一覧で、接続されたデバイスのペリペラルのみを限定する。
		if([obj.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
			obj.peripheral.delegate = obj;
			obj.state = DeviceStateConnected;
			
//			if(obj.peripheral.services == nil) {
//				[obj.peripheral discoverServices:nil];
//			}
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBLEDeviceConnected object:nil userInfo:@{kBLEDevice:obj}];
			*stop = YES;
		}
	}];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"ERROR:%@", error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"ERROR:%@", error);
	
	[_devices enumerateObjectsUsingBlock:^(KJBLEDevice *obj, NSUInteger idx, BOOL *stop) {
		if([obj.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
			obj.peripheral.delegate = nil;
			obj.state = DeviceStateDisconnected;
			*stop = YES;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBLEDeviceDisconnected object:nil];
		}
	}];
}

@end
