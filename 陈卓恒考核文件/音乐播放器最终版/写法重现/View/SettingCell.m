//
//  SpinSettingCell.m
//  写法重现
//
//  Created by jimmy on 4/7/23.
//

#import "SettingCell.h"

@interface SettingCell()

@property (nonatomic, strong) UISwitch *switchControl;



@end

@implementation SettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 初始化setting cell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 创建开关
        self.switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.switchControl addTarget:self action:@selector(switchControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.switchControl;
    }
    return self;
}

// 设置开关的状态
- (void)setSwitchState:(BOOL)on {
    self.switchControl.on = on;
    [self sendSwitchStateNotification:on];
    
}

// 开关状态发送
- (void)switchControlValueChanged:(UISwitch *)sender {
    [self sendSwitchStateNotification:sender.on];
}
- (void)sendSwitchStateNotification:(BOOL)on {
    NSDictionary *userInfo = @{@"switchState": @(on)};
    [[NSNotificationCenter defaultCenter] postNotificationName:_NotificationName  object:nil userInfo:userInfo];
}




@end
