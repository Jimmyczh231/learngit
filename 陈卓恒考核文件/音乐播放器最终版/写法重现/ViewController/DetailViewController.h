//
//  DetailViewController.h
//  写法重现
//
//  Created by jimmy on 3/20/23.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "playmode.h"
#import "PreOrNextPress.h"
#import "SongLikedInDetailView.h"
#import "LikeButtonUpdate.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DetailViewControllerDelegate <NSObject>
//设置代理
-(void)pass:(AVAudioPlayer*) audioPlayer;
typedef void (^MyBlock)(NSString *);

@end

@interface DetailViewController : UIViewController<buttonUpdateable>
@property (nonatomic, weak) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) NSString *detailText;
@property(nonatomic, strong ,readwrite)UIImageView *albumImageView;
@property(nonatomic, strong ,readwrite)UILabel *artistLabel;
@property (nonatomic) NSInteger songIndex;
@property (nonatomic, strong) NSArray *songsArray;
@property(nonatomic, strong ,readwrite)UIButton *playButton;
@property(nonatomic, readwrite)BOOL isSongPlayingAtPlayView;
@property(nonatomic, readwrite)playmode playmodeAtPlayingView;

@property (nonatomic, weak) id <PreOrNextPressOnPlayView> changeSongDelegate;
@property (nonatomic, weak) id <songLikeable> likeable;


@end


NS_ASSUME_NONNULL_END
