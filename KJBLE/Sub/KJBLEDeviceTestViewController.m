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


@end
