//
//  UserLikedSongsTableViewController.h
//  写法重现
//
//  Created by jimmy on 3/28/23.
//

#import <UIKit/UIKit.h>
#import "User.h"
NS_ASSUME_NONNULL_BEGIN

@interface UserLikedSongsTableViewController : UITableViewController

@property (nonatomic, strong) User *currentUser;

@end

NS_ASSUME_NONNULL_END
