//
//  DetailViewController.h
//  BLE Terminal
//
//  Created by Ashutosh Roy on 11/08/19.
//  Copyright © 2019 Ashutosh Roy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DetailViewController : UIViewController

@property (nonatomic, strong) CBPeripheral *sensorTag;
@end

