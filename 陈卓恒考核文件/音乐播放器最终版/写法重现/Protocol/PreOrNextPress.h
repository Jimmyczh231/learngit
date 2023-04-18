//
//  PreOrNextPress.h
//  写法重现
//
//  Created by jimmy on 3/26/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PreOrNextPressOnPlayView <NSObject>



@required
- (void)preButtonPress;
- (void)nextButtonPress;
- (void)loopRandomSelected;


@end
@interface PreOrNextPress : NSObject

@end

NS_ASSUME_NONNULL_END
