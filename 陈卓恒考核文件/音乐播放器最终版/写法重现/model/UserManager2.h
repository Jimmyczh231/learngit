//
//  UserManager2.h
//  写法重现
//
//  Created by jimmy on 3/28/23.
//

#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager2 : NSObject

+ (instancetype)sharedInstance;

- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password favoriteSongs:(NSArray *)favoriteSongs;

- (User *)loginWithUsername:(NSString *)username password:(NSString *)password;

- (void)saveCurrentUser:(User *)user andwith:(NSArray*)upDatedArra;

- (void)updateuser:(User*)user with:(NSDictionary*)newSongs;

- (void)updateuser:(User*)user bydelete:(NSDictionary*)Songs;


@end

NS_ASSUME_NONNULL_END
