//
//  KJBLEDeviceTestViewController.m
//  KJBLE
//
//  Created by 車東秀 on 2016/04/11.
//  Copyright © 2016年 chadongsu. All rights reserved.
//

#import "KJBLEDeviceTestViewController.h"
#import "DefinitionIF.h"

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
	
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCharacteristic:) name:kNotifyBLEPeripheralUpdateValueForCharacteristic object:nil];
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
	else if(sender == btnYellow) {
		[self sendValue:@"Yellow"];
	}
}

#pragma mark - Private Methods
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
