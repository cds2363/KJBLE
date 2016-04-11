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
//		NSString *strVal = [[NSString alloc] initWithData:[character value] encoding:NSUTF8StringEncoding];
//		baldView.backgroundColor = [UIColor colorWithWhite:(outVal/255.f) alpha:1.f];
		
		NSData *data = [character value];
		const uint8_t *reportData = [data bytes];
		uint16_t tValue = 0;
		
		if((reportData[0] & 0x01) == 0) {
			tValue = reportData[1];
		}
		else {
			tValue = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
		}
		
		int colVal = [[NSString stringWithFormat:@"%i", tValue] intValue];
		
		NSLog(@">>>>>>> %d", colVal);
		baldView.backgroundColor = [UIColor colorWithWhite:(colVal/255.f) alpha:1.f];
	}
}

@end
