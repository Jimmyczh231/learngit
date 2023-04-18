//
//  SceneDelegate.m
//  写法重现
//
//  Created by jimmy on 3/20/23.
//

#import "SceneDelegate.h"
#import "MyViewController.h"
#import "songTableViewController.h"
#import "DetailViewController.h"
#import "SettingViewController.h"
#import "UserViewController.h"
#import "playmode.h"
#import "PreOrNextPress.h"
#import "User.h"
#import "SongManager.h"


@interface SceneDelegate ()<Passable,AVAudioPlayerDelegate,PreOrNextPressOnPlayView>

@property(nonatomic ,strong) SongManager *SongManager;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *rootController;
@property(nonatomic, strong ,readwrite)NSArray *songsArrayAtScene;

@property(nonatomic, strong ,readwrite)NSMutableArray *RandomIndexArray;

@property(nonatomic, strong ,readwrite)UIButton *playButton;
@property(nonatomic, strong ,readwrite)UIButton *preButton;
@property(nonatomic, strong ,readwrite)UIButton *nextButton;
@property(nonatomic, strong ,readwrite)UIButton *songImage;

@property(nonatomic, strong ,readwrite)UILabel *artistName;
@property(nonatomic, strong ,readwrite)UILabel *songName;

@property(nonatomic, strong ,readwrite)songTableViewController *songTableView;
@property(nonatomic, strong ,readwrite)DetailViewController *playingView;
@property(nonatomic, strong ,readwrite)UserViewController *UserView;

@property(nonatomic, strong ,readwrite)AVAudioPlayer *rootPlayer;

@property(nonatomic, readwrite)playmode playmodeAtRootView;
 
@property (nonatomic, weak) id <buttonUpdateable> Updateable;

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    //歌曲默认单曲循环
    self.playmodeAtRootView = Singleloop;
    
    // 创建UITabBarController并设置为根视图控制器
    self.tabBarController = [[UITabBarController alloc] init];
    self.rootController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    
    // 设置标签栏中的选项卡
    MyViewController *viewController1 = [[MyViewController alloc] init];
    self.songTableView = [[songTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.songTableView.title = @"MUSIC";
    self.songTableView.passrootscene = self;
    SettingViewController *viewController4 = [[SettingViewController alloc] initWithStyle:UITableViewStylePlain];
    self.UserView = [[UserViewController alloc] init];
    UINavigationController *Usernavigation = [[UINavigationController alloc]initWithRootViewController:self.UserView];
    self.tabBarController.viewControllers = @[viewController1, self.songTableView,Usernavigation, viewController4];


    // 配置标签栏
    UITabBar *tabBar = self.tabBarController.tabBar;
    NSArray *titles = @[@"主页", @"音乐", @"个人", @"设置"];
      NSArray *images = @[@"xinxiinfo21.png", @"yinlemusic215.png", @"peoplec.png", @"setup.png"];
    for (int i = 0; i < titles.count; i++) {
        UITabBarItem *item = [tabBar.items objectAtIndex:i];
        item.title = titles[i];;
          item.image = [UIImage imageNamed:images[i]];
    }
    self.tabBarController .tabBar. translucent = NO;
    self.window.rootViewController = self.rootController;
    
    // 读取歌曲信息并初始化装有歌曲信息的array和随机歌曲的array
    self.SongManager = [[SongManager alloc]init];
    __weak typeof (self) wself = self;
    [self.SongManager SongManagerLoadedWithFinishBlock:^(BOOL isSuccess, NSArray * _Nonnull songsArrayInManager) {
        __strong typeof (self) strongself = wself;
        strongself.songsArrayAtScene = songsArrayInManager;
    }];
    self.RandomIndexArray = [NSMutableArray arrayWithCapacity:self.songsArrayAtScene.count];
    for (NSUInteger i = 0; i < self.songsArrayAtScene.count; i++) {
        NSInteger a = i;
        [self.RandomIndexArray addObject:@(a)];
    }
    
    // 将装有歌曲信息的array同时赋给播放页面的
    self.songTableView.songsMutableArray = self.songsArrayAtScene;
    self.songTableView.songTableViewdelegate = self;
    
    // 播放条初始化
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame= CGRectMake(0,[UIScreen mainScreen].bounds.size.height/1.21, [UIScreen mainScreen].bounds.size.width, 65);
    
    // 播放按钮初始化
    [view addSubview:({
        self.playButton = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width/1.3,0, 50, 50)];
        [self.playButton setImage:[UIImage imageNamed:@"Playerplay.png"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.playButton;
    })];
    
    //歌名初始化
    self.songName = [[UILabel alloc]initWithFrame:CGRectMake(view.bounds.size.width/6,view.bounds.size.height/10, 200, 20)];
    self.songName.text = @"这首歌";
    [view addSubview:({
        self.songName;
    })];
    
    //歌手初始化
    self.artistName = [[UILabel alloc]initWithFrame:CGRectMake(view.bounds.size.width/6,view.bounds.size.height/2.5, 100, 20)];
    self.artistName.text = @"这歌手";
    self.artistName.font = [UIFont systemFontOfSize:13];
    [view addSubview:({
        self.artistName;
    })];
    
    // 设置歌曲封面按钮，当点击的时候进入播发页面
    self.songImage = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 60, 60)];
    [self.songImage setImage:[[self.songsArrayAtScene objectAtIndex:0] objectForKey:@"albumArt"] forState:UIControlStateNormal];
    [self.songImage addTarget:self action:@selector(pushController) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:({
        self.songImage;
    })];
    
    // 初始化播放页面
    self.playingView = [DetailViewController new];
    self.playingView.isSongPlayingAtPlayView = NO;
    
    // 观察播放页面的元素
    [self.playingView addObserver:self forKeyPath:@"isSongPlayingAtPlayView" options:NSKeyValueObservingOptionNew context:nil];
    [self.playingView addObserver:self forKeyPath:@"songIndex" options:NSKeyValueObservingOptionNew context:nil];
    [self.playingView addObserver:self forKeyPath:@"playmodeAtPlayingView" options:NSKeyValueObservingOptionNew context:nil];
    self.playingView.likeable = self.UserView;
    self.Updateable = self.playingView;
    
    // 接收喜欢歌曲
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"likedSongSelected" object:nil];
    

    [self.tabBarController.view addSubview:view];
    self.window.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark - NSNotification和KVO的实现
// 在实现的方法中获取传递的数据
- (void)handleNotification:(NSNotification *)notification {
    // 处理获取到的数据
    NSDictionary *userInfo = notification.userInfo;
    NSString *selectedfilename  = [userInfo objectForKey:@"filename"];
    for (NSDictionary *song in self.songsArrayAtScene) {
        if([[song objectForKey:@"filename"]isEqualToString:selectedfilename]){
            self.courentSongIndexAtScene = [self.songsArrayAtScene indexOfObject:song];
            //更新播放条和播放页面
            [self ChangeSongInfoAtRootView];
            [self ChangeSongInfoAtPlayingView];
            [self.rootPlayer prepareToPlay];
            [self.rootPlayer play];
            [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
        }
    }
}


// 观察者逻辑实现
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isSongPlayingAtPlayView"]) {
        // 在这里处理属性变化后的逻辑
        if([self.rootPlayer isPlaying]){
            [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"Playerplay.png"] forState:UIControlStateNormal];
        }
        
    }else if ([keyPath isEqualToString:@"songIndex"]){
        //当在播放页面的歌曲切换了的时候对主页面的设置做修改
        if(self.courentSongIndexAtScene != self.playingView.songIndex){
            self.courentSongIndexAtScene = self.playingView.songIndex;
            [self ChangeSongInfoAtRootView];
            self.playingView.audioPlayer = self.rootPlayer;
            [self ChangeSongInfoAtPlayingView];
        }
        
    }else if ([keyPath isEqualToString:@"playmodeAtPlayingView"]){
        self.playmodeAtRootView = self.playingView.playmodeAtPlayingView;
    }
}

// 在控制器销毁时取消观察和订阅通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"likedSongSelected" object:nil];
    [self removeObserver:self forKeyPath:@"isSongPlayingAtPlayView"];
    [self removeObserver:self forKeyPath:@"songIndex"];
    [self removeObserver:self forKeyPath:@"playmodeAtPlayingView"];
}

#pragma mark - 更新播放条面和播放页面的方法
// 更新主页面中的信息，并更新audioplayer
- (void)ChangeSongInfoAtRootView{
    [self.songImage setImage:[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"albumArt"] forState:UIControlStateNormal];
    self.artistName.text = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"artist"];
    self.songName.text = ({
        NSString *Name=[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"title"];
        if(!Name){
            Name = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"filename"];
        }
        Name;
    });
    
    // 更新audioplayer中的歌曲
    NSString *songsPath = [({
        // 获取文件夹地址
        NSString *folderName = @"AudioFile"; // 文件夹名称
        NSString *folderPath = [[NSBundle mainBundle] pathForResource:folderName ofType:nil];
        folderPath;
    }) stringByAppendingPathComponent:[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"filename"]];
    self.rootPlayer = nil;
    self.rootPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:songsPath] error:nil];
    self.rootPlayer.delegate = self;
}

//更新播放页面中的信息
- (void)ChangeSongInfoAtPlayingView{
    self.playingView.title = [NSString stringWithFormat:({
            NSString *title = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"title"];
            if(title){
            }else{
                title = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"filename"];
            }
            title;
        }), self.courentSongIndexAtScene];
    self.playingView.artistLabel.text =[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"artist"];
    self.playingView.albumImageView.image =[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"albumArt"];
    self.playingView.songIndex = self.courentSongIndexAtScene;
    self.playingView.isSongPlayingAtPlayView = [self.rootPlayer isPlaying];
    self.playingView.audioPlayer = self.rootPlayer;
}

//点击歌曲的cell时的逻辑
- (NSInteger)passSongIndex:(NSInteger)index{
    self.courentSongIndexAtScene = index;
    [self.songImage setImage:[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"albumArt"] forState:UIControlStateNormal];
    self.artistName.text = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"artist"];
    self.songName.text = ({
        NSString *Name=[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"title"];
        if(!Name){
            Name = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"filename"];
        }
        Name;
    });
    // 更新audioplayer中的歌曲
    NSString *str2 = [({
        // 获取文件夹地址
        NSString *folderName = @"AudioFile"; // 文件夹名称
        NSString *folderPath = [[NSBundle mainBundle] pathForResource:folderName ofType:nil];
        folderPath;
    }) stringByAppendingPathComponent:[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"filename"]];
    [self.playingView.audioPlayer stop];
    self.rootPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:str2] error:nil];
    self.rootPlayer.delegate = self;
    [self.playButton setImage:[UIImage imageNamed:@"Playerplay.png"] forState:UIControlStateNormal];
    [self.playingView.playButton setImage:[UIImage imageNamed:@"Playerplay.png"] forState:UIControlStateNormal];
    return self.courentSongIndexAtScene;
}

// 推出播放页面
- (void) pushController{
    self.playingView.detailText = [NSString stringWithFormat:@"你点击了第%ld行", self.courentSongIndexAtScene];
    self.playingView.title = [NSString stringWithFormat:({
            NSString *title = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"title"];
            if(title){
            }else{
                title = [[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"filename"];
            }
            title;
        }), self.courentSongIndexAtScene];
    self.playingView.artistLabel.text =[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"artist"];
    self.playingView.albumImageView.image =[[self.songsArrayAtScene objectAtIndex:self.courentSongIndexAtScene] objectForKey:@"albumArt"];
    self.playingView.songIndex = self.courentSongIndexAtScene;
    self.playingView.playmodeAtPlayingView = self.playmodeAtRootView;
    self.playingView.isSongPlayingAtPlayView = [self.rootPlayer isPlaying];
    self.playingView.audioPlayer = self.rootPlayer;
        [self.tabBarController.navigationController pushViewController:self.playingView animated:YES];
    self.playingView.songsArray = self.songsArrayAtScene;
    self.playingView.songIndex = self.courentSongIndexAtScene;
    [self.Updateable UpdateLikedButton];
    self.playingView.changeSongDelegate = self;
}





#pragma mark - AVAudioPlayerDelegate
// 当歌曲完成播放的时候
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.rootPlayer stop];
    switch (self.playmodeAtRootView) {
        case Loop:
            if((self.courentSongIndexAtScene++)>=[self.songsArrayAtScene count]){
                self.courentSongIndexAtScene = 0;
            }
            self.playingView.songIndex = self.courentSongIndexAtScene;
            [self ChangeSongInfoAtRootView];
            [self ChangeSongInfoAtPlayingView];
            [self.rootPlayer prepareToPlay];
            [self.rootPlayer play];
            break;
        case Singleloop:
            self.rootPlayer.currentTime = 0;
            [self.rootPlayer prepareToPlay];
            [self.rootPlayer play];
            break;
        case Random:
        {
            NSUInteger index = [self.RandomIndexArray indexOfObject:@(self.courentSongIndexAtScene)];
            NSUInteger end = [self.RandomIndexArray count]-1;
            if(index<end){
                NSNumber *next = [self.RandomIndexArray objectAtIndex:index+1];
                self.courentSongIndexAtScene = [next integerValue];
            }else{
                NSNumber *next = [self.RandomIndexArray objectAtIndex:0];
                self.courentSongIndexAtScene = [next integerValue];
            }
        }
            self.playingView.songIndex = self.courentSongIndexAtScene;
            [self ChangeSongInfoAtRootView];
            [self ChangeSongInfoAtPlayingView];
            [self.rootPlayer prepareToPlay];
            [self.rootPlayer play];
            break;

        default:
            break;
    }
    [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
}




#pragma mark - 播放按钮、上一首下一首和随机播放array的delegate实现

// 播放按钮点击
-(void)playButtonClick:(UIButton*)button{

    if([self.rootPlayer isPlaying]){
        [self.rootPlayer pause];
        [self.playButton setImage:[UIImage imageNamed:@"Playerplay.png"] forState:UIControlStateNormal];
        [self.playingView.playButton setImage:[UIImage imageNamed:@"Playerplay.png"] forState:UIControlStateNormal];
        self.isSongPlayingAtRootView = NO;
        self.playingView.isSongPlayingAtPlayView = NO;
    }else{
        [self.rootPlayer play];
        [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
        [self.playingView.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
        self.isSongPlayingAtRootView = YES;
        self.playingView.isSongPlayingAtPlayView = YES;
    }
    
}
//上一首下一首按钮delegate实现
- (void)preButtonPress{
    switch (self.playmodeAtRootView) {

        case Random:{
            NSUInteger index = [self.RandomIndexArray indexOfObject:@(self.courentSongIndexAtScene)];
            NSUInteger end = [self.RandomIndexArray count]-1;
            if(index>0){
                NSNumber *pre = [self.RandomIndexArray objectAtIndex:index-1];
               self.courentSongIndexAtScene = [pre integerValue];
            }else{
                NSNumber *pre = [self.RandomIndexArray objectAtIndex:end];
                self.courentSongIndexAtScene = [pre integerValue];
            }

        }
            break;
            
        default:
            if(self.courentSongIndexAtScene == 0){
                self.courentSongIndexAtScene = [self.songsArrayAtScene count]-1;
            }else{
                self.courentSongIndexAtScene--;
            }
            
            break;
    }
    [self ChangeSongInfoAtRootView];
    [self ChangeSongInfoAtPlayingView];
    [self.rootPlayer prepareToPlay];
    [self.rootPlayer play];
    [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
}

- (void)nextButtonPress{
    switch (self.playmodeAtRootView) {
        case Random:{
            NSUInteger index = [self.RandomIndexArray indexOfObject:@(self.courentSongIndexAtScene)];
            NSUInteger end = [self.RandomIndexArray count]-1;
            if(index<end){
                NSNumber *next = [self.RandomIndexArray objectAtIndex:index+1];
                self.courentSongIndexAtScene = [next integerValue];
            }else{
                NSNumber *next = [self.RandomIndexArray objectAtIndex:0];
                self.courentSongIndexAtScene = [next integerValue];
            }

            
        }
            break;
            
        default:
            if(self.courentSongIndexAtScene == [self.songsArrayAtScene count]-1){
                self.courentSongIndexAtScene = 0;
            }else{
                self.courentSongIndexAtScene++;
            }
            break;
    }
    [self ChangeSongInfoAtRootView];
    [self ChangeSongInfoAtPlayingView];
    [self.rootPlayer prepareToPlay];
    [self.rootPlayer play];
    [self.playButton setImage:[UIImage imageNamed:@"Playerstop.png"] forState:UIControlStateNormal];
}

// 将随机歌曲编号重新编排
- (void)MakeArrayRandom{
    NSUInteger count = [self.RandomIndexArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger remainingCount = count - i;
        NSUInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        [self.RandomIndexArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

// 随机编排
- (void)loopRandomSelected{
    [self MakeArrayRandom];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
