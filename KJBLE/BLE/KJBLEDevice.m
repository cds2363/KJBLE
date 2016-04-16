//
//  KJBLEDevice.m
//  KJBLE
//
//  Created by chadongsu on 2016/03/29.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#import "KJBLEDevice.h"

NSString* const kBLECharacteristicValue = @"KEY_BLE_CHARACTERISTIC_VALUE";

NSString* const kNotifyBLEPeripheralUpdateValueForCharacteristic = @"BLE_PERIPHERAL_UPDATE_VALUE_CHARACTERISTIC";
NSString* const kNotifyBLEReady = @"BLE_READY";

@interface KJBLEDevice ()
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSDictionary *advertisementData;
@property (nonatomic, strong) NSNumber *rssi;

@property (nonatomic, strong) NSString *devName;

@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *serviceUUIDS;
@end

@implementation KJBLEDevice

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral advertisement:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	if(self = [super init]) {
		self.peripheral = peripheral;
		self.advertisementData = advertisementData;
		self.rssi = RSSI;
		
		if(advertisementData) {
			self.localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
			NSArray *array = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
			self.serviceUUIDS = [array componentsJoinedByString:@"; "];
		}
	}
	
	return self;
}

- (CBPeripheral *)peripheral {
	return _peripheral;
}

- (NSArray *)services {
	if(_advertisementData) {
		return [_advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
	}
	return nil;
}

- (NSString *)deviceName {
	if(_devName) return _devName;
	return [_peripheral name];
}

- (NSString *)valueOfServices {
	return _serviceUUIDS;
}

- (NSString *)valueOfRSSI {
	return [_rssi stringValue];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", invalidatedServices);
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", RSSI);
	NSLog(@"%@", error);
	
	self.rssi = RSSI;
}

#pragma mark - サービスの検出
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
//		self.peripheral = peripheral;
		
		[_peripheral.services enumerateObjectsUsingBlock:^(CBService *service, NSUInteger idx, BOOL *stop) {
			NSLog(@"[%lu]%@", (unsigned long)idx, service);
			// サービスの特性の検出
			[_peripheral discoverCharacteristics:nil forService:service];
		}];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", service);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
		
	}
}

#pragma mark - サービスの特性の検出
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", service);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
		[service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic *character, NSUInteger idx, BOOL *stop) {
			NSLog(@"[%lu] - %@", (unsigned long)idx, character);
//			[peripheral discoverDescriptorsForCharacteristic:character];
			[_peripheral setNotifyValue:YES forCharacteristic:character];
		}];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", characteristic);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
		self.talkString = [[NSString alloc] initWithData:[characteristic value] encoding:NSUTF8StringEncoding];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBLEPeripheralUpdateValueForCharacteristic object:nil userInfo:@{kBLECharacteristicValue:characteristic}];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", characteristic);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", characteristic);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
	}
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", characteristic);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
		const char * bytes =[(NSData*)[[characteristic UUID] data] bytes];
		if (bytes && strlen(bytes) == 2 && bytes[0] == (char)255 && bytes[1] == (char)225) {
			self.talkString = @"Ready";
//			self.peripheral = peripheral;
			_peripheral.delegate = self;
			[_peripheral.services enumerateObjectsUsingBlock:^(CBService *service, NSUInteger idx, BOOL *stop) {
				[service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic *characteristic, NSUInteger subIdx, BOOL *subStop) {
					[_peripheral setNotifyValue:YES forCharacteristic:characteristic];
				}];
			}];
			
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBLEReady object:nil];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", descriptor);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"%@", peripheral);
	NSLog(@"%@", descriptor);
	
	if(error) {
		NSLog(@"%@", error);
	}
	else {
	}
}

@end
