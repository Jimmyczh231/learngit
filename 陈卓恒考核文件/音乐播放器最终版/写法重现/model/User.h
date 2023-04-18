//
//  User.h
//  写法重现
//
//  Created by jimmy on 3/27/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSArray *favoriteSongs;

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password favoriteSongs:(NSArray *)favoriteSongs;


@end

NS_ASSUME_NONNULL_END
