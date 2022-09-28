//
//  EWTableCell.m
//  EWBluetoothDemo
//
//  Created by keli on 2021/6/15.
//

#import "EWTableCell.h"

@implementation EWTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(15, 10, self.frame.size.width / 2, 20);
    self.detailLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + 10, self.frame.size.width, 12);
    self.connectButton.frame = CGRectMake(self.frame.size.width - 88, 10, 66, 28);
}


- (void)setupViews {
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nameLabel.text = @"N/A";
    self.nameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.nameLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:12];
    self.detailLabel.text = @"Services:";
    self.detailLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.detailLabel];
    
    self.connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.connectButton.clipsToBounds = YES;
    self.connectButton.layer.cornerRadius = 14;
    self.connectButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.connectButton addTarget:self action:@selector(connectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.connectButton setTitle:@"未连接" forState:UIControlStateNormal];
    [self.connectButton setTitle:@"已连接" forState:UIControlStateSelected];
    [self.contentView addSubview:self.connectButton];
}

- (void)connectClick {
    if (self.connectAction) {
        self.connectAction();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
