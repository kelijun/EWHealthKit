//
//  EWUserInfoModel.h
//  EWBluetooth
//
//  Created by keli on 2021/6/14.
//  Copyright © 2021 keli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EWUserInfoModel : NSObject
// 用户 用户编码：U1~10=1~10
@property (nonatomic, assign) int user;
// 语言编码(1=中文；2=英文；3=法文；4=俄文；等等~)
@property (nonatomic, assign) int language;
// 年龄
@property (nonatomic, assign) int age;
// 性别 
@property (nonatomic, assign) int sex;
// 体重 kg
@property (nonatomic, assign) int weight;
// 身高 cm
@property (nonatomic, assign) int height;
@end

NS_ASSUME_NONNULL_END
