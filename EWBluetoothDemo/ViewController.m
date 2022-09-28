//
//  ViewController.m
//  EWBluetoothDemo
//
//  Created by keli on 2021/6/15.
//

#import "ViewController.h"
#import "TreadmillController.h"
#import "EWTableCell.h"

#import "EWCentralManager.h"
#import "EWUserInfoModel.h"

#define Cell_Identifier @"EWTableCell"
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sectionList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    [self setupData];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.frame = self.view.frame;
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    self.sectionList = [@[@[],@[],@[],@[],@[]] mutableCopy];
    
    // 调用前，请在plist文件中，设置NSBluetoothAlwaysUsageDescription
    // 监听蓝牙状态，蓝牙状态发生变化时，刷新表格
    [[EWCentralManager sharedInstance] ew_centralManagerDidUpdateState:^(EWManagerState state) {
        [self.tableView reloadData];
    }];
    
    // 搜索指定设备
    [[EWCentralManager sharedInstance] ew_scanPeripheralsForHasPrefix:nil];
    
    // 扫描到一个设备，刷新一次表格
    [[EWCentralManager sharedInstance] ew_discoverPeripheralsCompletion:^(NSMutableArray * _Nonnull peripheralsList) {
        // ⚠️ 此处仅仅为了展示全部设备
        for (CBPeripheral *peripheral in peripheralsList) {
//            peripheral.name = @"";
        }
        [self.tableView reloadData];
    }];
    
    // 连接成功的设备列表更新
    [[EWCentralManager sharedInstance] ew_connectedPeripheralsListUpdateCompletion:^(NSMutableArray * _Nonnull peripheralsList) {
        [self.tableView reloadData];
    }];
    
    EWUserInfoModel *model = [[EWUserInfoModel alloc] init];
    model.age = 25;
    model.height = 170;
    model.weight = 65;
    model.language = 2;
    [[EWCentralManager sharedInstance] ew_configureUserInfo:model];
}

#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *equimentList = self.sectionList[section];
//    return equimentList.count;
    return [EWCentralManager sharedInstance].discoverPeripheralsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EWTableCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_Identifier];
    if (!cell) {
        cell = [[EWTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Cell_Identifier];
    }
    
//    NSArray *equimentList = self.sectionList[indexPath.row];
    CBPeripheral *peripheral = [EWCentralManager sharedInstance].discoverPeripheralsList[indexPath.row];
    cell.nameLabel.text = peripheral.name;
    cell.detailLabel.text = [NSString stringWithFormat:@"Services:%@",peripheral.identifier];
    cell.connectAction = ^{
        [self connectAtIndexPath:indexPath];
    };
    switch (peripheral.state) {
        case CBPeripheralStateDisconnected:
            [cell.connectButton setTitle:@"未连接" forState:UIControlStateNormal];
            [cell.connectButton setBackgroundColor:[UIColor systemBlueColor]];
            break;
        case CBPeripheralStateConnecting:
            
            break;
        case CBPeripheralStateConnected:
            [cell.connectButton setTitle:@"已连接" forState:UIControlStateNormal];
            [cell.connectButton setBackgroundColor:[UIColor systemGreenColor]];
            break;
        default:
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"未知型号";
    switch (section) {
        case 0:
            title = @"健身车";
            break;
        case 1:
            title = @"跑步机";
            break;
        case 2:
            title = @"椭圆机";
            break;
        case 3:
            title = @"划船机";
            break;
        case 4:
            title = @"手表";
            break;
        default:
            break;
    }
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([EWCentralManager sharedInstance].currentPeripheral) {
        TreadmillController *vc = [[TreadmillController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)connectAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [EWCentralManager sharedInstance].discoverPeripheralsList[indexPath.row];
    
    if (peripheral.state == CBPeripheralStateDisconnected) {
        // 连接蓝牙
//        [[EWCentralManager sharedInstance] ew_connectWatchPeripheral:peripheral completion:^(CBCentralManager * _Nonnull central, CBPeripheral * _Nonnull peripheral, NSError * _Nonnull error) {
//
//        }];
        [[EWCentralManager sharedInstance] ew_setupEquipmentType:indexPath.section];
        [[EWCentralManager sharedInstance] ew_connectSportPeripheral:peripheral completion:^(CBCentralManager * _Nonnull central, CBPeripheral * _Nonnull peripheral, NSError * _Nonnull error) {
            if (error) {
                
            }
        }];
    } else {
        // 断开蓝牙
        [[EWCentralManager sharedInstance] ew_cancelSportPeripheralConnection:peripheral completion:^(CBCentralManager * _Nonnull central, CBPeripheral * _Nonnull peripheral, NSError * _Nonnull error) {
            if (error) {
                
            }
        }];
    }
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 68;
    }
    return _tableView;
}

- (NSMutableArray *)sectionList {
    if (!_sectionList) {
        _sectionList = [NSMutableArray array];
    }
    return _sectionList;
}
@end
