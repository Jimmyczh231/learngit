//
//  LyricView.h
//  写法重现
//
//  Created by jimmy on 4/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol LyricViewDelegate <NSObject>



@required
- (void)updateLyricViewWith:(NSArray *)LyricArray;



@end
@interface LyricView : UIView<LyricViewDelegate>
- (instancetype)initWithFrame:(CGRect)frame lyric:(NSArray *)lyricArray;
@end

NS_ASSUME_NONNULL_END
