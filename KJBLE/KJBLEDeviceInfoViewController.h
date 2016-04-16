//
//  KJBLEDeviceInfoViewController.h
//  KJBLE
//
//  Created by chadongsu on 2016/04/06.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJBLEDevice.h"

@interface KJBLEDeviceInfoViewController : UITableViewController

@property (nonatomic, strong) KJBLEDevice *selectedDevice;

@end
