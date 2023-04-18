//
//  LikeButtonUpdate.h
//  写法重现
//
//  Created by jimmy on 3/30/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol buttonUpdateable <NSObject>



@required
- (void)UpdateLikedButton;



@end

@interface LikeButtonUpdate : NSObject

@end

NS_ASSUME_NONNULL_END
