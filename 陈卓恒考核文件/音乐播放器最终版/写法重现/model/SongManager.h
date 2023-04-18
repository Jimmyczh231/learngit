//
//  SongManager.h
//  写法重现
//
//  Created by jimmy on 4/5/23.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SongManagerFinishBlock)(BOOL isSuccess, NSArray *songsArrayInManager);

@interface SongManager : NSObject

+ (instancetype)sharedInstance;

- (void)SongManagerLoadedWithFinishBlock:(SongManagerFinishBlock)finishBlock;

- (NSArray*)CreateLyricArraywith:(NSString*)lyricsString;
@end

NS_ASSUME_NONNULL_END
