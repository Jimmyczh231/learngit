//
//  UserManager2.m
//  写法重现
//
//  Created by jimmy on 3/28/23.
//

#import "UserManager2.h"

@implementation UserManager2

+ (instancetype)sharedInstance {
    static UserManager2 *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserManager2 alloc] init];
    });
    return instance;
}


- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password favoriteSongs:(NSArray *)favoriteSongs{
    User *newUser = [[User alloc] initWithUsername:username password:password favoriteSongs:[NSArray array]];

    // 将新用户模型保存到本地
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:newUser requiringSecureCoding:YES error:nil];
    NSUserDefaults *userDefaults =  [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userData forKey:newUser.username];

    // 设置为当前用户
    [userDefaults setInteger:1000  forKey:@"testing2"];
    [userDefaults synchronize];
    
    
}


- (User *)loginWithUsername:(NSString *)username password:(NSString *)password{

    User *loginUser = [[User alloc]init];

    //从NSUserDefaults读取对应的Data
    NSData *userData = [[NSUserDefaults standardUserDefaults]objectForKey:username];

    //将它解码为User的对象，并赋给当前用户
    loginUser = [NSKeyedUnarchiver unarchivedObjectOfClass:[User class] fromData:userData error:nil];

    //密码正确的处理
    if(loginUser &&[loginUser.password isEqualToString:password]){
        return loginUser;
    }else{
        return nil;
    }
}


- (void)saveCurrentUser:(User *)user andwith:(NSArray*)upDatedArray{
    //将新的歌曲列表存储到user上（保证存储时候的歌曲是正确的）
    //转码
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:YES error:nil];
    //存储
    NSUserDefaults *userDefaults =  [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userData forKey:user.username];

    [userDefaults synchronize];
}

// 喜欢歌曲的时候更新user信息
- (void)updateuser:(User*)user with:(NSDictionary*)newSongs{
    NSMutableArray *temp = [user.favoriteSongs mutableCopy];
    [temp addObject:newSongs];
    user.favoriteSongs = [temp copy];
}

// 取消喜欢歌曲的时候更新user信息
- (void)updateuser:(User*)user bydelete:(NSDictionary*)Songs{
    NSMutableArray *tempArray = [user.favoriteSongs mutableCopy];
    for(NSDictionary* dict in tempArray){
        if([[dict objectForKey:@"filename"] isEqualToString:[Songs objectForKey:@"filename"]]){
            [tempArray removeObject:dict];
            
        }
    }
    user.favoriteSongs = [tempArray copy];
}



@end
