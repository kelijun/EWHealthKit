//
//  TreadmillController.m
//  EWBluetoothDemo
//
//  Created by keli on 2021/6/16.
//

#import "TreadmillController.h"
#import "EWCentralManager.h"
#import "EWUserInfoModel.h"
#import "EWEquipmentInfo.h"
#import "EWDataModel.h"

#define Cell_Identifier @"EWTableCell"
@interface TreadmillController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EWDataModel *dataModel;
@end

@implementation TreadmillController

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
    
    [[EWCentralManager sharedInstance] ew_getEquipmentInfoCompletion:^(EWEquipmentInfo * _Nonnull info) {
        NSLog(@"获取运动成功");
    }];
//    int Speeds[20]={2,3,3,4,5,3,4,5,5,3,4,5,4,4,4,2,3,3,5,3};
//    int inclines[20]={0,7,7,6,6,5,5,4,4,3,3,2,2,2,2,2,2,3,3,4};
//    [[EWCentralManager sharedInstance] ew_setProgramforTimeset:2 speedset:Speeds inceline:inclines];
//    
    // 开始运动
    [EWCentralManager sharedInstance].didUpdateDataModel = ^(EWDataModel * _Nonnull dataModel) {
        self.dataModel = dataModel;
        [self.tableView reloadData];
    };
}

#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Cell_Identifier];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"时间：%ld s",self.dataModel.timesec + self.dataModel.timemin * 60];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"距离：%.2f km",self.dataModel.distance / 100.0];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"卡路里：%ld kcal",self.dataModel.calories];
            break;
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"心率：%ld bpm",self.dataModel.pulse];
            break;
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"速度：%.1f km/h",self.dataModel.speed / 10.0];
            break;
        case 5:
            cell.textLabel.text = [NSString stringWithFormat:@"步数：%ld 步",self.dataModel.pace];
            break;
        case 6:
            cell.textLabel.text = [NSString stringWithFormat:@"坡度：%ld ",self.dataModel.incline];
            break;
        case 7:
            cell.textLabel.text = [NSString stringWithFormat:@"速度 +"];
            break;
        case 8:
            cell.textLabel.text = [NSString stringWithFormat:@"速度 -"];
            break;
        case 9:
            cell.textLabel.text = [NSString stringWithFormat:@"坡度 +"];
            break;
        case 10:
            cell.textLabel.text = [NSString stringWithFormat:@"坡度 -"];
            break;
        case 11:
            if ([EWCentralManager sharedInstance].sportState == EWSportStatePause) {
                cell.textLabel.text = [NSString stringWithFormat:@"继续"];
            } else if ([EWCentralManager sharedInstance].sportState == EWSportStateSport) {
                cell.textLabel.text = [NSString stringWithFormat:@"暂停"];
            }  else {
                cell.textLabel.text = [NSString stringWithFormat:@"开始"];
            }
            break;
        case 12:
            cell.textLabel.text = [NSString stringWithFormat:@"停止"];
            break;
        case 13:
            cell.textLabel.text = [NSString stringWithFormat:@"速度+10"];
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 7:
            // 速度增加
            [[EWCentralManager sharedInstance] ew_setSportData:self.dataModel.speed + 1 forEWSportDataType:EWSportDataTypeSpeed];
            break;
        case 8:
            // 速度增加
            [[EWCentralManager sharedInstance] ew_setSportData:self.dataModel.speed - 1 forEWSportDataType:EWSportDataTypeSpeed];
            break;
        case 9:
            // 坡度增加
            [[EWCentralManager sharedInstance] ew_setSportData:self.dataModel.incline + 1 forEWSportDataType:EWSportDataTypeIncline];
            break;
        case 10:
            // 坡度减少
            [[EWCentralManager sharedInstance] ew_setSportData:self.dataModel.incline - 1 forEWSportDataType:EWSportDataTypeIncline];
            break;
        case 11: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell.textLabel.text isEqualToString:@"暂停"]) {
                [[EWCentralManager sharedInstance] ew_pauseSport];
            } else if ([cell.textLabel.text isEqualToString:@"继续"]) {
                [[EWCentralManager sharedInstance] ew_resumeSport];
            }  else {
                [[EWCentralManager sharedInstance] ew_startSport];
            }
        }
            break;
        case 12:
            [[EWCentralManager sharedInstance] ew_stopSport];
            break;
        case 13:
            [[EWCentralManager sharedInstance] ew_setSportData:self.dataModel.speed + 10 forEWSportDataType:EWSportDataTypeSpeed];
            break;
        default:
            break;
    }
}


#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 45;
    }
    return _tableView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[EWCentralManager sharedInstance] ew_cancelCurrentPeripheralConnectionWithError:^(NSError * _Nonnull error) {
            
    }];
}
@end
