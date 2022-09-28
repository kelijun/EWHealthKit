//
//  EWCentralManager.h
//  EWBluetooth
//
//  Created by keli on 2021/6/7.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "EWDataModel.h"

NS_ASSUME_NONNULL_BEGIN
#define EWDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)
typedef NS_ENUM(NSInteger, EWManagerState) {
    EWManagerStateUnknown = 0,
    EWManagerStateResetting,
    EWManagerStateUnsupported,
    EWManagerStateUnauthorized,
    EWManagerStatePoweredOff,
    EWManagerStatePoweredOn,
};

typedef NS_ENUM(NSInteger, EWSportEquimentConnectionState) {
    /// 未连接
    EWSportEquimentConnectionStateDisconnected = 0,
    /// 连接中
    EWSportEquimentConnectionStateConnecting,
    /// 已连接
    EWSportEquimentConnectionStateConnected,
};

typedef NS_ENUM(NSInteger, EWWatchEquimentConnectionState) {
    /// 未连接
    EWWatchEquimentConnectionStateDisconnected = 0,
    /// 连接中
    EWWatchEquimentConnectionStateConnecting,
    /// 已连接
    EWWatchEquimentConnectionStateConnected,
};

typedef NS_ENUM(NSInteger, EWEquipmentType) {
    EWEquipmentTypeBike = 0, // 健身车
    EWEquipmentTypeTreadmill, // 跑步机
    EWEquipmentTypeEllipticalTrainer, // 椭圆机
    EWEquipmentTypeRower, // 划船机
};

typedef NS_ENUM(NSInteger, EWSportMode) {
    EWSportModeNormal = 0,// 正常模式
    EWSportModeProgram,// 程序模式
    EWSportModeCountDown,// 倒计模式
    EWSportModeHRC,// HRC
    EWSportModeUser,// user
    EWSportModeWatt,// watt
    EWSportModeRecovery,
    EWSportModeFat,// 跑步机模式
    EWSportModeIRoute,// 跑步机模式
};

typedef NS_ENUM(NSInteger, EWSportDataType) {
    EWSportDataTypeDistance = 0, // 距离
    EWSportDataTypeCalories, // 卡路里
    EWSportDataTypeTime, // 时间
    EWSportDataTypePulse, // 心率
    EWSportDataTypeIncline, // 扬升
    EWSportDataTypePace, // 步数
    EWSportDataTypeWatt, // 瓦特
    EWSportDataTypeLevel, // 阻力
    EWSportDataTypeSpeed, // 速度
};

@class EWUserInfoModel, EWEquipmentInfo;
@interface EWCentralManager : NSObject
/// 蓝牙状态
@property (nonatomic, assign, readonly) EWManagerState state;
/// 运动设备连接状态
@property (nonatomic, assign, readonly) EWSportEquimentConnectionState sportEquimentconnectionState;
/// 手表设备连接状态
@property (nonatomic, assign, readonly) EWWatchEquimentConnectionState watchEquimentConnectionState;
/// 是否正在扫描外围设备
@property (nonatomic, assign, readonly) BOOL isScanning;
/// 已经发现的设备列表
@property (nonatomic, strong, readonly) NSMutableArray *discoverPeripheralsList;
/// 已经连接的设备列表
@property (nonatomic, strong, readonly) NSMutableArray *connectedPeripheralsList;
/// 当前连接的外围设备
@property (nonatomic, strong, readonly) CBPeripheral *currentPeripheral;
/// 当前连接的手表设备
@property (nonatomic, strong, readonly) CBPeripheral *currentWatchPeripheral;

/// 设备信息模型
@property (nonatomic, strong, readonly) EWEquipmentInfo *equipmentInfo;
/// 运动状态
@property (nonatomic, assign, readonly) EWSportState sportState;
/// 运动数据
@property (nonatomic, strong, readonly) NSData *data;
/// 运动数据模型
@property (nonatomic, strong, readonly) EWDataModel *dataModel;
/// 运动数据更新
@property (nonatomic, copy) void(^didUpdateSportData)(NSData *data);
/// 运动数据模型更新
@property (nonatomic, copy) void(^didUpdateDataModel)(EWDataModel *dataModel);
/// 手表数据模型更新
@property (nonatomic, copy) void(^didUpdateWatchData)(NSData *data);



// 单例
+ (instancetype)sharedInstance;

#pragma mark - 蓝牙方法
/// 蓝牙状态发生变更
/// @param updateState 更新回调
- (void)ew_centralManagerDidUpdateState:(nullable void(^)(EWManagerState state))updateState;

/// 扫描外围设备，找到所需外围设备后请调用 ew_stopScanPeripherals 方法停止扫描以节省电力
- (void)ew_scanPeripherals;

/// 扫描指定前缀的外围设备，找到所需外围设备后请调用 ew_stopScanPeripherals 方法停止扫描以节省电力
/// @param hasPrefix 前缀
- (void)ew_scanPeripheralsForHasPrefix:(nullable NSString *)hasPrefix;

/// 停止扫描外围设备
- (void)ew_stopScanPeripherals;

/// 每发现一个设备都会调用该方法，返回一个外围设备数组，也可通过discoverPeripheralsList属性获取已经发现设备数组
/// @param completion 回调
- (void)ew_discoverPeripheralsCompletion:(nullable void(^)(NSMutableArray *peripheralsList))completion;

/// 连接外围设备
/// @param peripheral 外围设备
/// @param error 错误信息
- (void)ew_connectPeripheral:(CBPeripheral *)peripheral
                       error:(nullable void(^)(NSError *error))error EWDeprecated("请使用ew_connectSportPeripheral:completion:");

/// 取消当前连接外围设备
/// @param error 错误信息
- (void)ew_cancelCurrentPeripheralConnectionWithError:(nullable void(^)(NSError *error))error;

/// 连接运动设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_connectSportPeripheral:(CBPeripheral *)peripheral
                       completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion;
/// 取消连接运动设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_cancelSportPeripheralConnection:(CBPeripheral *)peripheral
                                completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion;

/// 取消连接外围设备
/// @param peripheral 外围设备
/// @param error 错误信息
- (void)ew_cancelPeripheralConnection:(CBPeripheral *)peripheral
                                error:(nullable void(^)(NSError *error))error EWDeprecated("请使用ew_cancelSportPeripheralConnection:completion:");

/// 取消连接所有外围设备
- (void)ew_cancelAllPeripheralConnection;

/// 每连接或者断开成功一个设备都会调用该方法，返回一个外围设备数组，也可通过connectedPeripheralsList属性获取连接成功设备数组
/// @param completion 回调
- (void)ew_connectedPeripheralsListUpdateCompletion:(nullable void(^)(NSMutableArray *peripheralsList))completion;


#pragma mark - 连接手表设备
/// 连接手表设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_connectWatchPeripheral:(CBPeripheral *)peripheral
                       completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion;

/// 取消连接手表设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_cancelWatchPeripheralConnection:(CBPeripheral *)peripheral
                                completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion;

#pragma mark - 运动配置
/// 配置用户基础信息，计算卡路里使用
/// @param userInfo 用户信息，默认年龄20，性别男，身高175，体重65
- (void)ew_configureUserInfo:(EWUserInfoModel *)userInfo;

/// 设置设备类型，请在连接蓝牙前调用
/// @param equipmentType 设备类型
- (void)ew_setupEquipmentType:(EWEquipmentType)equipmentType;


/// 获取设备信息
/// @param completion 回调
- (void)ew_getEquipmentInfoCompletion:(void (^)(EWEquipmentInfo *info))completion;

/// 设置运动模式，切换模式前调用
/// @param sportMode 运动模式
- (void)ew_setSportMode:(EWSportMode)sportMode;

/// 设置运动数据/下发运动数据
/// @param sportData 数据
/// @param dataType 数据类型
- (void)ew_setSportData:(NSInteger)sportData
     forEWSportDataType:(EWSportDataType)dataType;

/// 设置程序模式
/// @param timeset 时间
/// @param caloies 卡路里
/// @param distance 里程
/// @param type 类型
- (void)ew_setProgramforTimeset:(NSInteger)timeset
                     caloiesset:(NSInteger)caloies
                    distanceset:(NSInteger)distance
                      cptypeset:(NSInteger)type;

/// 设置跑步机程序模式
/// @param speed 速度
/// @param inceline 坡度
- (void)ew_setProgramforTimeset:(NSInteger)timeset
                       speedset:(int[_Nullable])speed
                       inceline:(int[_Nonnull])inceline;
#pragma mark - 运动控制
/// 开始运动
- (void)ew_startSport;
/// 暂停运动
- (void)ew_pauseSport;
/// 继续运动
- (void)ew_resumeSport;
/// 停止运动
- (void)ew_stopSport;

@end

NS_ASSUME_NONNULL_END
