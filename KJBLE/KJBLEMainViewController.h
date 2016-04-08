//
//  KJBLEMainViewController.h
//  KJBLE
//
//  Created by chadongsu on 2016/03/31.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJBLEDevice.h"

@interface KJBLEMainListCell : UITableViewCell {
	IBOutlet UILabel *lbDeviceName;		// デバイス名
	IBOutlet UILabel *lbServiceName;	// サービス名
	IBOutlet UILabel *lbRSSI;			// RSSI値
	IBOutlet UILabel *lbUUID;			// UUID
}

- (void)configureCell:(KJBLEDevice *)device indexPath:(NSIndexPath *)indexPath;

@end

@interface KJBLEMainViewController : UITableViewController

@end
