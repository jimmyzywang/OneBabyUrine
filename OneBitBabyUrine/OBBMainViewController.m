//
//  OBBMainViewController.m
//  OneBitBabyUrine
//
//  Created by jimmyzywang-nb on 15/8/22.
//  Copyright © 2015年 com.tencent. All rights reserved.
//

#import "OBBMainViewController.h"
#import "OBBBlueToothManager.h"

@interface OBBMainViewController ()

@property (weak,nonatomic)IBOutlet UIButton* scanNewPeripheralButton;

-(IBAction)p_onScanNewPeripheralButton:(id)sender;

-(IBAction)p_onShowConnectedPeripheralButton:(id)sender;

@end

@implementation OBBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  [[OBBBlueToothManager shareInstance] ensurePhoneBlueToothState:^(CBCentralManagerState state) {
    switch (state) {
      case CBCentralManagerStatePoweredOn:{
        NSArray* connectedPeripherals = [[OBBBlueToothManager shareInstance] retrivePeripheral];
        if (![connectedPeripherals count]) {
          [[OBBBlueToothManager shareInstance] beginToScanPeripheral];
        }
        break;
      }
      case CBCentralManagerStatePoweredOff:{
        NSLog(@"state power off");
        break;
      }
      default:
        break;
    }
  }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)p_onScanNewPeripheralButton:(id)sender{
  [[OBBBlueToothManager shareInstance] beginToScanPeripheral];
}


-(IBAction)p_onShowConnectedPeripheralButton:(id)sender{
  NSArray* connectedPeripherals = [[OBBBlueToothManager shareInstance] retrivePeripheral];
  NSLog(@"connectedPeripherals = %@",connectedPeripherals);
}


@end
