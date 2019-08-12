//
//  DetailViewController.m
//  BLE Terminal
//
//  Created by Ashutosh Roy on 11/08/19.
//  Copyright © 2019 Ashutosh Roy. All rights reserved.
//

#import "DetailViewController.h"

#define TICKET_DETAILS @"Details"
#define TERMINAL_TEXT @"Terminal"

@interface DetailViewController() <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate>
{
//    NSMutableDictionary *infoDict;
    NSMutableArray *details;
    NSMutableArray *servicesList;
    NSMutableArray *characteristicList;
}

@property (nonatomic, strong) UIView *segmentHolderView;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *ticketsMainView;
@property (nonatomic, strong) UIButton *detailsButton;
@property (nonatomic, strong) UIButton *terminalButton;
@property (nonatomic, strong) UIView *detailLine;
@property (nonatomic, strong) UIView *terminalLine;
@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) UITableView *detailsTableView;

@end

@implementation DetailViewController

-(UITableView*) detailsTableView
{
    if(!_detailsTableView)
    {
        _detailsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _detailsTableView.translatesAutoresizingMaskIntoConstraints = NO;
//        _detailsTableView.backgroundColor = [UIColor redColor];
        _detailsTableView.delegate = self;
        _detailsTableView.dataSource = self;
        
        //        _detailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _detailsTableView;
}

- (UIView *)segmentHolderView
{
    if(!_segmentHolderView)
    {
        _segmentHolderView = [[UIView alloc] init];
        _segmentHolderView.backgroundColor = [UIColor whiteColor];//[ZCRMSharedThemeInstance ticketSegmentBgColor];
    }
    return _segmentHolderView;
}

-(UIView*) bottomLine
{
    if(!_bottomLine)
    {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
        _bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _bottomLine;
}

- (UIView *)ticketsMainView
{
    if(!_ticketsMainView)
    {
        _ticketsMainView = [[UIView alloc] init];
        _ticketsMainView.backgroundColor = [UIColor whiteColor];
    }
    return _ticketsMainView;
}

- (UIButton *)detailsButton
{
    if(!_detailsButton)
    {
        _detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_detailsButton setTitle:TICKET_DETAILS forState:UIControlStateNormal];
        [_detailsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_detailsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_detailsButton sizeToFit];
        [_detailsButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _detailsButton;
}

- (UIButton *)terminalButton
{
    if(!_terminalButton)
    {
        _terminalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_terminalButton setTitle:TERMINAL_TEXT forState:UIControlStateNormal];
        [_terminalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_terminalButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_terminalButton sizeToFit];
        [_terminalButton addTarget:self action:@selector(showTerminal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _terminalButton;
}

-(UIView*) detailLine
{
    if(!_detailLine)
    {
        _detailLine = [[UIView alloc] init];
        _detailLine.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLine.backgroundColor = [UIColor redColor];
    }
    return _detailLine;
}

-(UIView*) terminalLine
{
    if(!_terminalLine)
    {
        _terminalLine = [[UIView alloc] init];
        _terminalLine.translatesAutoresizingMaskIntoConstraints = NO;
        _terminalLine.backgroundColor = [UIColor redColor];
        _terminalLine.hidden =YES;
    }
    return _terminalLine;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNavigationBar];
    [self configureView];
    [self initializeValues];
    NSLog(@"connected PERIPHERAL: %@ (%@)", self.sensorTag, self.sensorTag.identifier.UUIDString);
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];

}

-(void)setNavigationBar
{
    self.navigationItem.title = @"Device Details";
}

-(void) configureView
{
    [self.view addSubview:self.segmentHolderView];
    [self.view addSubview:self.bottomLine];
    [self.view addSubview:self.ticketsMainView];
    self.segmentHolderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.ticketsMainView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentHolderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentHolderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentHolderView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentHolderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:64]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.segmentHolderView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLine attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.ticketsMainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bottomLine attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.ticketsMainView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.ticketsMainView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.ticketsMainView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self addSegmentViewComponents];
    [self addMainViewComponents];
}

-(void) addSegmentViewComponents
{
    [self.segmentHolderView addSubview:self.detailsButton];
    self.detailsButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.segmentHolderView addSubview:self.terminalButton];
    self.terminalButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *dummyView = [UIView new];
    dummyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.segmentHolderView addSubview:dummyView];
    dummyView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.segmentHolderView addSubview:self.detailLine];
    self.detailLine.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.segmentHolderView addSubview:self.terminalLine];
    self.terminalLine.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.segmentHolderView attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.segmentHolderView attribute:NSLayoutAttributeTop multiplier:1 constant:24]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.terminalButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.detailsButton attribute:NSLayoutAttributeRight multiplier:1 constant:50]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.terminalButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.segmentHolderView attribute:NSLayoutAttributeTop multiplier:1 constant:24]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLine attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.detailsButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-6]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLine attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.detailsButton attribute:NSLayoutAttributeRight multiplier:1 constant:6]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.segmentHolderView attribute:NSLayoutAttributeBottom multiplier:1 constant:-18]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:2]];
    
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.terminalLine attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.terminalButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-6]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.terminalLine attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.terminalButton attribute:NSLayoutAttributeRight multiplier:1 constant:6]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.terminalLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.segmentHolderView attribute:NSLayoutAttributeBottom multiplier:1 constant:-18]];
    
    [self.segmentHolderView addConstraint:[NSLayoutConstraint constraintWithItem:self.terminalLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:2]];
}

-(void) addMainViewComponents
{
    self.detailsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.ticketsMainView addSubview:self.detailsTableView];
    
    NSLayoutConstraint *aboutTableLeftConst = [NSLayoutConstraint constraintWithItem:self.detailsTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.ticketsMainView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *aboutTableRightConst = [NSLayoutConstraint constraintWithItem:self.detailsTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.ticketsMainView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *aboutTableTopConst = [NSLayoutConstraint constraintWithItem:self.detailsTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.ticketsMainView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *aboutTableBottomConst = [NSLayoutConstraint constraintWithItem:self.detailsTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.ticketsMainView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.ticketsMainView addConstraints:@[aboutTableLeftConst, aboutTableRightConst, aboutTableTopConst, aboutTableBottomConst ]];
}

- (void)showDetails:(id)sender
{
    if(self.sensorTag)
    {
        [self.detailLine setHidden:NO];
        [self.terminalLine setHidden:YES];
        [self.detailsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.terminalButton setTitleColor:[UIColor colorWithRed:136/255.0f green:136/255.0f blue:136/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
}

- (void)showTerminal:(id)sender
{
    NSLog(@"**** Show Terminal!!!");
    
    [self.detailLine setHidden:YES];
    [self.terminalLine setHidden:NO];
    [self.terminalButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.detailsButton setTitleColor:[UIColor colorWithRed:136/255.0f green:136/255.0f blue:136/255.0f alpha:1.0f] forState:UIControlStateNormal];
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
            [self connectSelectedDevice];
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

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"**** SUCCESSFULLY CONNECTED TO SENSOR TAG!!!");
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"**** CONNECTION FAILED!!!");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"**** DISCONNECTED FROM SENSOR TAG!!!");
}

-(void) connectSelectedDevice
{
    self.sensorTag.delegate = self;
    [self.sensorTag discoverServices:nil];
}

#pragma mark - CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services)
    {
        NSLog(@"Discovered service: %@", service);
        [servicesList addObject:service];
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
    [self.detailsTableView reloadData];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        [peripheral readValueForCharacteristic:characteristic];
        
//        uint8_t enableValue = 1;
//        NSData *enableBytes = [NSData dataWithBytes:&enableValue length:sizeof(uint8_t)];
//        [self.sensorTag writeValue:enableBytes forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        
        NSLog(@"Discovered characteristic: %@", characteristic);
        [characteristicList addObject:characteristic];
    }
    [self.detailsTableView reloadData];
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    } else {
        
        NSData *dataBytes = characteristic.value;
        NSLog(@"Updated characteristic Value: %@", dataBytes);
    }
}
-(void) initializeValues
{
//    [self loadInfoValues];
    [self loadServiceValues];
    [self loadCharacteristicValues];
    
    details = [[NSMutableArray alloc] init];
//    [details addObject:infoDict];
    [details addObject:self.sensorTag];
    [details addObject:servicesList];
    [details addObject:characteristicList];
}
//-(void)loadInfoValues
//{
//    infoDict = [[NSMutableDictionary alloc] init];
//
//    [infoDict setValue:self.sensorTag.identifier.UUIDString forKey:@"UUID"];
//    [infoDict setValue:self.sensorTag.name forKey:@"Name"];
//}

-(void)loadServiceValues
{
    servicesList = [[NSMutableArray alloc] init];
}

-(void)loadCharacteristicValues
{
    characteristicList =[[NSMutableArray alloc] init];
}


// MARK: Table View Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return details.count;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Info";
    }
    else if ((section == 1) && ([details[section] count] >0))
    {
        return @"Services";
    }
    else if ((section ==2) && ([details[section] count]))
    {
        return @"Characteristics";
    }
    else
    {
        return nil;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return [details[section] count];
    }
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
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.sensorTag.name;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"UUID";
            cell.detailTextLabel.text = self.sensorTag.identifier.UUIDString;
        }
    }
    else if (indexPath.section == 1)
    {
        CBService *service = (CBService*)servicesList[indexPath.row];
        cell.textLabel.text = service.UUID.UUIDString;
//        cell.detailTextLabel.text = self.sensorTag.name;
    }
    else if (indexPath.section == 2)
    {
        CBCharacteristic *character = (CBCharacteristic*)characteristicList[indexPath.row];
        cell.textLabel.text = character.UUID.UUIDString;
        //        cell.detailTextLabel.text = self.sensorTag.name;
    }
    
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.detailsTableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
