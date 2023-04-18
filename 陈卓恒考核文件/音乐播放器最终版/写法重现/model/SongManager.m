//
//  SongManager.m
//  写法重现
//
//  Created by jimmy on 4/5/23.
//

#import "SongManager.h"

@interface SongManager ()<AVAudioPlayerDelegate>


@end

@implementation SongManager

+ (instancetype)sharedInstance {
    static SongManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SongManager alloc] init];
    });
    return instance;
}

- (void)SongManagerLoadedWithFinishBlock:(SongManagerFinishBlock)finishBlock{
    // 获取文件夹地址
    NSString *folderName = @"AudioFile"; // 文件夹名称
    NSString *folderPath = [[NSBundle mainBundle] pathForResource:folderName ofType:nil];
    if (folderPath) {
        NSLog(@"Folder path: %@", folderPath);
    } else {
        NSLog(@"Folder not found.");
    }
    
    // 用于返回的array和mutablearray
    NSArray *songsDataArray = [NSArray array];
    NSMutableArray *songsMutableDataArray = [songsDataArray mutableCopy];
    
    // 用file manager遍历文件夹并将文件名称存在files中
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:folderPath error:&error];
    
    // 遍历file中的所有文件，判断是否为音频文件
    for (NSString *filename in files) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
        if ([asset.tracks.firstObject.mediaType isEqualToString:AVMediaTypeAudio]) {
            
            // 调用AVAsset，将里面的歌名、歌手名称和专辑封面装入dictionary
            NSArray *metadata = [asset commonMetadata];
            NSDictionary *songsdataDict = [NSDictionary dictionary];
            NSMutableDictionary *songsdataDictMutable = [songsdataDict mutableCopy];
            AVPlayerItem *song = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filePath]];
            NSArray *metadatalyric = song.asset.metadata;
            NSMutableArray *key = [NSMutableArray array];
            for (AVMetadataItem *item in metadatalyric) {
                if(item.key){
                    [key addObject:item.key];
                }
                //                歌曲的名称
                if ([item.commonKey isEqualToString:@"title"]) {
                    NSString *title = (NSString *)item.value;
                    [songsdataDictMutable setObject:title forKey:@"title"];
                }
                //                歌曲的歌手
                else if ([item.commonKey isEqualToString:@"artist"]) {
                    NSString *artist = (NSString *)item.value;
                    [songsdataDictMutable setObject:artist forKey:@"artist"];
                }
                
                //                歌曲的封面
                else if ([item.commonKey isEqualToString:@"artwork"]) {
                    NSData *imageData = (NSData *)item.value;
                    UIImage *image = [UIImage imageWithData:imageData];
                    [songsdataDictMutable setObject:image forKey:@"albumArt"];
                }
                
                //                歌曲的歌词
                else if([[NSString stringWithFormat:(@"%@",item.key)] isEqualToString:@"USLT"]){
                    NSString *lyrics = (NSString *)item.value;
                    [songsdataDictMutable setObject:lyrics forKey:@"lyrics"];
                }
            }
            [songsdataDictMutable setObject:filename forKey:@"filename"];
            //转回不可变dictionary
            songsdataDict = [songsdataDictMutable copy];
            //将dictionary装入mutablearray中
            [songsMutableDataArray addObject:songsdataDict];
        }
    }
    //返回生成的array
    songsDataArray = [songsMutableDataArray copy];
    
    if(finishBlock){
        finishBlock(songsDataArray != nil,songsDataArray.copy);
    }


}

- (NSArray*)CreateLyricArraywith:(NSString*)lyricsString{
    
    NSArray *lyricArray = [NSArray array];
    NSMutableArray *lyricsmutableArray = [lyricArray mutableCopy];
    
    // 将歌词按照结尾回车符分开
    NSArray *lyricsLines = [lyricsString componentsSeparatedByString:@"\n"];
    for (NSString *lyricsLine in lyricsLines) {
        if ([lyricsLine hasPrefix:@"["]) {
            // 获得歌词时间信息的Range
            NSRange timeRange = [lyricsLine rangeOfString:@"]"];
            if (timeRange.location != NSNotFound) {
                
                // 歌词时间信息
                NSString *timeString = [lyricsLine substringWithRange:NSMakeRange(1, timeRange.location - 1)];
                NSArray *timeComponents = [timeString componentsSeparatedByString:@":"];
                NSTimeInterval timeInterval = [timeComponents[0] doubleValue] * 60 + [timeComponents[1] doubleValue];
                
                // 歌词歌词信息
                NSString *lyrics = [lyricsLine substringFromIndex:timeRange.location + 1];
                NSMutableDictionary *lyricsDict = [NSMutableDictionary dictionary];
                
                // 写入dictionary中
                [lyricsDict setObject:@(timeInterval) forKey:@"time"];
                [lyricsDict setObject:lyrics forKey:@"lyrics"];
                [lyricsmutableArray addObject:lyricsDict];
            }
        }
    }
    // 返回装有歌词信息的列表
    lyricArray = [lyricsmutableArray copy];
    return lyricArray;
}


@end
