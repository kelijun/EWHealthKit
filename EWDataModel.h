//
//  EWDataModel.h
//  EWBluetooth
//
//  Created by EWBluetooth on 2021/6/11.
//  Copyright © 2021 keli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EWSportState) {
    EWSportStateNone = 0, // 运动中
    EWSportStateLdle, // 待机
    EWSportStateSport, // 运动中
    EWSportStateSyscount321, // 倒计时
    EWSportStatePause, // 暂停
    EWSportStateStop, // 结束
    EWSportStateSleep, // 睡眠
};

@interface EWDataModel : NSObject
// 时间分钟
@property (nonatomic, assign) NSInteger timemin;
// 时间秒
@property (nonatomic, assign) NSInteger timesec;
// 距离
@property (nonatomic, assign) NSInteger distance;
// 卡路里
@property (nonatomic, assign) NSInteger calories;
// watt
@property (nonatomic, assign) NSInteger watt;
// 心率
@property (nonatomic, assign) NSInteger pulse;
// 速度
@property (nonatomic, assign) NSInteger speed;
// 坡度
@property (nonatomic, assign) NSInteger incline;
// 阻力
@property (nonatomic, assign) NSInteger level;
// 转速
@property (nonatomic, assign) NSInteger rpm;
// 步数
@property (nonatomic, assign) NSInteger pace;
// 水平
@property (nonatomic, assign) NSInteger highlighted;
// 划船次数
@property (nonatomic, assign) NSInteger strokes;
// 按键回值
@property (nonatomic, assign) NSInteger hardKey;
// 运动状态
@property (nonatomic, assign) EWSportState sportState;
@end

NS_ASSUME_NONNULL_END
