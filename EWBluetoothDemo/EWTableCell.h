//
//  EWTableCell.h
//  EWBluetoothDemo
//
//  Created by keli on 2021/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EWTableCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, copy) void(^connectAction)(void);
@end

NS_ASSUME_NONNULL_END
