//
//  User.m
//  写法重现
//
//  Created by jimmy on 3/27/23.
//

#import "User.h"

@implementation User 



- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password favoriteSongs:(NSArray *)favoriteSongs {
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
        _favoriteSongs = favoriteSongs;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.username forKey:@"username"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeObject:self.favoriteSongs forKey:@"favoriteSongs"];
}



- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    NSString *username = [coder decodeObjectOfClass:[NSString class] forKey:@"username"];
    NSString *password = [coder decodeObjectOfClass:[NSString class] forKey:@"password"];
    NSArray *favoriteSongs = [coder decodeObjectOfClass:[NSArray class] forKey:@"favoriteSongs"];
    self.username = username;
    self.password = password;
    self.favoriteSongs = favoriteSongs;
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}





@end
