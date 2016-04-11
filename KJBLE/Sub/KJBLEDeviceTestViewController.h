//
//  KJBLEDeviceTestViewController.h
//  KJBLE
//
//  Created by 車東秀 on 2016/04/11.
//  Copyright © 2016年 chadongsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJBLEDevice.h"

@interface KJBLEDeviceTestViewController : UIViewController {
	IBOutlet UIButton *btnRed;
	IBOutlet UIButton *btnGreen;
	IBOutlet UIButton *btnYellow;
	
	IBOutlet UISwitch *swRed;
	IBOutlet UISwitch *swGreen;
	IBOutlet UISwitch *swYellow;
	
	IBOutlet UIView *baldView;
}

@property (nonatomic, strong) KJBLEDevice *device;

- (IBAction)onButtonClicked:(UIButton *)sender;

@end
