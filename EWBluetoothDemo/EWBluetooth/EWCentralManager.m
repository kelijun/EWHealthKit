//
//  EWCentralManager.m
//  EWBluetooth
//
//  Created by keli on 2021/6/7.
//

#import "EWCentralManager.h"
#import "EWUserInfoModel.h"
#import "EWDataModel.h"
#import "EWEquipmentInfo.h"
#import "EWBlock.h"
#import "NSMutableData+Extensions.h"

// 打印
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"输出 >> %s >> %d行\n   %s\n",[[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] stringByDeletingPathExtension] UTF8String],__LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif
#define NSLogFunc NSLog(@"%s", __func__);
#define NSLogError(error) NSLog(@"Error: %@", error)

typedef NS_ENUM(NSInteger, UUIDType) {
    UUIDTypeServer = 0,
    UUIDTypeWrite,
    UUIDTypeRead,
};

static const Byte resistance_level[12][16]={
    {0x8,0x10,0x10,0x8,0x8,0x10,0x10,0x8,0x8,0x10,0x10,0x8,0x8,0x10,0x10,0x8},
    {0x4,0x4,0x8,0xc,0x10,0x4,0x4,0x8,0xc,0x10,0x4,0x4,0x8,0xc,0x10,0x4},
    {0x4,0x10,0xc,0x8,0x4,0x4,0x10,0xc,0x8,0x4,0x4,0x10,0xc,0x8,0x4,0x4},
    {0x2,0x4,0x6,0x8,0xa,0xc,0xe,0x10,0x12,0x10,0xe,0xc,0xa,0x8,0x6,0x4},
    {0x2,0x4,0x4,0x6,0x6,0x8,0x8,0xa,0xa,0xc,0xc,0xe,0xe,0x10,0x10,0x12},
    {0x4,0x4,0x8,0xe,0x12,0xe,0x8,0x4,0x4,0x8,0xe,0x12,0xe,0x8,0x4,0x4},
    {0x4,0x8,0x8,0xe,0xe,0x12,0x12,0x12,0x12,0x12,0x12,0xe,0xe,0x8,0x8,0x4},
    {0x4,0x12,0x8,0x4,0x4,0x12,0x8,0x4,0x4,0x12,0x8,0x4,0x4,0x12,0x8,0x4},
    {0x4,0x4,0x8,0x8,0x8,0x8,0xe,0xe,0xe,0xe,0x12,0x12,0x12,0x12,0xe,0xe},
    {0x2,0x6,0xe,0xe,0x10,0x14,0x12,0x10,0x10,0x12,0x14,0x12,0x10,0x10,0x6,0x2},
    {0x8,0x14,0x8,0x12,0x8,0x14,0x8,0x12,0x8,0x14,0x8,0x12,0x8,0x14,0x8,0x12},
    {0x2,0x2,0x14,0x2,0x2,0x14,0x2,0x2,0x14,0x2,0x2,0x14,0x2,0x2,0x14}
};

int SPEEDS_1_20[12][20]={
    {2,3,3,4,5,3,4,5,5,3,4,5,4,4,4,2,3,3,5,3},
    {2,4,4,5,6,4,6,6,6,4,5,6,4,4,4,2,2,5,4,1},
    {2,4,4,6,6,4,7,7,7,4,7,7,4,4,4,2,4,5,3,2},
    {3,5,5,6,7,7,5,7,7,8,8,5,9,5,5,6,6,4,4,3},
    {2,4,4,5,6,7,7,5,6,7,8,8,5,4,3,3,6,5,4,2},
    {2,4,3,4,5,4,8,7,6,7,8,3,6,4,4,2,5,4,3,2},
    {2,3,3,3,4,5,3,4,5,3,4,5,3,3,3,6,6,5,3,3},
    {2,3,3,6,7,7,4,6,7,4,6,7,4,4,4,2,3,4,4,2},
    {2,4,4,7,7,4,7,8,4,8,9,9,4,4,4,5,6,3,3,2},
    {2,4,5,6,7,5,4,6,8,8,6,6,5,4,4,2,4,4,3,3},
    {3,4,5,9,5,9,5,5,5,9,5,5,5,5,9,9,8,7,6,3},
    {2,5,8,10,7,7,10,10,7,7,10,10,6,6,9,9,5,5,4,3}};


int INCLINES1_20[12][20]={
    {0,7,7,6,6,5,5,4,4,3,3,2,2,2,2,2,2,3,3,4},
    {0,3,3,5,5,7,7,9,9,7,7,5,5,3,3,3,3,5,5,7},
    {0,5,5,5,12,12,5,5,5,12,12,5,5,5,12,12,5,5,5,12},
    {0,2,3,4,5,6,7,7,6,5,4,3,2,1,1,2,3,4,5,6},
    {0,2,3,4,5,6,7,7,6,5,4,3,2,1,1,2,3,4,5,6},
    {0,2,3,4,5,6,7,7,6,5,4,3,2,1,1,2,3,4,5,6},
    {2,3,4,5,6,7,8,9,9,9,9,9,8,7,6,5,4,3,2,2},
    {0,3,3,5,5,7,7,9,9,7,7,5,5,3,3,3,3,5,5,7},
    {0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    {9,8,7,6,5,4,3,3,4,5,6,7,8,9,9,8,7,6,5,4},
    {9,8,7,6,5,4,3,3,4,5,6,7,8,9,9,8,7,6,5,4},
    {2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4}};

@interface EWCentralManager () <CBCentralManagerDelegate,CBPeripheralDelegate> {
    int customeSpeeds[20],customeinclines[20];
}
// 私有属性
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *currentPeripheral;
@property (nonatomic, strong) CBPeripheral *currentWatchPeripheral;
@property (nonatomic, strong) CBPeripheral *tempWatchPeripheral;
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBCharacteristic *readCharacteristic;
@property (nonatomic, strong) EWBlock *block;
@property (nonatomic, assign) NSInteger command; //收到的命令
@property (nonatomic, assign) NSInteger sendKey; //发送的命令
@property (nonatomic, assign) int speedSign;// 速度数据标志
@property (nonatomic, assign) int inclineSign;// 速度数据标志
@property (nonatomic, assign) BOOL isWriteValue;
@property (nonatomic, assign) BOOL isWriteProg; //程序模式是否可以写入
@property (nonatomic, assign) EWSportMode sportMode;
@property (nonatomic, assign) EWSportState sportState;
@property (nonatomic, assign) EWEquipmentType equipmentType;
@property (nonatomic, strong) EWUserInfoModel *userInfo;
@property (nonatomic, strong) EWEquipmentInfo *equipmentInfo;
// 设置数据类型
@property (nonatomic, assign) NSInteger distanceset;
@property (nonatomic, assign) NSInteger caloriesset;
@property (nonatomic, assign) NSInteger timeset;
@property (nonatomic, assign) NSInteger speedset;
@property (nonatomic, assign) NSInteger pulseset;
@property (nonatomic, assign) NSInteger paceset;
@property (nonatomic, assign) NSInteger wattset;
@property (nonatomic, assign) NSInteger inclineset;
@property (nonatomic, assign) NSInteger levelset;
@property (nonatomic, assign) NSInteger cf_p;
@property (nonatomic, assign) NSInteger programNum; // 第几个程序
@property (nonatomic, assign) NSInteger R_HORLdata;



@property(nonatomic,assign)NSInteger totalTime;
@property(nonatomic,assign)NSInteger totalDist;

@property(nonatomic,retain)NSMutableString *speeddata;
@property(nonatomic,retain)NSMutableString *inclinedata;
@property(nonatomic,assign)NSInteger updata_num;
@property(nonatomic,assign)NSInteger hex_length;

@property(nonatomic,assign)NSInteger sendKeyTimes;
@property(nonatomic,assign)NSInteger Addr_Send;
@property(nonatomic,assign)BOOL sendenable;
@property(nonatomic,assign)BOOL updataEnd;
@property(nonatomic,assign)BOOL pageEnd;

// 公共属性
@property (nonatomic, assign) EWManagerState state;
@property (nonatomic, assign) EWSportEquimentConnectionState sportEquimentconnectionState;
@property (nonatomic, assign) EWWatchEquimentConnectionState watchEquimentConnectionState;
@property (nonatomic, assign) BOOL isCanScanning;
@property (nonatomic, strong) NSMutableArray *discoverPeripheralsList;
@property (nonatomic, strong) NSMutableArray *connectedPeripheralsList;
@property (nonatomic, strong) NSString *hasPrefix;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) EWDataModel *dataModel;

@property (nonatomic, copy) void(^connectFailureError)(NSError *error);
@property (nonatomic, copy) void(^disconnectFailureError)(NSError *error);
@property (nonatomic, copy) void(^updateStateBlock)(EWManagerState state);
@property (nonatomic, copy) void(^listUpdateCompletion)(NSMutableArray *list);
@property (nonatomic, copy) void(^getEWEquipmentInfoBlock)(EWEquipmentInfo *equipmentInfo);
@end

@implementation EWCentralManager

+ (instancetype)sharedInstance {
    static EWCentralManager *centralManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        centralManager = [[self alloc] init];
        centralManager.block = [[EWBlock alloc] init];
    });
    return centralManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{@"CBCentralManagerOptionShowPowerAlertKey":[NSNumber numberWithBool:YES]}];
        
        _userInfo = [[EWUserInfoModel alloc] init];
        _discoverPeripheralsList = [NSMutableArray array];
        _connectedPeripheralsList = [NSMutableArray array];
        [self resetBaseData];
    }
    return self;
}

#pragma mark - CBCenralManagerDelegate
// 蓝牙状态更新
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"蓝牙状态：未知");
            break;
        case CBManagerStateResetting:
            NSLog(@"蓝牙状态：正在重置");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"蓝牙状态：不支持");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"蓝牙状态：未授权");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"蓝牙状态：关闭");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"蓝牙状态：打开");
            self.isCanScanning = YES;
            break;
        default:
            break;
    }
    if (central.state != CBManagerStatePoweredOn) {
        [self resetBaseData];
        self.isCanScanning = NO;
        [self.discoverPeripheralsList removeAllObjects];
        [self.connectedPeripheralsList removeAllObjects];
    }
    if (self.isCanScanning && central.state == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
    }
    self.state = (EWManagerState)central.state;
    if (self.updateStateBlock) {
        self.updateStateBlock((EWManagerState)self.state);
    }
}

// 发现外围设备
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    if (peripheral.name) {
        if ([self.discoverPeripheralsList containsObject:peripheral]) {
            return;
        }
        // 判断过滤
        NSString *lowercaseName = [peripheral.name lowercaseString];
        if (self.hasPrefix) {
            if ([lowercaseName hasPrefix:[self.hasPrefix lowercaseString]]) {
                [self addDiscoverPeripheralsList:peripheral];
            }
        } else {
            [self addDiscoverPeripheralsList:peripheral];
        }
    }
}

// 外围设备连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (self.tempWatchPeripheral == peripheral) { // 手表连接成功
        self.watchEquimentConnectionState = EWWatchEquimentConnectionStateConnected;
        peripheral.delegate = self;
        [peripheral discoverServices:nil];
        self.currentWatchPeripheral = peripheral;
        if (self.block.connectWatchEquimentCompletion) {
            self.block.connectWatchEquimentCompletion(central, peripheral, nil);
        }
    } else {
        if ([self.connectedPeripheralsList containsObject:peripheral]) {
            return;
        }
        self.sportEquimentconnectionState = EWSportEquimentConnectionStateConnected;
        peripheral.delegate = self;
        [peripheral discoverServices:nil];
        // 添加到列表
        [self.connectedPeripheralsList addObject:peripheral];
        if (self.listUpdateCompletion) {
            self.listUpdateCompletion(self.connectedPeripheralsList);
        }
        if (self.block.connectSportEquimentCompletion) {
            self.block.connectSportEquimentCompletion(central, peripheral, nil);
        }
        self.currentPeripheral = peripheral;
    }
    NSLog(@"%@ 连接成功",peripheral.name);
}
// 外围设备连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@ 连接失败，错误信息：%@",peripheral.name,error);
    if (self.tempWatchPeripheral == peripheral) {
        self.watchEquimentConnectionState = EWWatchEquimentConnectionStateDisconnected;
        if (self.block.connectWatchEquimentCompletion) {
            self.block.connectWatchEquimentCompletion(central, peripheral, error);
        }
    } else {
        self.sportEquimentconnectionState = EWSportEquimentConnectionStateDisconnected;
        if (self.connectFailureError) {
            self.connectFailureError(error);
        }
        if (self.block.connectSportEquimentCompletion) {
            self.block.connectSportEquimentCompletion(central, peripheral, error);
        }
    }
}
// 取消连接外围设备
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.currentWatchPeripheral == peripheral) {
        if (error) {
            NSLog(@"%@ 取消连接失败，错误信息：%@",peripheral.name,error);
        } else {
            NSLog(@"%@ 取消连接成功",peripheral.name);
            [self resetWatchBaseData];
        }
        if (self.block.cancelWatchEquimentConnectionCompletion) {
            self.block.cancelWatchEquimentConnectionCompletion(central, peripheral, error);
        }
    } else {
        if (error) {
            NSLog(@"%@ 取消连接失败，错误信息：%@",peripheral.name,error);
            if (self.disconnectFailureError) {
                self.disconnectFailureError(error);
            }
        } else {
            NSLog(@"%@ 取消连接成功",peripheral.name);
            [self resetBaseData];
            [self.connectedPeripheralsList removeObject:peripheral];
            if (self.listUpdateCompletion) {
                self.listUpdateCompletion(self.connectedPeripheralsList);
            }
        }
        if (self.block.cancelSportEquimentConnectionCompletion) {
            self.block.cancelSportEquimentConnectionCompletion(central, peripheral, error);
        }
    }
}

#pragma mark - CBPeripheralDelegate
// 外围服务发现成功
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"外围服务发现成功");
    for (CBService *service in peripheral.services) {
        NSLog(@"%@ 服务 %@",peripheral.name,service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
// 外围设备为服务找到了特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"外围设备为服务找到了特征");
    if (self.currentWatchPeripheral == peripheral) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
        }
    } else {
        if ([service.UUID isEqual:[self getUUIDWithUUIDType:UUIDTypeServer]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                // 写
                if ([characteristic.UUID isEqual:[self getUUIDWithUUIDType:UUIDTypeWrite]]) {
                    self.writeCharacteristic = characteristic;
                } else if ([characteristic.UUID isEqual:[self getUUIDWithUUIDType:UUIDTypeRead]]) { // 读
                    self.readCharacteristic = characteristic;
                }
            }
            for (CBCharacteristic *characteristic in service.characteristics) {
                [peripheral discoverDescriptorsForCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID isEqual:[self getUUIDWithUUIDType:UUIDTypeWrite]]) {
        if (!self.currentPeripheral) {
            return;
        }
        [peripheral readValueForCharacteristic:characteristic];
        [self sendCommand:self.command];
    } else if ([characteristic.UUID isEqual:[self getUUIDWithUUIDType:UUIDTypeRead]]) { // 读
        
    } else if (self.currentWatchPeripheral == peripheral) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}
// 检索指定特征的值成功，或特征的值发生了变化
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        
    } else {
        NSLog(@"%@",error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (!error) {
        if ([characteristic.UUID isEqual:[self getUUIDWithUUIDType:UUIDTypeRead]]) {
            if ([characteristic.value length] == 0) {
                return;
            }
            if (self.equipmentType == EWEquipmentTypeTreadmill) {
                [self readTreadmillDataWithData:characteristic.value];
            } else {
                [self readBikeDataWithData:characteristic.value];
            }
        }
    } else {
        NSLog(@"%@",error);
    }
}
#pragma mark - 公共属性
- (BOOL)isScanning {
    return self.centralManager.isScanning;
}

#pragma mark - 公共方法
/// 蓝牙状态发生变更
/// @param updateState 更新回调
- (void)ew_centralManagerDidUpdateState:(void (^)(EWManagerState))updateState {
    self.updateStateBlock = updateState;
}

/// 扫描外围设备，找到所需外围设备后请调用 ew_stopScanPeripherals 方法停止扫描以节省电力
- (void)ew_scanPeripherals {
    self.hasPrefix = nil;
    self.isCanScanning = YES;
    [self.discoverPeripheralsList removeAllObjects];
    [self.connectedPeripheralsList removeAllObjects];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
}

/// 扫描指定前缀的外围设备
/// @param hasPrefix 前缀
- (void)ew_scanPeripheralsForHasPrefix:(nullable NSString *)hasPrefix {
    self.hasPrefix = hasPrefix;
    self.isCanScanning = YES;
    [self.discoverPeripheralsList removeAllObjects];
    [self.connectedPeripheralsList removeAllObjects];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
}

/// 停止扫描外围设备
- (void)ew_stopScanPeripherals {
    self.isCanScanning = NO;
    [self.centralManager stopScan];
}

/// 每发现一个设备都会调用该方法，返回一个外围设备数组，也可通过discoverPeripheralsList属性获取已经发现设备数组
/// @param completion 回调
- (void)ew_discoverPeripheralsCompletion:(void (^)(NSMutableArray * _Nonnull))completion {
    self.listUpdateCompletion = completion;
}

/// 连接运动设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_connectSportPeripheral:(CBPeripheral *)peripheral
                       completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion {
    self.block.connectSportEquimentCompletion = completion;
    self.sportEquimentconnectionState = EWSportEquimentConnectionStateConnecting;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

/// 取消连接运动设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_cancelSportPeripheralConnection:(CBPeripheral *)peripheral
                                completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion {
    self.block.cancelSportEquimentConnectionCompletion = completion;
    [self.centralManager cancelPeripheralConnection:peripheral];
}

/// 连接外围设备
/// @param peripheral 外围设备
/// @param error 错误信息
- (void)ew_connectPeripheral:(CBPeripheral *)peripheral
                       error:(nullable void (^)(NSError * _Nonnull))error {
    self.connectFailureError = error;
    self.sportEquimentconnectionState = EWSportEquimentConnectionStateConnecting;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

/// 取消当前连接外围设备
/// @param error 错误信息
- (void)ew_cancelCurrentPeripheralConnectionWithError:(nullable void(^)(NSError *error))error {
    self.disconnectFailureError = error;
    if (self.currentPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
    }
}

/// 取消连接外围设备
/// @param peripheral 外围设备
/// @param error 错误信息
- (void)ew_cancelPeripheralConnection:(CBPeripheral *)peripheral
                                error:(nullable void (^)(NSError * _Nonnull))error {
    self.disconnectFailureError = error;
    [self.centralManager cancelPeripheralConnection:peripheral];
}

/// 取消连接所有外围设备
- (void)ew_cancelAllPeripheralConnection {
    for (CBPeripheral *peripheral in self.connectedPeripheralsList) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

/// 每连接或者断开成功一个设备都会调用该方法，返回一个外围设备数组，也可通过connectedPeripheralsList属性获取连接成功设备数组
/// @param completion 回调
- (void)ew_connectedPeripheralsListUpdateCompletion:(nullable void(^)(NSMutableArray *peripheralsList))completion {
    self.listUpdateCompletion = completion;
}

#pragma mark - 连接手表设备
/// 连接手表设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_connectWatchPeripheral:(CBPeripheral *)peripheral
                       completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion {
    self.tempWatchPeripheral = peripheral;
    self.block.connectWatchEquimentCompletion = completion;
    [self.centralManager connectPeripheral:peripheral options:nil];
}
/// 取消连接手表设备
/// @param peripheral 外围设备
/// @param completion 回调
- (void)ew_cancelWatchPeripheralConnection:(CBPeripheral *)peripheral
                                completion:(nullable void(^)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error))completion {
    self.block.cancelWatchEquimentConnectionCompletion = completion;
    [self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - 运动控制
/// 配置用户基础信息，计算卡路里使用
/// @param userInfo 用户信息，默认年龄20，性别男，身高175，体重65
- (void)ew_configureUserInfo:(EWUserInfoModel *)userInfo {
    self.userInfo = userInfo;
}

/// 设置设备类型，请在连接蓝牙前调用
/// @param equipmentType 设备类型
- (void)ew_setupEquipmentType:(EWEquipmentType)equipmentType {
    self.dataModel = [[EWDataModel alloc] init];
    self.equipmentInfo = [[EWEquipmentInfo alloc] init];
    self.equipmentType = equipmentType;
}

/// 开始运动
- (void)ew_startSport {
    if (self.equipmentType == EWEquipmentTypeTreadmill) {
        self.sendKey = 1;
        self.command = 4;
        [self sendCommand:4];
    } else {
        self.sendKey = 1;
        [self sendCommand:3];
    }
}
/// 暂停运动
- (void)ew_pauseSport {
    if (self.equipmentType == EWEquipmentTypeTreadmill) {
        self.sendKey = 4;
        [self sendCommand:3];
    } else {
        self.sendKey = 2;
        [self sendCommand:3];
    }
}
/// 继续运动
- (void)ew_resumeSport {
    if (self.equipmentType == EWEquipmentTypeTreadmill) {
        self.sendKey = 1;
        [self sendCommand:3];
    } else {
        self.sendKey = 1;
        [self sendCommand:3];
    }
}
/// 停止运动
- (void)ew_stopSport {
    if (self.equipmentType == EWEquipmentTypeTreadmill) {
        self.sendKey = 2;
    } else {
        self.sendKey = 2;
        self.command = 4;
    }
    // 停止运动重置基础数据
    [self resetSportData];
}

/// 获取设备信息
/// @param completion 回调
- (void)ew_getEquipmentInfoCompletion:(void (^)(EWEquipmentInfo *info))completion {
    self.getEWEquipmentInfoBlock = completion;
    self.command = 1;
    [self sendCommand:1];
}
/// 设置运动模式，切换模式前调用
/// @param sportMode 运动模式
- (void)ew_setSportMode:(EWSportMode)sportMode {
    [self resetSportData];
    self.sportMode = sportMode;
}
/// 设置运动数据/下发运动数据
/// @param sportData 数据
/// @param dataType 数据类型
- (void)ew_setSportData:(NSInteger)sportData forEWSportDataType:(EWSportDataType)dataType {
    switch (dataType) {
        case EWSportDataTypeDistance:
            self.distanceset = sportData * 100;
            break;
        case EWSportDataTypeCalories:
            self.caloriesset = sportData;
            break;
        case EWSportDataTypeTime:
            self.timeset = sportData;
            break;
        case EWSportDataTypePulse:
            self.pulseset = sportData;
            break;
        case EWSportDataTypeIncline:
            self.inclineset = sportData;
            break;
        case EWSportDataTypePace:
            self.paceset = sportData;
            break;
        case EWSportDataTypeWatt:
            self.wattset = sportData;
            break;
        case EWSportDataTypeLevel:
            self.levelset = sportData;
            break;
        case EWSportDataTypeSpeed:
            self.speedset = sportData;
            break;
        default:
            break;
    }
    
    if (self.equipmentType == EWEquipmentTypeTreadmill) {
        self.sendKey = 3;
    } else {
        self.sendKey = 4;
    }
}

/// 设置程序模式
/// @param timeset 时间
/// @param caloies 卡路里
/// @param distance 里程
/// @param type 类型
- (void)ew_setProgramforTimeset:(NSInteger)timeset
                     caloiesset:(NSInteger)caloies
                    distanceset:(NSInteger)distance
                      cptypeset:(NSInteger)type {
    self.timeset = timeset;
    self.caloriesset = caloies;
    self.distanceset = distance;
    self.cf_p = type;
    self.sportMode = EWSportModeProgram;
    self.command = 4;
    self.sendKey = 1;
    [self sendCommand:4];
}

/// 设置跑步机程序模式
/// @param speed 速度
/// @param inceline 坡度
- (void)ew_setProgramforTimeset:(NSInteger)timeset
                       speedset:(int [])speed
                       inceline:(int [])inceline {
    for (NSInteger i = 0; i < 20; i ++) {
        customeSpeeds[i] = speed[i];
        customeinclines[i] = inceline[i];
    }
    self.sportMode = EWSportModeProgram;
    self.timeset = timeset;
    self.speedSign = 0x01;
    self.inclineSign = 0x01;
    self.command = 8;
}


#pragma mark - 私有方法
// 添加数组
- (void)addDiscoverPeripheralsList:(CBPeripheral *)peripheral {
    [self.discoverPeripheralsList addObject:peripheral];
    if (self.listUpdateCompletion) {
        self.listUpdateCompletion(self.discoverPeripheralsList);
    }
}

/// 获取UUID
/// @param type UUID类型
- (CBUUID *)getUUIDWithUUIDType:(UUIDType)type {
    NSString *uuidStr = @"";
    switch (self.equipmentType) {
        case EWEquipmentTypeBike: {
            if (type == UUIDTypeServer) {
                uuidStr = @"FFF0";
            } else if (type == UUIDTypeWrite) {
                uuidStr = @"FFF2";
            } else if (type == UUIDTypeRead) {
                uuidStr = @"FFF1";
            }
        }
            break;
        case EWEquipmentTypeTreadmill: {
            if (type == UUIDTypeServer) {
                uuidStr = @"FFF0";
            } else if (type == UUIDTypeWrite) {
                uuidStr = @"FFF2";
            } else if (type == UUIDTypeRead) {
                uuidStr = @"FFF1";
            }
        }
            break;
        case EWEquipmentTypeEllipticalTrainer: {
            if (type == UUIDTypeServer) {
                uuidStr = @"FFF0";
            } else if (type == UUIDTypeWrite) {
                uuidStr = @"FFF2";
            } else if (type == UUIDTypeRead) {
                uuidStr = @"FFF1";
            }
        }
            break;
        case EWEquipmentTypeRower: {
            if (type == UUIDTypeServer) {
                uuidStr = @"FFA0";
            } else if (type == UUIDTypeWrite) {
                uuidStr = @"FFF2";
            } else if (type == UUIDTypeRead) {
                uuidStr = @"FFF1";
            }
        }
            break;
        default:
            break;
    }
    return [CBUUID UUIDWithString:uuidStr];
}


/// 发送命令
/// @param command 命令
//- (void)sendCommand:(NSInteger)command {
//    if (self.equipmentType == EWEquipmentTypeTreadmill) {
//        [self setTredmillWriteValueBytes:command];
//    } else {
//        [self setBikeWriteValueBytes:command];
//    }
//    NSLog(@"发送命令 %ld--%ld",command,self.command);
//    NSLog(@"发送指令 %ld",self.sendKey);
//}

- (void)sendCommand2:(NSString *)command {
    if (self.equipmentType == EWEquipmentTypeTreadmill) {
        [self setTredmillWriteValueBytes:[command integerValue]];
    } else {
        [self setBikeWriteValueBytes:[command integerValue]];
    }
    NSLog(@"发送命令 %@--%ld",command,self.command);
    NSLog(@"发送指令 %ld",self.sendKey);
}

- (void)sendCommand:(NSInteger)command {
    [self performSelector:@selector(sendCommand2:) withObject:[NSString stringWithFormat:@"%ld",command] afterDelay:0.3];
}

/// 设置单车写入的数据
/// @param command 命令
- (void)setBikeWriteValueBytes:(NSInteger)command {
    switch (command) {
        case 0: {
            Byte byte[4] = {0xF2,0xC0,0x00,0xB2};
            [self writeValueBytes:byte length:4];
        }
            break;
        case 1: {
            Byte byte[9] = {0xf2,0xc1,0x05,0x01,0x00,0x00,0x00,0x00};
            byte[8] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:9];
        }
            break;
        case 2: {
            if (self.writeCharacteristic) {
                // 写入用户数据
                Byte byte[17] = {0xf2,0xc2,0x0d};
                byte[3] = [self intTobyte:1];// 0读 1写
                byte[4] = [self intTobyte:0];// 用户
                byte[5] = [self intTobyte:1];// 中文
                byte[6] = [self intTobyte:self.userInfo.age?:20];// 年龄
                byte[7] = [self intTobyte:self.userInfo.sex?:1];// 性别
                byte[8] = [self intTobyte:self.userInfo.weight?:65];// 体重
                byte[9] = [self intTobyte:self.userInfo.weight?:65];
                byte[10] = [self intTobyte:self.userInfo.height?:175];//身高
                byte[11] = [self intTobyte:self.userInfo.height?:175];
                byte[16] = [self checkoutsum:byte];
                [self writeValueBytes:byte length:17];
            } else {
                Byte byte[5] = {0xf2,0xc2,[self intTobyte:1],[self intTobyte:0]};
                byte[4] = [self checkoutsum:byte];
                [self writeValueBytes:byte length:5];
            }
        }
            break;
        case 3: {
            Byte byte[11] = {0xf2,0xc3,[self intTobyte:7],[self intTobyte:(int)self.sendKey],[self intTobyte:(int)self.levelset],[self intTobyte:(int)self.wattset / 256],[self intTobyte:(int)self.wattset % 256]};
            byte[10] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:11];
            
            if (self.sendKey == 2) {
                self.sendKey = 0;
            }
        }
            break;
        case 4: {
            Byte byte[17] = {0xf2};
            byte[1] = 0xc4;
            byte[2] = 0x0d;
            byte[3] = [self intTobyte:(int)self.sportMode];
            byte[4] = [self intTobyte:(int)self.timeset];
            byte[5] = [self intTobyte:(int)self.distanceset / 256];
            byte[6] = [self intTobyte:(int)self.distanceset % 256];
            byte[7] = [self intTobyte:(int)self.caloriesset / 256];
            byte[8] = [self intTobyte:(int)self.caloriesset % 256];
            byte[9] = [self intTobyte:(int)self.wattset / 256];
            byte[10] = [self intTobyte:(int)self.wattset % 256];
            byte[11] = [self intTobyte:(int)self.pulseset];
            if (self.sportMode == EWSportModeProgram) {
                byte[13] = [self intTobyte:(int)self.cf_p];
            }
            byte[16] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:17];
        }
            break;
        case 5: {
            Byte byte[18];
            byte[0] = 0xf2;
            byte[1] = 0xc5;
            byte[2] = 0x0e;
            if (self.isWriteProg) { // 是否写入
                byte[3] = 0x1;
            } else {
                byte[3] = 0x00;
            }
            byte[4] = [self intTobyte:(int)self.cf_p];
            if (self.programNum == 0x10) {
                byte[5] = 0x20;
                byte[6] = [self intTobyte:2];
                for (int j = 0; j < 10; j ++) {
                    byte[j + 7] = resistance_level[self.cf_p - 1][j];
                }
            } else if (self.programNum == 0x20) {
                if (self.R_HORLdata == 1) {
                    byte[5] = 0x20;
                    byte[6] = [self intTobyte:2];
                    for (int j = 0; j < 10; j ++) {
                        byte[j + 7] = resistance_level[self.cf_p-1][j];
                    }
                } else if (self.R_HORLdata == 2) {
                    byte[5] = 0x21;
                    byte[6] = [self intTobyte:2];
                    for (int j = 0; j < 6; j ++) {
                        byte[j+7] = resistance_level[self.cf_p-1][j+10];
                    }
                }
            }
            byte[17] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:18];
        }
            break;
        case 6: {
            Byte byte[4];
            byte[0] = 0xf0;
            byte[1] = 0xc6;
            byte[2] = 0x0;
            byte[3] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:18];
        }
            break;
        case 7: {
            Byte byte[4];
            byte[0] = 0xf2;
            byte[1] = 0xc7;
            byte[2] = 0x0;
            byte[3] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:4];
        }
        default:
            break;
    }
}

/// 设置跑步机写入的数据
/// @param command 命令
- (void)setTredmillWriteValueBytes:(NSInteger)command {
    switch (command) {
        case 0: {
            Byte byte[4] = {0xF0,0xC0,0x00};
            byte[3] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:4];
        }
            break;
        case 1: {
            Byte byte[6];
            byte[0] = 0xF0;
            byte[1] = 0xC1;
            byte[2] = [self intTobyte:2];
            byte[3] = 0x00;// 0普通模式 1运动模式
            byte[4] = 0x00;// 0公制 1英制
            byte[5] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:6];
        }
            break;
        case 2: {
            if (self.writeCharacteristic) {
                // 写入用户数据
                Byte byte[17] = {0xf2,0xc2,0x0d};
                byte[3] = [self intTobyte:1];// 0读 1写
                byte[4] = [self intTobyte:0];// 用户
                byte[5] = [self intTobyte:1];// 中文
                byte[6] = [self intTobyte:self.userInfo.age?:20];// 年龄
                byte[7] = [self intTobyte:self.userInfo.sex?:1];// 性别
                byte[8] = [self intTobyte:self.userInfo.weight?:65];// 体重
                byte[9] = [self intTobyte:self.userInfo.weight?:65];
                byte[10] = [self intTobyte:self.userInfo.height?:175];//身高
                byte[11] = [self intTobyte:self.userInfo.height?:175];
                byte[16] = [self checkoutsum:byte];
                [self writeValueBytes:byte length:17];
            } else {
                Byte byte[5] = {0xF2,0xC2,[self intTobyte:1],[self intTobyte:0]};
                byte[4] = [self checkoutsum:byte];
                [self writeValueBytes:byte length:5];
            }
        }
            break;
        case 3: {
            Byte byte[7];
            byte[0] = 0xF0;
            byte[1] = 0xC3;
            byte[2] = [self intTobyte:3];
            byte[3] = [self intTobyte:(int)self.sendKey]; // 1启动 2停止 3修改速度和坡度 4暂停
            // 速度小于或者大于上限，需要错误提示
            if (self.speedset < self.equipmentInfo.speedMin) {
                self.speedset = self.dataModel.speed;
            } else if (self.speedset > self.equipmentInfo.speedMax) {
                self.speedset = self.equipmentInfo.speedMax;
            }
            if (self.inclineset < self.equipmentInfo.inclineMin) {
                self.inclineset = self.dataModel.incline;
            } else if (self.inclineset > self.equipmentInfo.inclineMax) {
                self.inclineset = self.equipmentInfo.inclineMax;
            }
            byte[4] = [self intTobyte:(int)self.speedset * 10]; // 速度
            byte[5] = [self intTobyte:(int)self.inclineset];// 坡度
            byte[6] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:7];
        }
            break;
        case 4: {
            Byte byte[9];
            byte[0] = 0xF0;
            byte[1] = 0xC4;
            byte[2] = [self intTobyte:5];
            int sportMode = (int)self.sportMode;
            if (self.sportMode == EWSportModeFat) {
                sportMode = 4;
            } else if (self.sportMode == EWSportModeIRoute) {
                sportMode = 5;
            }
            byte[3] = [self intTobyte:sportMode];
            byte[4] = [self intTobyte:self.userInfo.age?:20];// 年龄
            byte[5] = [self intTobyte:self.userInfo.sex?:1];// 性别
            byte[6] = [self intTobyte:self.userInfo.height?:175];//身高
            byte[7] = [self intTobyte:self.userInfo.weight?:65];// 体重
            byte[8] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:9];
        }
            break;
        case 5: {
            Byte byte[14];
            byte[0] = 0xF0;
            byte[1] = 0xC5;
            byte[2] = [self intTobyte:10];;
            byte[3] = [self intTobyte:(int)self.timeset];//time
            byte[4] = [self intTobyte:(int)self.distanceset * 100 / 100];//距离
            byte[5] = [self intTobyte:(int)self.distanceset * 100 % 100];//0.5km
            byte[6] = [self intTobyte:(int)self.caloriesset / 100];// 卡路里
            byte[7] = [self intTobyte:(int)self.caloriesset % 100];//cal
            byte[8] = [self intTobyte:(int)self.paceset / 100];//pace hi
            byte[9] = [self intTobyte:(int)self.paceset % 100];//Pace low
            byte[10] = [self intTobyte:(int)self.pulseset];//pulse
            byte[11] = [self intTobyte:(int)self.speedset * 10.0];//speed
            byte[12] = [self intTobyte:(int)self.inclineset];//incline
            byte[13]=[self checkoutsum:byte];
            [self writeValueBytes:byte length:14];
        }
            break;
        case 6: {
            Byte byte[5];
            byte[0] = 0xF0;
            byte[1] = 0xC6;
            byte[2] = [self intTobyte:1];
            byte[3] = 0x01;
            byte[4] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:5];
        }
            break;
        case 7: {
            Byte byte[5];
            byte[0] = 0xF0;
            byte[1] = 0xC7;
            byte[2] = [self intTobyte:1];
            byte[3] = 0x01;
            byte[4] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:5];
        }
            break;
        case 8: {
            Byte byte[15];
            byte[0] = 0xF0;
            byte[1] = 0xC8;
            byte[2] = [self intTobyte:11];

            if (self.speedSign == 0x01) {
                byte[13] = 0x01;
                for (int i = 0; i < 10; i++) {
                    if (self.sportMode == EWSportModeProgram) {
                        byte[i + 3] = customeSpeeds[i] * 10;
                    } else {
                        NSInteger sportMode = self.sportMode;
                        if (sportMode > 3) {
                            sportMode -= 3;
                        }
                        byte[i + 3] = SPEEDS_1_20[sportMode][i] * 10;
                    }
                    
                }
            } else if (self.speedSign == 0x02){
                byte[13] = 0x02;
                for (int i = 0; i < 10; i++) {
                    if (self.sportMode == EWSportModeProgram) {
                        byte[i + 3] = customeSpeeds[i+10]*10;
                    } else {
                        NSInteger sportMode = self.sportMode;
                        if (sportMode > 3) {
                            sportMode -= 3;
                        }
                        byte[i + 3] = SPEEDS_1_20[sportMode][i + 10] * 10;
                    }
                    
                }
            }
            byte[14]=[self checkoutsum:byte];
            [self writeValueBytes:byte length:15];
        }
            break;
        case 10: {
            Byte byte[15];
            byte[0] = 0xF0;
            byte[1] = 0xCA;
            byte[2] = [self intTobyte:11];
            
            if (self.inclineSign == 0x01) {
                byte[13] = 0x01;
                for (int i = 0; i < 10; i ++) {
                    if (self.sportMode == EWSportModeProgram) {
                        byte[i + 3] = customeinclines[i];
                    }else{
                        NSInteger sportMode = self.sportMode;
                        if (sportMode > 3) {
                            sportMode -= 3;
                        }
                        byte[i + 3] = INCLINES1_20[sportMode][i];
                    }
                    
                }
                
            } else if (self.inclineSign == 0x02){
                byte[13]=0x02;
                for (int i = 0; i < 10; i++) {
                    if (self.sportMode == EWSportModeProgram) {
                        byte[i + 3] = customeinclines[i+10];
                    } else {
                        NSInteger sportMode = self.sportMode;
                        if (sportMode > 3) {
                            sportMode -= 3;
                        }
                        byte[i + 3] = INCLINES1_20[sportMode][i + 10];
                    }
                    
                }
            }
            byte[14] = [self checkoutsum:byte];
            [self writeValueBytes:byte length:15];
        }
            break;
        default:
            break;
    }
}

/// 写入数据到设备
/// @param bytes bytes
/// @param length 长度
- (void)writeValueBytes:(nullable const void *)bytes length:(NSUInteger)length {
    NSData *data = [[NSData alloc] initWithBytes:bytes length:length];
    if (self.writeCharacteristic) {
        [self.currentPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
    if (self.readCharacteristic) {
        [self.currentPeripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
    }
}


/// 读取单车数据
/// @param data 单车数据
- (void)readBikeDataWithData:(NSData *)data {
    Byte *bRecv = (Byte *)[data bytes];
    if ([self byteToint:(bRecv[1])] != 0xde) {
        switch (self.command) {
            case 0: {
                if ([self byteToint:bRecv[1] == 0xd0 && [self checkoutsum:bRecv] == bRecv[3]]) {
                    self.command = 1;
                }
            }
                break;
            case 1: {
                if ([self byteToint:bRecv[1]] == 0xd1 && [self checkoutsum:bRecv] == bRecv[15]) {
                    // Watt：是否支持Watt模式（0：为不支持1：支持）
                    if ([self byteToint:bRecv[3]] == 0x01) {
                        self.equipmentInfo.isWatt = YES;
                    } else { // 不支持watt
                        self.equipmentInfo.isWatt = NO;
                    }
                    // HRC：是否支持HRC模式（0：为不支持1：支持）
                    if ([self byteToint:bRecv[4]] == 0x01) {
                        self.equipmentInfo.isHRC = YES;
                    } else {
                        self.equipmentInfo.isHRC = NO;
                    }
                    // Level Max：最大Level值
                    self.equipmentInfo.levelMax = [self byteToint:bRecv[5]];
                    // 最大坡度 0：无坡度设备
                    self.equipmentInfo.inclineMax = [self byteToint:bRecv[6]];
                    
                    // KM/MI：公制或者英制（0=不设置；1=公制；2=英制）
                    if ([self byteToint:bRecv[7]] == 0x02) {
                        self.equipmentInfo.KMMI = 1;
                    } else {
                        self.equipmentInfo.KMMI = 0;
                    }
                    // 程序
                    self.programNum = [self byteToint:bRecv[8]];
                    [self byteToint:bRecv[13]];
                    [self byteToint:bRecv[14]];
                    self.command = 2;
                    
                    // 返回设备信息
                    if (self.getEWEquipmentInfoBlock) {
                        self.getEWEquipmentInfoBlock(self.equipmentInfo);
                    }
                }
            }
                break;
            case 2: {
                if (self.writeCharacteristic) {
                    if ([self byteToint:(bRecv[1])] == 0xd2 && [self checkoutsum:(bRecv)] == bRecv[17]) {
                        self.userInfo.user = [self byteToint:(bRecv[3])];// 用户
                        self.userInfo.language = [self byteToint:(bRecv[4])];// 语言
                        self.userInfo.age = [self byteToint:(bRecv[5])];// 年龄
                        self.userInfo.sex = [self byteToint:(bRecv[6])];// 性别
                        self.userInfo.weight = [self byteToint:(bRecv[7])] * 256 + [self byteToint:(bRecv[8])];// 体重
                        self.userInfo.height = [self byteToint:(bRecv[9])] * 256 + [self byteToint:(bRecv[10])];// 高度
                        self.totalTime = [self byteToint:(bRecv[11])] * 256 + [self byteToint:(bRecv[12])];// 总时间
                        self.totalDist = [self byteToint:(bRecv[13])] * 256 + [self byteToint:(bRecv[14])];// 总距离
                        self.totalDist = [self byteToint:(bRecv[15])] * 256 + [self byteToint:(bRecv[16])];// 总卡路里
                        self.command = 3;
                    }
                } else {
                    if ([self byteToint:(bRecv[1])] == 0xd2 && [self checkoutsum:(bRecv)] == bRecv[4]) {
                        self.command = 3;
                    }
                }
            }
                break;
            case 3: {
                if([self byteToint:(bRecv[1])] == 0xd3 && [self checkoutsum:(bRecv)] == bRecv[19]) {
                    // 基础数据
                    self.dataModel.timemin = [self byteToint:(bRecv[3])];
                    self.dataModel.timesec = [self byteToint:(bRecv[4])];
                    self.dataModel.distance = ([self byteToint:(bRecv[5])] * 256 + [self byteToint:(bRecv[6])]);
                    self.dataModel.calories = [self byteToint:(bRecv[7])] * 256 + [self byteToint:(bRecv[8])];
                    self.dataModel.watt = [self byteToint:(bRecv[9])] * 256 + [self byteToint:(bRecv[10])];
                    self.dataModel.pulse = [self byteToint:(bRecv[11])];
                    self.dataModel.speed = ([self byteToint:(bRecv[12])] * 256 + [self byteToint:(bRecv[13])]);
                    self.dataModel.strokes = [self byteToint:(bRecv[12])] * 256 + [self byteToint:(bRecv[13])];
                    self.dataModel.incline = [self byteToint:(bRecv[14])];
                    self.dataModel.level = [self byteToint:(bRecv[15])];
                    self.dataModel.rpm = [self byteToint:(bRecv[16])] * 256 + [self byteToint:(bRecv[17])];
                    self.dataModel.highlighted = ([self byteToint:bRecv[18]]) % 16;
                   
                    // 发送命令
                    if (self.sendKey == 2 || self.sendKey == 3) {
                        self.sendKey = 0;
                    } else if (self.sendKey == 4) {
                        if (self.sportMode == EWSportModeWatt) {
                            if (self.wattset == self.dataModel.watt) {
                                self.sendKey = 0;
                            }
                        } else {
                            if (self.levelset == self.dataModel.level) {
                                self.sendKey = 0;
                            }
                        }
                    } else if (self.sendKey == 1) {
                        
                    }
                    
                    // 判断状态
                    switch ([self byteToint:bRecv[18]] % 16) {
                        case 0:
                            self.sportState = EWSportStateStop;
                            break;
                        case 1: {
                            self.sportState = EWSportStateSport;
                            if (self.sendKey == 1 || self.sendKey == 3) {
                                self.sendKey = 0;
                            }
                            break;
                        }
                        case 2:
                            self.sportState = EWSportStatePause;
                            break;
                        default:
                            break;
                    }
                    self.dataModel.sportState = self.sportState;
                    
                    // 返回数据
                    self.data = [[NSData alloc] initWithBytes:bRecv length:19];
                    if (self.didUpdateSportData) {
                        self.didUpdateSportData(self.data);
                    }
                    // 返回数据模型
                    if (self.didUpdateDataModel) {
                        self.didUpdateDataModel(self.dataModel);
                    }
                }
            }
                break;
            case 4: {
                if ([self byteToint:(bRecv[1])] == 0xd4 && [self checkoutsum:(bRecv)] == bRecv[5]) {
                    switch (self.sportMode) {
                        case EWSportModeNormal:
                            self.command = 3;
                            break;
                        case EWSportModeProgram:
                            self.command = 5;
                            break;
                        case EWSportModeCountDown:
                            self.command = 3;
                            break;
                        case EWSportModeHRC:
                            self.command = 3;
                            break;
                        case EWSportModeUser:
                            self.command = 3;
                            break;
                        case EWSportModeWatt:
                            self.command = 3;
                            break;
                        case EWSportModeRecovery:
                            self.command = 3;
                            self.sportMode = EWSportModeNormal;
                            self.sendKey = 2;
                        default:
                            break;
                    }
                }
            }
            case 5: {
                if ([self byteToint:(bRecv[1])] == 0xd5 || [self checkoutsum:(bRecv)] == bRecv[16]) {
                    if (self.isWriteProg) {
                        if([self byteToint:(bRecv[4])] == 0x10) {
                            self.command = 3 ;
                        } else if([self byteToint:(bRecv[4])] == 0x20) {
                            self.R_HORLdata = 2;
                        } else if([self byteToint:(bRecv[4])] == 0x21) {
                            self.command = 3;
                            self.R_HORLdata = 1;
                        } else {
                            self.command=3;
                        }
                    }
                }
            }
                break;
            case 6: {
                if ([self byteToint:(bRecv[1])] == 0xd6 && [self checkoutsum:(bRecv)]==bRecv[16]) {
                    self.command = 3;
                }
            }
                break;
            case 7: {
                if ([self byteToint:(bRecv[1])] == 0xd7 && [self checkoutsum:(bRecv)] == bRecv[14]) {
                    if ([self byteToint:(bRecv[13])] == 1) {
                        for (int i = 0; i < 10; i ++) {
                            [self.speeddata appendFormat:@"%ld",(long)bRecv[i+3]/10];
                        }
                        self.R_HORLdata=2;
                    } else if([self byteToint:(bRecv[13])] == 2) {
                        for (int i = 0; i < 10; i ++) {
                            [self.speeddata appendFormat:@"%ld",(long)bRecv[i+3]/10];
                        }
                        self.command = 9;
                        self.R_HORLdata = 1;
                    }
                }
            }
                break;
            case 8: {
                if ([self byteToint:(bRecv[1])]==0xd8 && [self checkoutsum:(bRecv)]==bRecv[4]) {
                    self.R_HORLdata = [self byteToint:(bRecv[5])];
                    if (self.R_HORLdata == 0x20) {
                        self.R_HORLdata = 2;
                    } else if(self.R_HORLdata == 0x21) {
                        self.command = 0x0a;
                        self.R_HORLdata=1;
                    }
                }
            }
                break;
            case 9: {
                if ([self byteToint:(bRecv[1])] == 0xd9 && [self checkoutsum:(bRecv)] == bRecv[14]) {
                    if ([self byteToint:(bRecv[13])] == 1) {
                        for (int i = 0; i < 10; i++) {
                            [self.inclinedata appendFormat:@"%hhu",bRecv[i+3]];
                        }
                        self.R_HORLdata=2;
                    } else if([self byteToint:(bRecv[13])] == 2) {
                        for (int i = 0; i < 10; i++) {
                            [self.inclinedata appendFormat:@"%hhu",bRecv[i+3]];
                        }
                        self.R_HORLdata=1;
                        self.command = 3;
                    }
                }
            }
                break;
            case 0x0a: {
                if ([self byteToint:(bRecv[1])] == 0xda && [self checkoutsum:(bRecv)] == bRecv[4]) {
                    self.R_HORLdata = [self byteToint:(bRecv[3])];
                    if (self.R_HORLdata == 1) {
                        self.R_HORLdata=2;
                    } else if(self.R_HORLdata == 2) {
                        self.command = 5;
                        self.R_HORLdata = 1;
                    }
                }
            }
                break;
            case 0x0b: {
                if ([self byteToint:(bRecv[1])] == 0xdb && [self checkoutsum:(bRecv)] == bRecv[6]) {
                    if ([self byteToint:(bRecv[3])] == 2) {
                        self.sendKey = 0;
                        self.command = 3;
                    }
                    self.sendKeyTimes = 0;
                }
            }
                break;
            case 0x0f: {
                if ([self byteToint:(bRecv[1])] == 0xdf && [self checkoutsum:(bRecv)] == bRecv[3]) {
                    self.command = 0;
                }
            }
                break;
            case 0x10: {
                if ([self byteToint:(bRecv[1])] == 0x60 && [self checkoutsum:(bRecv)] == bRecv[5]) {
                    switch ([self byteToint:(bRecv[4])]) {
                        case 0: {
                            if ([self byteToint:(bRecv[3])] == 0 || [self byteToint:(bRecv[3])] == 2) {//短记录或长记录2接收成功
                                NSInteger data;
                                data = (self.updata_num + 1) * (self.hex_length / 1000);
                                if (self.Addr_Send > data) {
                                    self.updata_num ++;
                                    if (self.updata_num > 999) {
                                        self.updata_num = 1000;
                                    }
                                }
                            } else if ([self byteToint:(bRecv[3])] == 1) {
                                
                            }
                        }
                            break;
                        case 1:
                            break;
                        case 2:
                            self.command = 0;
                            self.sendenable = NO;
                            break;
                        case 3:
                            break;
                        case 4: {
                            if (self.updataEnd) {
                                self.command = 0;
                            } else {
                                self.pageEnd = NO;
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
        default:
                break;
        }
    } else {
        switch ([self byteToint:(bRecv[3])]) {
            case 0x01:
                NSLog(@"拉线器报错！");
                break;
            case 0x02:
                NSLog(@"坡度报错！");
                break;
            case 0x03:
                NSLog(@"通讯错误！");
                break;
            case 0x04:
                NSLog(@"坡度错误！");
                break;
            default:
                break;
        }
        self.sendenable = YES;
        self.command = 3;
    }
    if (self.currentPeripheral) {
        [self sendCommand:self.command];
    }
}

/// 读取跑步机数据
/// @param data 跑步机数据
- (void)readTreadmillDataWithData:(NSData *)data {
    Byte *bRecv = (Byte *)[data bytes];
    if ([self byteToint:(bRecv[1])] != 0xD0) {
        switch (self.command) {
            case 0: {
                if ([self byteToint:bRecv[1]] == 0xD0 && [self checkoutsum:bRecv]== bRecv[4]) {
                    self.command = 1;
                }
            }
                break;
            case 1: {
                if ([self byteToint:bRecv[1]] == 0xD1 && [self checkoutsum:bRecv]== bRecv[18]) {
                    self.command = 3;
                    self.equipmentInfo.speedMin = [self byteToint:bRecv[3]] / 10.0;
                    self.equipmentInfo.speedMax = [self byteToint:bRecv[4]] / 10.0;
                    self.equipmentInfo.inclineMin = [self byteToint:bRecv[5]];
                    self.equipmentInfo.inclineMax = [self byteToint:bRecv[6]];
                    
                    // 返回设备信息
                    if (self.getEWEquipmentInfoBlock) {
                        self.getEWEquipmentInfoBlock(self.equipmentInfo);
                    }
                }
            }
                break;
            case 2: {
                if([self byteToint:(bRecv[1])] == 0xd2 && [self checkoutsum:(bRecv)] == bRecv[17]){
                    self.command = 3;
                }
            }
                break;
            case 3: {
                if([self byteToint:(bRecv[1])] == 0xd3 && [self checkoutsum:(bRecv)] == bRecv[19]) {
                    self.dataModel.timesec = [self byteToint:bRecv[3]];
                    self.dataModel.timemin = [self byteToint:bRecv[4]];
                    self.dataModel.distance = ([self byteToint:bRecv[5]] * 100 + [self byteToint:bRecv[6]]);
                    self.dataModel.calories = [self byteToint:bRecv[7]] * 100 + [self byteToint:bRecv[8]];
                    self.dataModel.pulse = [self byteToint:bRecv[9]];
                    self.dataModel.speed = [self byteToint:bRecv[10]];
                    self.dataModel.level = [self byteToint:bRecv[10]];
                    self.dataModel.incline = [self byteToint:bRecv[11]];
                    self.dataModel.pace = [self byteToint:bRecv[12]] * 100 + [self byteToint:bRecv[13]];
                    self.dataModel.rpm = [self byteToint:bRecv[12]] * 100 + [self byteToint:bRecv[13]];
                    self.dataModel.hardKey = [self byteToint:bRecv[18]];
                    
                    // 获取运动状态
                    NSInteger sportState = [self byteToint:bRecv[14]];// 0x00:None,0x01:Idle待机;0x02:sysCount倒计时;0x03:Sport运动中;0x04:Pause暂停
                    // 判断状态
                    switch (sportState) {
                        case 0: {
                            self.sportState = EWSportStateStop;
                            if (self.sendKey == 2) {
                                self.sendKey = 0;
                            }
                        }
                            break;
                        case 1: {
                            self.sportState = EWSportStateLdle;
                            self.sendKey = 0;
                        }
                            break;
                        case 2: {
                            self.sportState = EWSportStateSyscount321;
                        }
                        case 3: {
                            self.sportState = EWSportStateSport;
                            if (self.sendKey == 1) {
                                self.sendKey = 0;
                            } else if (self.sendKey == 3) {
                                if (self.dataModel.speed == self.speedset && self.dataModel.incline == self.inclineset) {
                                    self.sendKey = 0;
                                }
                            }
                        }
                            break;
                        case 4:
                            self.sportState = EWSportStatePause;
                            if (self.sendKey == 4) {
                                self.sendKey = 0;
                            }
                            break;
                        default:
                            break;
                        case 5: {
                            self.sportState = EWSportStateStop;
                            if (self.sendKey == 2) {
                                self.sendKey = 0;
                            }
                        }
                            break;
                    }
                    self.dataModel.sportState = self.sportState;
                    
                    // 返回数据
                    self.data = [[NSData alloc] initWithBytes:bRecv length:19];
                    if (self.didUpdateSportData) {
                        self.didUpdateSportData(self.data);
                    }
                    // 返回数据模型
                    if (self.didUpdateDataModel) {
                        self.didUpdateDataModel(self.dataModel);
                    }
                }
            }
                break;
            case 4: {
                if ([self byteToint:bRecv[1]] == 0xd4 && [self checkoutsum:bRecv] == bRecv[6]) {
                    self.command = 5;
                    self.equipmentInfo.speedMin = [self byteToint:bRecv[3]] / 10.0;
                    self.equipmentInfo.speedMax = [self byteToint:bRecv[4]] / 10.0;
                    self.equipmentInfo.inclineMin = 0;
                    self.equipmentInfo.inclineMax = [self byteToint:bRecv[5]];
                    // Hrc 模式可以设置最小最大速度
                    if (self.sportMode == EWSportModeHRC) {
                        
                    }
                }
            }
                break;
            case 5: {
                if ([self byteToint:bRecv[1]] == 0xd5 && [self checkoutsum:bRecv] == bRecv[3]) {
                    self.command = 6;
                }
            }
                break;
            case 6: {
                if ([self byteToint:bRecv[1]] == 0xd6 && [self checkoutsum:bRecv] == bRecv[3]) {
                    self.command = 3;
                }
            }
                break;
            case 7: {
                if ([self byteToint:bRecv[1]] == 0xd7 && [self checkoutsum:bRecv] == bRecv[14]) {
//                    self.command = 3;
                }
            }
                break;
            case 8: {
                if ([self byteToint:bRecv[1]] == 0xd8 && [self checkoutsum:bRecv] == bRecv[4]) {
                    if (bRecv[3] == 0x01) {
                        self.speedSign = 0x02;
                    } else if(bRecv[3] == 0x02){
                        self.command = 10;
                    }
                }
            }
                break;
            case 10: {
                if ([self byteToint:bRecv[1]] == 0xda && [self checkoutsum:bRecv] == bRecv[4]) {
                    if (bRecv[3] == 0x01) {
                        self.inclineSign = 0x02;
                    } else if(bRecv[3] == 0x02){
                        self.command = 4;
                    }
                }
            }
            default:
                break;
        }
    } else {
        switch ([self byteToint:bRecv[3]]) {
            case 0x01:
                NSLog(@"未检测到速度信号");
                break;
            case 0x02:
                NSLog(@"过载故障");
                break;
            case 0x04:
                NSLog(@"马达自动断开");
                break;
            case 0x05:
                NSLog(@"通信异常");
                break;
            case 0x0A:
                NSLog(@"安全锁断开");
                break;
            default:
                break;
        }
    }
    if (self.currentPeripheral) {
        [self sendCommand:self.command];
    }
}

- (Byte)checkoutsum:(Byte[])byte {
    Byte byt = 0;
    int length = 0, sum = 0;
    length = byte[2] + 3;
    for (int i = 0; i < length; i ++) {
        sum += byte[i];
    }
    byt = (Byte)(sum & 0xff);
    return byt;
}

- (Byte)intTobyte:(int)data {
    Byte byte = 0;
    byte = (Byte) (0xff & data);
    return byte;
}

- (int)byteToint:(Byte)data {
    int a = 0xff;
    a = a & data;
    return a;
}

// 保持通讯
- (void)keepInTouch {
    if (self.currentPeripheral) {
        NSLog(@"保持通讯");
        [self sendCommand:self.command];
    }
}

// 重置运动数据，适用于切换模式
- (void)resetSportData {
    self.distanceset = 0;
    self.caloriesset = 0;
    self.timeset = 0;
    self.pulseset = 0;
    self.paceset = 0;
    self.wattset = 0;
    self.levelset = 0;
    self.inclineset = 0;
    self.speedset = 0.0;
    self.cf_p = 0;
    self.programNum = 0x10; // 第几个程序
    self.speedSign = 0;
    self.inclineSign = 0;
    self.R_HORLdata = 1;
    self.sportMode = EWSportModeNormal;
    self.data = nil;
    self.dataModel = [[EWDataModel alloc] init];
}
// 重置运动设备基础数据，适用于断开连接，断开蓝牙
- (void)resetBaseData {
    [self resetSportData];
    
    self.currentPeripheral = nil;
    self.writeCharacteristic = nil;
    self.readCharacteristic = nil;
    self.sendKey = 0;
    self.isWriteValue = NO;
    self.isWriteProg = YES;
    self.equipmentType = 0;
    self.dataModel = nil;
    self.equipmentInfo = nil;
    self.sportEquimentconnectionState = EWSportEquimentConnectionStateDisconnected;
}
// 重置蓝牙设备基础数据，适用于断开连接，断开蓝牙
- (void)resetWatchBaseData {
    self.tempWatchPeripheral = nil;
    self.currentWatchPeripheral = nil;
    self.watchEquimentConnectionState = EWWatchEquimentConnectionStateDisconnected;
}
@end
