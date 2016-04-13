//
//  KJBLEDeviceTestViewController.h
//  KJBLE
//
//  Created by 車東秀 on 2016/04/11.
//  Copyright © 2016年 chadongsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJBLEDevice.h"
#import "DefinitionIF.h"

@interface KJBLEDeviceTestViewController : UIViewController {
	IBOutlet UIButton *btnRed;
	IBOutlet UIButton *btnGreen;
	IBOutlet UIButton *btnOrange;
	
	IBOutlet UISwitch *swBlink;
	IBOutlet UISwitch *swRed;
	IBOutlet UISwitch *swGreen;
	IBOutlet UISwitch *swOrange;
	
	IBOutlet UIView *baldView;
	
	ColorType currType;
}

@property (nonatomic, strong) KJBLEDevice *device;

- (IBAction)onButtonClicked:(UIButton *)sender;
- (IBAction)onSwitchChanged:(UISwitch *)sender;

@end
