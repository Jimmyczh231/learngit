//
//  UserManager.h
//  写法重现
//
//  Created by jimmy on 3/28/23.
//

#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject


+ (instancetype)sharedInstance;

- (BOOL)registerUserWithUsername:(NSString *)username password:(NSString *)password favoriteSongs:(NSArray *)favoriteSongs;

- (User *)loginWithUsername:(NSString *)username password:(NSString *)password;

- (void)saveCurrentUser:(User *)user;

@end

NS_ASSUME_NONNULL_END
