//
//  KJBLEMainViewController.m
//  KJBLE
//
//  Created by chadongsu on 2016/03/31.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#import "KJBLEMainViewController.h"
#import "KJBLEManager.h"

#import "KJBLEDeviceInfoViewController.h"

#pragma mark - KJBLEMainListCell
@implementation KJBLEMainListCell
- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)configureCell:(KJBLEDevice *)device indexPath:(NSIndexPath *)indexPath {
	if(device) {
		if([device deviceName]) {
			lbDeviceName.text = [device deviceName];
		}
		else {
			lbDeviceName.text = @"Unknown Device";
		}
		
		lbRSSI.text = [device valueOfRSSI];
		
//		if(device.talkString) {
//			lbServiceName.text = device.talkString;
//		}
//		else {
////			lbServiceName.text = nil;
//		}
		// サービスの数またはサービスのUUIDを列挙する。
		NSArray *arrServices = [device services];
		if([arrServices count] == 0) {
			lbServiceName.text = @"No Service";
		}
		else {
			lbServiceName.text = [NSString stringWithFormat:@"%d Service%@", [arrServices count], ([arrServices count] > 1 ? @"s" : @"")];
		}
		
		if(device.peripheral.identifier.UUIDString) {
			lbUUID.text = device.peripheral.identifier.UUIDString;
		}
	}
}

@end

#pragma mark - KJBLEMainViewController
@interface KJBLEMainViewController ()
@property (nonatomic, strong) KJBLEManager *manager;
@end

@implementation KJBLEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	
	self.manager = [[KJBLEManager alloc] init];
//	[_manager testScans];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managerReady:) name:kNotifyBLEManagerReady object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundDevice:) name:kNotifyBLEDeviceFound object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedDevice:) name:kNotifyBLEDeviceConnected object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedDevice:) name:kNotifyBLEDeviceDisconnected object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCharacteristic:) name:kNotifyBLEPeripheralUpdateValueForCharacteristic object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReady:) name:kNotifyBLEReady object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyBLEManagerReady object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyBLEDeviceFound object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyBLEDeviceConnected object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyBLEDeviceDisconnected object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyBLEReady object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Peripherals Nearby";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[_manager nearByDevicesList] count];
}

/**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KJBLEMainListCell *cell = (KJBLEMainListCell *)[tableView dequeueReusableCellWithIdentifier:@"DeviceListCell" forIndexPath:indexPath];
    
    // Configure the cell...
	if([[_manager nearByDevicesList] count] > indexPath.row) {
		KJBLEDevice *device = [[_manager nearByDevicesList] objectAtIndex:indexPath.row];
		[cell configureCell:device indexPath:indexPath];
	}
	
    return cell;
}
/**/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// 該当デバイスに接続する。
	if([[_manager nearByDevicesList] count] > indexPath.row) {
		KJBLEDevice *device = [[_manager nearByDevicesList] objectAtIndex:indexPath.row];
		
		if(device.state == DeviceStateDisconnected) {
			[_manager connectDevice:device];
		}
		else if(device.state == DeviceStateConnected) {
			[_manager disconnectDevice:device];
		}
//		[self performSegueWithIdentifier:@"connectToDevice" sender:device];
	}
}


/**/
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if([segue.identifier isEqualToString:@"connectToDevice"]) {
		KJBLEDeviceInfoViewController *devInfo = segue.destinationViewController;
		devInfo.selectedDevice = (KJBLEDevice *)sender;
	}
}
/**/

#pragma mark - Notify
- (void)managerReady:(NSNotification *)notify {
	[_manager testScans];
}

- (void)foundDevice:(NSNotification *)notify {
	[self.tableView reloadData];
}

- (void)connectedDevice:(NSNotification *)notify {
	NSLog(@"%s", __FUNCTION__);
}

- (void)disconnectedDevice:(NSNotification *)notify {
	NSLog(@"%s", __FUNCTION__);
}

- (void)updateReady:(NSNotification *)notify {
	[self.tableView reloadData];
}

- (void)updateCharacteristic:(NSNotification *)notify {
	[self.tableView reloadData];
}

@end
