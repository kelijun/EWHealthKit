//
//  EWEquipmentInfo.h
//  EWBluetooth
//
//  Created by keli on 2021/6/15.
//  Copyright © 2021 keli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EWEquipmentInfo : NSObject
// Watt：是否支持Watt模式（0：为不支持1：支持）
@property (nonatomic, assign) BOOL isWatt;
// HRC：是否支持HRC模式（0：为不支持1：支持）
@property (nonatomic, assign) BOOL isHRC;
// 最大水平值
@property (nonatomic, assign) NSInteger levelMax;
// 最大坡度值
@property (nonatomic, assign) NSInteger inclineMax;
// 0：公制 1：英制
@property (nonatomic, assign) NSInteger KMMI;
// 最小速度
@property (nonatomic, assign) NSInteger speedMin;
// 最大速度
@property (nonatomic, assign) NSInteger speedMax;
// 最小坡度
@property (nonatomic, assign) NSInteger inclineMin;
// 机型代码
@end

NS_ASSUME_NONNULL_END
