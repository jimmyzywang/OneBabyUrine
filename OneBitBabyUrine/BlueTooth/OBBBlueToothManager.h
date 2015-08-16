//
//  OBBBlueToochManager.h
//  OneBitBabyUrine
//
//  Created by jimmyzywang-nb on 15/8/15.
//  Copyright (c) 2015年 com.tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBBBlueToothManager : NSObject

+(OBBBlueToothManager*)shareInstance;

-(void)beginToScanPeripheral;

@end
