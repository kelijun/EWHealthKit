//
//  EWBlock.h
//  EWBluetooth
//
//  Created by keli on 2021/6/22.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^EWConnectSportEquimentCompletion)(CBCentralManager *central, CBPeripheral *peripheral, NSError  *error);
typedef void (^EWcancelSportEquimentConnectionCompletion)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);
typedef void (^EWConnectWatchEquimentCompletion)(CBCentralManager *central, CBPeripheral *peripheral, NSError  *error);
typedef void (^EWcancelWatchEquimentConnectionCompletion)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);

@interface EWBlock : NSObject
/// 连接运动设备
@property (nonatomic, copy) EWConnectSportEquimentCompletion connectSportEquimentCompletion;
/// 取消连接运动设备
@property (nonatomic, copy) EWcancelSportEquimentConnectionCompletion cancelSportEquimentConnectionCompletion;
/// 连接手表
@property (nonatomic, copy) EWConnectWatchEquimentCompletion connectWatchEquimentCompletion;
/// 取消连接手表
@property (nonatomic, copy) EWcancelWatchEquimentConnectionCompletion cancelWatchEquimentConnectionCompletion;
@end


