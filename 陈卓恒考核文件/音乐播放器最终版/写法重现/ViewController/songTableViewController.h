//
//  songTableViewController.h
//  写法重现
//
//  Created by jimmy on 3/20/23.
//

#import <UIKit/UIKit.h>
#import "passSongProtocol.h"
#import "SceneDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface songTableViewController : UITableViewController
@property (nonatomic, weak) id <Passable> songTableViewdelegate;
@property(nonatomic, strong ,readwrite)NSArray *songsMutableArray;
@property(nonatomic, strong ,readwrite)SceneDelegate *passrootscene;


@end

NS_ASSUME_NONNULL_END
