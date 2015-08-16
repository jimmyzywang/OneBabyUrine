//
//  OBBBlueToochManager.m
//  OneBitBabyUrine
//
//  Created by jimmyzywang-nb on 15/8/15.
//  Copyright (c) 2015年 com.tencent. All rights reserved.
//

#import "OBBBlueToothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface OBBBlueToothManager() <CBCentralManagerDelegate>

@end

@implementation OBBBlueToothManager{
  CBCentralManager* centralManager_;
  dispatch_queue_t queue_;
}

+(OBBBlueToothManager*)shareInstance{
  dispatch_once_t pred;
  static OBBBlueToothManager* instance = nil;
  dispatch_once(&pred, ^{
    instance = [[OBBBlueToothManager alloc] init];
  });
  return instance;
}

-(instancetype)init{
  if (self = [super init]) {
    queue_ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    centralManager_ = [[CBCentralManager alloc] initWithDelegate:self queue:queue_];
  }
  return self;
}


-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
  
}

-(void)beginToScanPeripheral{
  NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
  [centralManager_ scanForPeripheralsWithServices:nil options:options];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
  if ([peripheral.name isEqualToString:@"OnlyBaby"] && peripheral.state == CBPeripheralStateDisconnected) {
    
    
  }
}




@end
