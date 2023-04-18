//
//  SceneDelegate.h
//  写法重现
//
//  Created by jimmy on 3/20/23.
//

#import <UIKit/UIKit.h>
#import "passSongProtocol.h"
#import "LikeButtonUpdate.h"
@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>


@property (strong, nonatomic) UIWindow * window;
@property(nonatomic ,readwrite)NSInteger courentSongIndexAtScene;
@property(nonatomic, readwrite)BOOL isSongPlayingAtRootView;

@end

