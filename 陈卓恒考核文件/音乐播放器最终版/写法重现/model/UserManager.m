//
//  UserManager.m
//  写法重现
//
//  Created by jimmy on 3/28/23.
//

#import "UserManager.h"

@implementation UserManager


+ (instancetype)sharedInstance {
    static UserManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserManager alloc] init];
    });
    return instance;
}

- (NSURL *)usersFileURL {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

- (void)saveUsers:(NSDictionary<NSString *, User *> *)users {
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:users requiringSecureCoding:YES error:&error];
    if (data && !error) {
        NSURL *fileURL = [[self usersFileURL] URLByAppendingPathComponent:@"users"];
        [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
    }
    if (error) {
        NSLog(@"Save users failed with error: %@", error);
    }
}

- (NSDictionary<NSString *, User *> *)loadUsers {
    NSError *error = nil;
    NSURL *fileURL = [[self usersFileURL] URLByAppendingPathComponent:@"users"];
    NSData *data = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:&error];
    if (data && !error) {
        NSDictionary<NSString *, User *> *users = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:data error:&error];
        if (users && !error) {
            return users;
        }
    }
    if (error) {
        NSLog(@"Load users failed with error: %@", error);
    }
    return @{};
}

- (BOOL)registerUserWithUsername:(NSString *)username password:(NSString *)password favoriteSongs:(NSArray *)favoriteSongs {
    if (!username || !password) {
        return NO;
    }
    NSDictionary<NSString *, User *> *users = [self loadUsers];
    NSMutableDictionary<NSString *, User *> *usersmutable = [users mutableCopy];
    
    
    if (usersmutable[username]) {
        return NO;
    }
    User *user = [[User alloc] initWithUsername:username password:password favoriteSongs:favoriteSongs];
    usersmutable[username] = user;
    users = [usersmutable copy];
    [self saveUsers:users];
    return YES;
}

- (User *)loginWithUsername:(NSString *)username password:(NSString *)password {
    if (!username || !password) {
        return nil;
    }
    NSDictionary<NSString *, User *> *users = [self loadUsers];
    User *user = users[username];
    if (user && [user.password isEqualToString:password]) {
        return user;
    }
    return nil;
}


- (void)saveCurrentUser:(User *)user {
    if (!user) {
        return;
    }
    
    NSDictionary<NSString *, User *> *users =  [self loadUsers];
    NSMutableDictionary<NSString *, User *> *usersmutable = [users mutableCopy];
    NSString *username = user.username;
    
    if (usersmutable[username]) {
        [usersmutable setValue:user forKey:username];
    } else {
        usersmutable[username] = user;
    }
    user = [usersmutable copy];
    [self saveUsers:users];
    
}

@end
