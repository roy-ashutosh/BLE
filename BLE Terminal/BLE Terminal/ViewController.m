//
//  ViewController.m
//  BLE Terminal
//
//  Created by Ashutosh Roy on 11/08/19.
//  Copyright © 2019 Ashutosh Roy. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define TIMER_SCAN_INTERVAL  5.0
#define TIMER_PAUSE_INTERVAL 10.0

#define UUID_HEART_RATE_SERVICE @"0x180D"
#define UUID_BLOOD_PRESSURE_SERVICE @"0x1810"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSLayoutConstraint *aboutTableLeftConst,*aboutTableRightConst,*aboutTableTopConst,*aboutTableBottomConst;
    NSMutableArray *deviceList;
}
@property (nonatomic, strong) UITableView *aboutTableView;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, assign) BOOL keepScanning;
@property (nonatomic, strong) CBPeripheral *sensorTag;

@end

@implementation ViewController

-(UITableView*) aboutTableView
{
    if(!_aboutTableView)
    {
        _aboutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _aboutTableView.translatesAutoresizingMaskIntoConstraints = NO;
//        _aboutTableView.backgroundColor = UIColor.whiteColor;
        _aboutTableView.delegate = self;
        _aboutTableView.dataSource = self;
        
//        _aboutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _aboutTableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f  blue:242.0f/255.0f  alpha:1];
    
    [self setNavigationBar];
    [self configureViews];

    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
//    [self cleanup];
}

-(void) configureViews
{
    self.aboutTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.aboutTableView];
    
    if (@available(iOS 11.0, *)) {
        
        aboutTableLeftConst = [NSLayoutConstraint constraintWithItem:self.aboutTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        
        aboutTableRightConst = [NSLayoutConstraint constraintWithItem:self.aboutTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        
    }else{
        
        aboutTableLeftConst = [NSLayoutConstraint constraintWithItem:self.aboutTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        
        aboutTableRightConst = [NSLayoutConstraint constraintWithItem:self.aboutTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    }
    
    aboutTableTopConst = [NSLayoutConstraint constraintWithItem:self.aboutTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    aboutTableBottomConst = [NSLayoutConstraint constraintWithItem:self.aboutTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[aboutTableLeftConst, aboutTableRightConst, aboutTableTopConst, aboutTableBottomConst ]];
}

-(void)setNavigationBar
{
    self.navigationItem.title = @"Device List";
}

- (void)pauseScan {
    NSLog(@"*** PAUSING SCAN...");
    [self.centralManager stopScan];
}

- (void)resumeScan {
    if (self.keepScanning) {
        // Start scanning again...
        NSLog(@"*** RESUMING SCAN!");
        deviceList = [[NSMutableArray alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:TIMER_SCAN_INTERVAL target:self selector:@selector(pauseScan) userInfo:nil repeats:NO];
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)cleanup {
//    [_centralManager cancelPeripheralConnection:self.sensorTag];
}


// MARK: Table View Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Select a device";
    }
    return nil;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return 4;
    NSInteger deviceCount = 0;

    deviceCount = [deviceList count];
    
    return deviceCount;
    
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Others";
    UITableViewCell *cell = [ tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    CBPeripheral *peripheral = deviceList[indexPath.row];
    cell.textLabel.text = peripheral.name;
//    cell.textLabel.text = @"\u2001 Wi-Fi 1";
//    cell.detailTextLabel.text = @"Connected";
    
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.aboutTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = deviceList[indexPath.row];
    
    self.keepScanning = NO;
    
    // save a reference to the sensor tag
    self.sensorTag = peripheral;
    self.sensorTag.delegate = self;
    
    // Request a connection to the peripheral
    [self.centralManager connectPeripheral:self.sensorTag options:nil];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //hello
    
    
    CBPeripheral *peripheral = deviceList[indexPath.row];
    
    DetailViewController *attributionVC = [[DetailViewController alloc] init];
    attributionVC.sensorTag = peripheral;
    [self.navigationController pushViewController:attributionVC animated:YES];
    
}

#pragma mark - CBCentralManagerDelegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL showAlert = YES;
    NSString *state = @"";
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"This device does not support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"This app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth on this device is currently powered off.";
            break;
        case CBCentralManagerStateResetting:
            state = @"The BLE Manager is resetting; a state update is pending.";
            break;
        case CBCentralManagerStatePoweredOn:
            showAlert = NO;
            state = @"Bluetooth LE is turned on and ready for communication.";
            NSLog(@"%@", state);
            self.keepScanning = YES;
            [NSTimer scheduledTimerWithTimeInterval:TIMER_SCAN_INTERVAL target:self selector:@selector(pauseScan) userInfo:nil repeats:NO];
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            
            deviceList = [[NSMutableArray alloc] init];
            break;
        case CBCentralManagerStateUnknown:
            state = @"The state of the BLE Manager is unknown.";
            break;
        default:
            state = @"The state of the BLE Manager is unknown.";
    }
    
    if (showAlert) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Central Manager State" message:state preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
    NSString *peripheralName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    peripheralName = peripheral.name;
    NSString *peripheralId = peripheral.identifier.UUIDString;
    NSLog(@"NEXT PERIPHERAL: %@ (%@)", peripheralName, peripheral.identifier.UUIDString);
    if (peripheralName) {
        BOOL flag = NO;
        for (CBPeripheral *per in deviceList) {
            if ([peripheral.identifier.UUIDString isEqualToString:(per.identifier.UUIDString)])
            {
                flag = YES;
                break;
            }
        }
        if (!flag)
        {
            [deviceList addObject:peripheral];
        }
        [self.aboutTableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"**** SUCCESSFULLY CONNECTED TO SENSOR TAG!!!");
    [peripheral discoverServices:nil];
    
//    for (CBPeripheral *per in deviceList) {
        CBPeripheral *per;
        for (int i=0; i<deviceList.count; i++)
        {
            per = deviceList[i];
            if ([peripheral.identifier.UUIDString isEqualToString:(per.identifier.UUIDString)])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                UITableViewCell *cell = [self.aboutTableView cellForRowAtIndexPath:indexPath];
                cell.detailTextLabel.text = @"Connected";
                
                cell.accessoryType = UITableViewCellAccessoryDetailButton;

            }
        }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"**** CONNECTION FAILED!!!");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"**** DISCONNECTED FROM SENSOR TAG!!!");
    CBPeripheral *per;
    for (int i=0; i<deviceList.count; i++)
    {
        per = deviceList[i];
        if ([peripheral.identifier.UUIDString isEqualToString:(per.identifier.UUIDString)])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [self.aboutTableView cellForRowAtIndexPath:indexPath];
            cell.detailTextLabel.text = @"";
            cell.accessoryType = nil;
            break;
            
        }
    }
}
@end
