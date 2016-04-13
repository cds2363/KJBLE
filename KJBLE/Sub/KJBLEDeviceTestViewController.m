//
//  KJBLEDeviceTestViewController.m
//  KJBLE
//
//  Created by 車東秀 on 2016/04/11.
//  Copyright © 2016年 chadongsu. All rights reserved.
//

#import "KJBLEDeviceTestViewController.h"

@interface KJBLEDeviceTestViewController ()

@end

@implementation KJBLEDeviceTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = [_device deviceName];
	
	// 関連サービスへ接続する。
	if(_device.peripheral.services == nil) {
		[_device.peripheral discoverServices:nil];
	}
	
	[self resetCurrent];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCharacteristic:) name:kNotifyBLEPeripheralUpdateValueForCharacteristic object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self resetCurrent];
	[self sendData:[self makeSendingData]];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyBLEPeripheralUpdateValueForCharacteristic object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction
- (IBAction)onButtonClicked:(UIButton *)sender {
	if(sender == btnRed) {
		[self sendValue:@"Red"];
	}
	else if(sender == btnGreen) {
		[self sendValue:@"Green"];
	}
	else if(sender == btnOrange) {
		[self sendValue:@"Orange"];
	}
}

- (IBAction)onSwitchChanged:(UISwitch *)sender {
	
	ColorType selectedType;
	
	if(sender == swBlink)		selectedType = TypeBlink;
	else if(sender == swRed)	selectedType = TypeRed;
	else if(sender == swGreen)	selectedType = TypeGreen;
	else						selectedType = TypeOrange;
	
	if(currType & selectedType) {
		if(!sender.on) {
			currType &= ~selectedType;
		}
	}
	else {
		if(sender.on) {
			currType |= selectedType;
		}
	}
	
	[self sendData:[self makeSendingData]];
}

#pragma mark - Private Methods
- (void)resetCurrent {
	currType = TypeNone;
	swRed.on =
	swGreen.on =
	swOrange.on = NO;
}

- (NSData *)makeSendingData {
	uint8_t target = currType;
	NSData *result = [NSData dataWithBytes:&target length:sizeof(uint8_t)];
	NSLog(@"%@", result);
	
	return result;
}

- (void)sendData:(NSData *)param {
	[[_device.peripheral services] enumerateObjectsUsingBlock:^(CBService *service, NSUInteger idx, BOOL *stop) {
		[[service characteristics] enumerateObjectsUsingBlock:^(CBCharacteristic *chara, NSUInteger subIdx, BOOL *subStop) {
			[_device.peripheral writeValue:param forCharacteristic:chara type:CBCharacteristicWriteWithoutResponse];
		}];
	}];
}

- (void)sendValue:(NSString *) str {
	for (CBService * service in [_device.peripheral services]) {
		for (CBCharacteristic * characteristic in [service characteristics])
		{
			[_device.peripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
		}
	}
}


#pragma mark - NSNotify
- (void)updateCharacteristic:(NSNotification *)notify {
	CBCharacteristic *character = notify.userInfo[kBLECharacteristicValue];
	
	if([character value]) {
		NSData *data = [character value];
		
		uint8_t index;
		[data getBytes:&index length:sizeof(uint8_t)];
		
		baldView.backgroundColor = [UIColor colorWithWhite:(index/255.f) alpha:1.f];
	}
}

@end
