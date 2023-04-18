//
//  SpinSettingCell.h
//  写法重现
//
//  Created by jimmy on 4/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingCell : UITableViewCell

@property(nonatomic, copy)NSString *NotificationName;


- (void)setSwitchState:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
