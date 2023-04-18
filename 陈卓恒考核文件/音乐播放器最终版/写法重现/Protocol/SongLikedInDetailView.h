//
//  SongLikedInDetailView.h
//  写法重现
//
//  Created by jimmy on 3/29/23.
//

#import <Foundation/Foundation.h>
#import "User.h"
NS_ASSUME_NONNULL_BEGIN
@protocol songLikeable <NSObject>



@required
- (void)addFavorSongToUserwith:(NSDictionary*)songFilename;
- (BOOL)isUserLogin;
- (BOOL)isSonglikedWith:(NSDictionary*)songFile;
- (void)deleteFavorSongfromUserwith:(NSDictionary*)songFilename;

@end

@interface SongLikedInDetailView : NSObject

@end

NS_ASSUME_NONNULL_END
