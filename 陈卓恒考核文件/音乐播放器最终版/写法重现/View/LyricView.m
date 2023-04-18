//
//  LyricView.m
//  写法重现
//
//  Created by jimmy on 4/9/23.
//

#import "LyricView.h"


@interface LyricView()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong ,readwrite)UIView *backgroundView;
@property(nonatomic, strong ,readwrite)UITableView *lyrictablewview;
@property(nonatomic, strong ,readwrite)NSArray *lyricArrayWithDict;

@end

@implementation LyricView

- (instancetype)initWithFrame:(CGRect)frame lyric:(NSArray *)lyricArray {
    self = [super initWithFrame:frame];
    if (self) {
        // 传入歌词 array
        self.lyricArrayWithDict = lyricArray;
        
        // 创建背景 View
        self.backgroundView = [[UIImageView alloc] initWithFrame:frame];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.5;
        [self addSubview:self.backgroundView];
        
        // 创建歌词 Tableview
        self.lyrictablewview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 80, frame.size.height*12/15)];
        self.lyrictablewview.center = self.center;
        self.lyrictablewview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        self.lyrictablewview.delegate = self;
        self.lyrictablewview.dataSource = self;
        [self addSubview:self.lyrictablewview];
        

        // 给背景 backgroundveiw 添加 GestureRecognizer 用于返回
        self.backgroundView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTapGesture:)];
        [self.backgroundView addGestureRecognizer:tapGestureRecognizer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"TimeToChangelyric" object:nil];

    }
    return self;
}

// 背景的 GestureRecognizer 的方法实现
- (void)handleBackgroundTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self removeFromSuperview];
    }
}

// 接收播放时间信息
- (void)handleNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval time = [userInfo[@"time"] doubleValue];
    [self scrollToLyricAtTime:time];
}

// 判断歌词应该滚动到的位置
- (void)scrollToLyricAtTime:(NSTimeInterval)time {
    __block NSInteger targetIndex = -1;
    [self.lyricArrayWithDict enumerateObjectsUsingBlock:^(NSDictionary *lyricDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval lyricTime = [lyricDict[@"time"] doubleValue];
        if (lyricTime > time) {
            *stop = YES;
        } else {
            targetIndex = idx;
        }
    }];
    if (targetIndex >= 0) {
        [self scrollToLyricAtIndex:targetIndex];
    }
}

// 将歌词滚动到对应的位置
- (void)scrollToLyricAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.lyrictablewview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lyricArrayWithDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LyricCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByClipping;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor orangeColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSDictionary *lyricDict = self.lyricArrayWithDict[indexPath.row];
    cell.textLabel.text = lyricDict[@"lyrics"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *lyricDict = self.lyricArrayWithDict[indexPath.row];
    NSTimeInterval timeInterval = [lyricDict[@"time"] doubleValue];
    
    // 发送通知
    NSDictionary *userInfo = @{@"timeInterval": @(timeInterval)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LyricDidSelectNotification" object:nil userInfo:userInfo];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateLyricViewWith:(nonnull NSArray *)LyricArray {
    self.lyricArrayWithDict = LyricArray;
    [self.lyrictablewview reloadData];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/






@end
