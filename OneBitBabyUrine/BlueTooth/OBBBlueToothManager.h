//
//  OBBBlueToochManager.h
//  OneBitBabyUrine
//
//  Created by jimmyzywang-nb on 15/8/15.
//  Copyright (c) 2015年 com.tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBCentralManager.h>


@protocol OBBBlueToothManagerDelegate <NSObject>

-(void)OBBBlueToothManagerFailToRetriveConnectedPeripheral:(NSError*)error;
-(void)OBBBlueToothManagerDidSuccessRetriveConnectedPeripheral;

@end

typedef void (^OBBBlueToothStateCallback)(CBCentralManagerState state);

@interface OBBBlueToothManager : NSObject

-(void)ensurePhoneBlueToothState:(OBBBlueToothStateCallback)callback;

+(OBBBlueToothManager*)shareInstance;

-(void)beginToScanPeripheral;

-(NSArray*)retrivePeripheral;

@end
