//
//  DetailViewController.m
//  写法重现
//
//  Created by jimmy on 3/20/23.
//

#import "DetailViewController.h"
#import "LyricView.h"
#import "SongManager.h"
@interface DetailViewController ()


@property(nonatomic, strong ,readwrite)UIButton *preButton;
@property(nonatomic, strong ,readwrite)UIButton *nextButton;
@property(nonatomic, strong ,readwrite)UIButton *loopSettingButton;
@property(nonatomic, strong ,readwrite)UIButton *likeButton;
@property(nonatomic, strong ,readwrite)UISlider *progressSlider;
@property(nonatomic, strong ,readwrite)SongManager *songManagerAtDetalView;
@property(nonatomic, strong ,readwrite)NSArray *LyricArray;
@property(nonatomic, strong ,readwrite)UIImage *icon;
@property(nonatomic, strong ,readwrite)NSTimer *timer;
@property(nonatomic, strong ,readwrite)CABasicAnimation *albumCoverRotationAnimation ;
@property(nonatomic, strong ,readwrite)LyricView *lyricView;
@property(nonatomic, weak ,readwrite)id<LyricViewDelegate> lyricViewDelegate;
@property(nonatomic, readwrite)BOOL shouldAlbumViewrotate;


@end

@implementation CALayer (PauseResume)

- (void)pauseAnimationwith:(BOOL)shouldpause {
    if(shouldpause){
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0.0;
        self.timeOffset = pausedTime;
    }
}

- (void)resumeAnimationwith:(BOOL)shouldresume {
    if(shouldresume){
        CFTimeInterval pausedTime = self.timeOffset;
        self.speed = 1.0;
        self.timeOffset = 0.0;
        self.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
}

- (void)stopAnimation {
    [self removeAnimationForKey:@"albumCoverRotationAnimation"];
}

@end



@implementation DetailViewController

//初始化的时候的设置
- (instancetype)init{
    self = [super init];
    if(self){
        // 接收从设置 View 发送的设置信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"SwitchStateOnSpinningSettingChanged" object:nil];
        self.shouldAlbumViewrotate = YES;
        self.songManagerAtDetalView = [[SongManager alloc]init];
        // 接收从歌词 View 发送的时间信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLyricTimeNotification:) name:@"LyricDidSelectNotification" object:nil];
        // 用于观察自己当前歌曲，变化时将发送信息给歌词 View
        [self addObserver:self forKeyPath:@"songIndex" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

// 在控制器销毁时取消观察和订阅通知
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LyricDidSelectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SettingChangedNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetAlbumCoverRotationAnimation];
    if(![self.audioPlayer isPlaying]){
        [self.albumImageView.layer pauseAnimationwith:self.shouldAlbumViewrotate];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 创建并配置UILabel
    self.detailLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.text = @"这是个人页面";
    
    // 播放按钮初始化
    [self.view addSubview:({
        self.playButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-35,[UIScreen mainScreen].bounds.size.height/1.256+60, 70, 70)];
        
        [self.playButton setImage:[UIImage imageNamed:({
            NSString* imagename;
            if(self.isSongPlayingAtPlayView){
                imagename = @"Playerstop.png";
            }else{
                imagename = @"Playerplay.png";
            }
            imagename;
        })] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.playButton;
    })];
    
    // 上一首歌按钮
    [self.view addSubview:({
        self.preButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-100,[UIScreen mainScreen].bounds.size.height/1.24+60, 50, 50)];
        [self.preButton setImage:[UIImage imageNamed:@"shangyishou.png"] forState:UIControlStateNormal];
        [self.preButton addTarget:self action:@selector(prePressAtPlayView:) forControlEvents:UIControlEventTouchUpInside];
        self.preButton;
    })];
    
    // 下一首歌按钮
    [self.view addSubview:({
        self.nextButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2+50,[UIScreen mainScreen].bounds.size.height/1.24+60, 50, 50)];
        [self.nextButton setImage:[UIImage imageNamed:@"xiayishou.png"] forState:UIControlStateNormal];
        [self.nextButton addTarget:self action:@selector(nextPressAtPlayView:) forControlEvents:UIControlEventTouchUpInside];
        self.nextButton;
    })];
    
    // 循坏播放按钮
    [self.view addSubview:({
        self.loopSettingButton = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-50)/4, ([UIScreen mainScreen].bounds.size.height-50)/1.35+60, 50, 50)];
        [self.loopSettingButton setImage:[UIImage imageNamed:@"danquxunhuan.png"] forState:UIControlStateNormal];
        [self.loopSettingButton addTarget:self action:@selector(loopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.loopSettingButton;
    })];
    
    // 喜欢按钮
    [self.view addSubview:({
        self.likeButton = [[UIButton alloc]initWithFrame:CGRectMake((([UIScreen mainScreen].bounds.size.width-50)/4)*3, ([UIScreen mainScreen].bounds.size.height-50)/1.35+60, 50, 50)];
        [self.likeButton setImage:({
            UIImage *likeimage = [UIImage imageNamed:@"zhuifanshu.png"];
            likeimage;
        }) forState:UIControlStateNormal];
        [self.likeButton addTarget:self action:@selector(likeButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton;
    })];
    
    // 专辑封面（包括旋转动画的初始化）
    [self.view addSubview:({
        UIImage *image = [[self.songsArray objectAtIndex:self.songIndex] objectForKey:@"albumArt"];
        self.albumImageView = [[UIImageView alloc]initWithImage:image];
        self.albumImageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 300)/2 , ([UIScreen mainScreen].bounds.size.height - 300)/2.4, 300, 300);
        // 将专辑封面裁剪为圆形
        [self albumImageCutwith:self.shouldAlbumViewrotate];
        // 添加layer
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithOvalInRect:self.albumImageView.bounds];
        maskLayer.path = maskPath.CGPath;
        self.albumImageView.layer.mask = maskLayer;
        //添加动画的方法
        [self resetAlbumCoverRotationAnimation];
        self.albumImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *albumtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(albumImageTap:)];
        [self.albumImageView addGestureRecognizer:albumtap];
        self.albumImageView;
        })] ;
    
    
    //歌手名称
    [self.view addSubview:({
        self.artistLabel = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)/2 , ([UIScreen mainScreen].bounds.size.height - 50)/10, 100, 50)];
        self.artistLabel.text = [[self.songsArray objectAtIndex:self.songIndex] objectForKey:@"artist"];
        self.artistLabel;
        })] ;
    
    //播放条初始化
    self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.width/1.3)/2, [UIScreen mainScreen].bounds.size.height/1.3+55, [UIScreen mainScreen].bounds.size.width/1.3-2, 30)];
    [self.progressSlider addTarget:self action:@selector(progressSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    self.progressSlider.minimumTrackTintColor =[UIColor redColor];
    [self.view addSubview:self.progressSlider];
    self.progressSlider.maximumValue = self.audioPlayer.duration;
    self.progressSlider.value = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressSlider) userInfo:nil repeats:YES];
    
    // 改变歌词的timer
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(sendNotification:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];


    
}
#pragma mark - 专辑动画

// 重制或初始化动画旋转动画
- (void)resetAlbumCoverRotationAnimation {
    // 移除现有的动画
    [self.albumImageView.layer removeAnimationForKey:@"albumCoverRotationAnimation"];
    if(self.shouldAlbumViewrotate){
        // 初始化新的动画
        self.albumCoverRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        self.albumCoverRotationAnimation.fromValue = @0.0;
        self.albumCoverRotationAnimation.toValue = @(2 * M_PI);
        self.albumCoverRotationAnimation.duration = 10.0; // 10 秒旋转一周
        self.albumCoverRotationAnimation.repeatCount = HUGE_VALF;
        self.albumCoverRotationAnimation.removedOnCompletion = NO;
        [self.albumImageView.layer addAnimation:self.albumCoverRotationAnimation forKey:@"albumCoverRotationAnimation"];
        // 将新的动画添加到专辑view上
        [self.albumImageView.layer resumeAnimationwith:self.shouldAlbumViewrotate];
    }
}

#pragma mark - 和播放相关的方法

// 播放条拖动改变的方法
- (void)progressSliderValueChange:(UISlider*)slider {
    [self.audioPlayer stop];
    [self.albumImageView.layer pauseAnimationwith:self.shouldAlbumViewrotate];
    self.audioPlayer.currentTime = slider.value;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    [self.albumImageView.layer resumeAnimationwith:self.shouldAlbumViewrotate];
    [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
    
}

// 更新进度条
- (void)updateProgressSlider{
    self.progressSlider.value = self.audioPlayer.currentTime;
    self.progressSlider.maximumValue = self.audioPlayer.duration;
}

// 播放按钮点击
-(void)playButtonClick:(UIButton*)button{
    if([self.audioPlayer isPlaying]){
        [self.audioPlayer pause];
        [self.playButton setImage:[UIImage imageNamed:@"Playerplay.png"] forState:UIControlStateNormal];
        self.isSongPlayingAtPlayView = NO;
        if(self.shouldAlbumViewrotate){
            [self.albumImageView.layer pauseAnimationwith:self.shouldAlbumViewrotate];
        }
    }else{
        [self.audioPlayer play];
        [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
        self.isSongPlayingAtPlayView = YES;
        if(self.shouldAlbumViewrotate){
            [self.albumImageView.layer resumeAnimationwith:self.shouldAlbumViewrotate];
        }
    }
}

//上一首歌和下一首歌点击时候的逻辑
- (void)prePressAtPlayView:(UIButton*)button{
    [self.changeSongDelegate preButtonPress];
    [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
    [self resetAlbumCoverRotationAnimation];
}
- (void)nextPressAtPlayView:(UIButton*)button{
    [self.changeSongDelegate nextButtonPress];
    [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
    [self resetAlbumCoverRotationAnimation];
}

//选择循环方式
-(void)loopButtonClick:(UIButton*)button{
    switch (self.playmodeAtPlayingView) {
        case Loop:
            [self.loopSettingButton setImage:[UIImage imageNamed:@"danquxunhuan.png"] forState:UIControlStateNormal];
            self.playmodeAtPlayingView = Singleloop;
            break;
        case Singleloop:
            [self.loopSettingButton setImage:[UIImage imageNamed:@"suijibofang.png"] forState:UIControlStateNormal];
            [self.changeSongDelegate loopRandomSelected];
            self.playmodeAtPlayingView = Random;
            break;
        case Random:
            [self.loopSettingButton setImage:[UIImage imageNamed:@"liebiaoxunhuan.png"] forState:UIControlStateNormal];
            self.playmodeAtPlayingView = Loop;
            break;
        default:
            break;
    }
}

//喜欢按钮点击时的逻辑
- (void)likeButtonPress:(UIButton*)button{
    NSDictionary *songinfo = [self.songsArray objectAtIndex:self.songIndex];
    if(![self.likeable isUserLogin]){
        return;
    }else if([self.likeable isSonglikedWith:songinfo]){
        [self.likeButton setImage:[UIImage imageNamed:@"zhuifanshu.png"] forState:UIControlStateNormal];
        [self.likeable deleteFavorSongfromUserwith:songinfo];
    }else{
        [self.likeButton setImage:[UIImage imageNamed:@"yizhuifan.png"] forState:UIControlStateNormal];
        [self.likeable addFavorSongToUserwith:songinfo];
    }
    
}

//更新喜欢按钮
- (void)UpdateLikedButton{
    NSDictionary *songinfo = [self.songsArray objectAtIndex:self.songIndex];
    if(![self.likeable isUserLogin]){
        [self.likeButton setImage:[UIImage imageNamed:@"zhuifanshu.png"] forState:UIControlStateNormal];
    }else if([self.likeable isSonglikedWith:songinfo]){
        [self.likeButton setImage:[UIImage imageNamed:@"yizhuifan.png"] forState:UIControlStateNormal];
    }else{
        [self.likeButton setImage:[UIImage imageNamed:@"zhuifanshu.png"] forState:UIControlStateNormal];
    }
    
}



#pragma mark - 设置信息接收

// 接收设置修改的信息
- (void)receiveNotification:(NSNotification *)notification {
    // 处理接收到的设置消息
    NSDictionary *userInfo = notification.userInfo;
    self.shouldAlbumViewrotate = [[userInfo objectForKey:@"switchState"] boolValue];
    [self resetAlbumCoverRotationAnimation];
    [self albumImageCutwith:self.shouldAlbumViewrotate];
}

#pragma mark - 和歌词页面相关的方法

// 发送当前播放时间给歌词 View
- (void)sendNotification:(NSTimer *)timer {
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    NSDictionary *userInfo = @{@"time": @(currentTime)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeToChangelyric" object:nil userInfo:userInfo];
}

// 接收歌词页面的时间信息并修改player的时间
- (void)didReceiveLyricTimeNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval lyricTime = [userInfo[@"timeInterval"] doubleValue];
    
    // 将歌曲播放器的时间设置为接收到的时间
    self.audioPlayer.currentTime = lyricTime;
}

// 裁剪专辑封面
- (void)albumImageCutwith:(BOOL)shouldcut{
    if(shouldcut){
        self.albumImageView.layer.cornerRadius = self.albumImageView.frame.size.width / 2.0;
        self.albumImageView.layer.masksToBounds = YES;
    }else{
        self.albumImageView.layer.cornerRadius = 0.0;
        self.albumImageView.layer.masksToBounds = NO;

    }
}

// 点击封面弹出歌词页面
- (void)albumImageTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        self.LyricArray = [self.songManagerAtDetalView CreateLyricArraywith:[[self.songsArray objectAtIndex:self.songIndex]objectForKey:@"lyrics"]];
        self.lyricView = [[LyricView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 9/15) lyric:self.LyricArray];
        self.lyricView.center = CGPointMake(self.view.center.x, self.view.center.y* 18/20);
        self.lyricViewDelegate = self.lyricView;
        [self.view addSubview:self.lyricView];
    }
}

// 观察者逻辑实现
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"songIndex"]) {
        // 发送歌词
        self.LyricArray = [self.songManagerAtDetalView CreateLyricArraywith:[[self.songsArray objectAtIndex:self.songIndex]objectForKey:@"lyrics"]];
        [self.lyricViewDelegate updateLyricViewWith:self.LyricArray];
        
    }
}
       

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



