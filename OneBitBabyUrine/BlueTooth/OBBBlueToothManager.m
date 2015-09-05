//
//  OBBBlueToochManager.m
//  OneBitBabyUrine
//
//  Created by jimmyzywang-nb on 15/8/15.
//  Copyright (c) 2015年 com.tencent. All rights reserved.
//

#import "OBBBlueToothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "OBBConstants.h"

#define ENSURE_BLUETOOTH_ASSERT NSAssert(callback_,@"please invoke testPhoneBlueToothState first");

@interface OBBBlueToothManager() <CBCentralManagerDelegate,CBPeripheralDelegate>

@end

@implementation OBBBlueToothManager{
  CBCentralManager* centralManager_;
  dispatch_queue_t queue_;
  OBBBlueToothStateCallback callback_;
}

+(OBBBlueToothManager*)shareInstance{
  static dispatch_once_t pred;
  static OBBBlueToothManager* instance = nil;
  dispatch_once(&pred, ^{
    instance = [[OBBBlueToothManager alloc] init];
  });
  return instance;
}


-(void)ensurePhoneBlueToothState:(OBBBlueToothStateCallback)callback{
  callback_ = callback;
  [OBBBlueToothManager shareInstance];
}


-(instancetype)init{
  if (self = [super init]) {
    queue_ = dispatch_queue_create("com.oneBit.babyUrine", 0);
    centralManager_ = [[CBCentralManager alloc] initWithDelegate:self queue:queue_];
  }
  return self;
}

-(NSArray*)retrivePeripheral{
  ENSURE_BLUETOOTH_ASSERT
  CBUUID* serviceID = [CBUUID UUIDWithString:kPeripheralServiceUUID];
  return [centralManager_ retrieveConnectedPeripheralsWithServices:@[serviceID]];
}

-(void)beginToScanPeripheral{
  ENSURE_BLUETOOTH_ASSERT
  NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES ,CBCentralManagerOptionShowPowerAlertKey: @YES};
  CBUUID* serviceID = [CBUUID UUIDWithString:kPeripheralServiceUUID];
  [centralManager_ scanForPeripheralsWithServices:@[serviceID] options:options];
}

#pragma mark CBCentralManagerDelegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
  NSLog(@"centralManagerDidUpdateState state = %ld",(long)central.state);
  callback_(central.state);
  if (central.state == CBCentralManagerStatePoweredOn) {
    [central stopScan];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self beginToScanPeripheral];
    });
  }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
  NSAssert([peripheral.name isEqualToString:kPeripheralName], @"PeripheralName error");
  NSLog(@"DISCOVERED: %@, %@, %@ db", peripheral, peripheral.name, RSSI);
  if (peripheral.state == CBPeripheralStateDisconnected) {
      [central stopScan];
      peripheral.delegate = self;
      [central connectPeripheral:peripheral options:nil];
  }
}

-(void)centralManager:(nonnull CBCentralManager *)central didConnectPeripheral:(nonnull CBPeripheral *)peripheral{
  NSLog(@"didConnectPeripheral");
}


-(void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
  
}

-(void)centralManager:(nonnull CBCentralManager *)central willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict{
  
}

-(void)centralManager:(nonnull CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"didFailToConnectPeripheral");
}








@end
