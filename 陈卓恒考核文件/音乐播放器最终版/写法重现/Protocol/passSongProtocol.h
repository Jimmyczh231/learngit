//
//  passProtocol.h
//  写法重现
//
//  Created by jimmy on 3/25/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol Passable <NSObject>



@optional
- (NSInteger)passSongIndex:(NSInteger)index;


@end

@interface passSongProtocol : NSObject

@end

NS_ASSUME_NONNULL_END
