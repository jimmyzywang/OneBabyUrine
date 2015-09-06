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
  CBPeripheral* peripheral_;
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
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
  NSAssert([peripheral.name isEqualToString:kPeripheralName], @"PeripheralName error");
  NSLog(@"DISCOVERED: %@, %@, %@ db,state = %ld", peripheral, peripheral.name, RSSI,peripheral.state);
  if (peripheral.state == CBPeripheralStateDisconnected) {
      [central stopScan];
      peripheral_ = peripheral;
      peripheral_.delegate = self;
      [central connectPeripheral:peripheral_ options:nil];
  }
}

-(void)centralManager:(nonnull CBCentralManager *)central didConnectPeripheral:(nonnull CBPeripheral *)peripheral{
  NSLog(@"didConnectPeripheral");
  [peripheral discoverServices:nil];
}


-(void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
  NSLog(@"didDisconnectPeripheral");
}

-(void)centralManager:(nonnull CBCentralManager *)central willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict{
  
}

-(void)centralManager:(nonnull CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"didFailToConnectPeripheral");
}


-(void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
  NSLog(@"didDiscoverServices service count = %ld",peripheral.services.count);
  NSLog(@"peripheral.services = %@",peripheral.services);
  for (CBService* service in peripheral.services) {
    [peripheral discoverCharacteristics:nil forService:service];
  }
}

-(void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{
    NSLog(@"发现服务 %@, 特性数: %lu", service.UUID, [service.characteristics count]);
  
    for (CBCharacteristic *c in service.characteristics) {
      [peripheral readValueForCharacteristic:c];
      NSLog(@"特性值： UUID = %@ value = %@",c.UUID.UUIDString ,c.value);
    }
  
    NSLog(@"  ");
}

-(void)peripheral:(nonnull CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
  NSLog(@"didUpdateValueForCharacteristic 特性值： UUID = %@ value = %@",characteristic.UUID.UUIDString ,characteristic.value);
  NSString* hexString = [self p_hexadecimalString:characteristic.value];
  NSLog(@"hexString = %@",hexString);
}

-(NSString*)p_hexadecimalString:(NSData *)data{
  NSString* result;
  const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
  if(!dataBuffer){
    return nil;
  }
  NSUInteger dataLength = [data length];
  NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for(int i = 0; i < dataLength; i++){
    [hexString appendString:[NSString stringWithFormat:@"%lx", (unsigned long)dataBuffer[i]]];
  }
  result = [NSString stringWithString:hexString];
  return result; 
}




@end
