//
//  UserViewController.m
//  写法重现
//
//  Created by jimmy on 3/27/23.
//

#import "UserViewController.h"
#import "User.h"
#import "UserManager.h"
#import "UserLikedSongsTableViewController.h"

#import "UserManager2.h"


@interface UserViewController ()<songLikeable>

@property(nonatomic ,strong) UITextField *UsernameTextfield;
@property(nonatomic ,strong) UITextField *PasswordTextfield;
@property(nonatomic ,strong) User *currentUser;
@property(nonatomic ,strong) NSArray *currentUserFavoriteSong;
@property(nonatomic ,strong) UserManager *datamanager;
@property(nonatomic ,strong) UserManager2 *datamanager2;
@property(nonatomic ,strong) UIButton *registerButton;
@property(nonatomic ,strong) UIButton *loginButton;
@property(nonatomic ,strong) UserLikedSongsTableViewController *likedSongs;



@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化用户名输入框
    [self.view addSubview:({
        self.UsernameTextfield = [[UITextField alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-250)/2, self.view.bounds.size.height*(3.0/10), 250, 40)];
        self.UsernameTextfield.placeholder = @"Please put in Username";
        self.UsernameTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.UsernameTextfield.backgroundColor = [UIColor lightGrayColor];
        self.UsernameTextfield.layer.cornerRadius = 20;
        self.UsernameTextfield.layer.masksToBounds = YES;
        self.UsernameTextfield;
    })];
    
    // 初始化密码输入框
    [self.view addSubview:({
        self.PasswordTextfield = [[UITextField alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-250)/2, self.view.bounds.size.height*(4.0/10), 250, 40)];
        self.PasswordTextfield.placeholder = @"Please put in Password";
        self.PasswordTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.PasswordTextfield.backgroundColor = [UIColor lightGrayColor];
        self.PasswordTextfield.layer.cornerRadius = 20;
        self.PasswordTextfield.layer.masksToBounds = YES;
        self.PasswordTextfield;
    })];
    // 1 是filemanager的版本 2 是NSUserDefault的版本
    self.datamanager = [[UserManager alloc]init];
    self.datamanager2 = [[UserManager2 alloc]init];
    
    // 添加注册按钮
    self.registerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/4, self.view.bounds.size.height/1.9, 50, 40)];
    [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.registerButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:5/255.0 blue:5/255.0 alpha:1];
    self.registerButton.layer.cornerRadius = 20;
    self.registerButton.layer.masksToBounds = YES;
    [self.view addSubview:self.registerButton];
    
    // 添加登录按钮
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width/5)*3, self.view.bounds.size.height/1.9, 50, 40)];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:5/255.0 blue:5/255.0 alpha:1];
    self.loginButton.layer.cornerRadius = 20;
    self.loginButton.layer.masksToBounds = YES;
    [self.view addSubview:self.loginButton];

    // 喜欢歌曲列表的初始化，在未登录的情况下隐藏
    self.likedSongs = [[UserLikedSongsTableViewController alloc]initWithStyle:UITableViewStylePlain];
    [self.view addSubview:self.likedSongs.tableView];
    

}

// 登陆按钮点击的逻辑
- (void)loginButtonTapped:(id)sender{
    //filemanager版本的代码
//    self.currentUser = [self.datamanager loginWithUsername:username password:password];
//
//    if(!self.currentUser){
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"登陆失败" preferredStyle:  UIAlertControllerStyleAlert];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
//                                                               style:UIAlertActionStyleDefault
//                                                             handler:nil];
//                [alert addAction:okAction];
//                [self presentViewController:alert animated:YES completion:nil];
//                 return;
//    }else{
//        self.UsernameTextfield.hidden =YES;
//        self.PasswordTextfield.hidden =YES;
////        [self.tableView reloadData];
//    }
    

        NSString *username = self.UsernameTextfield.text;
        NSString *password = self.PasswordTextfield.text;
        self.currentUser = [self.datamanager2 loginWithUsername:username password:password];
    
        if(!self.currentUser){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"登陆失败" preferredStyle:  UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:nil];
                     return;
        }else{
            self.likedSongs.currentUser = self.currentUser;
            [self.navigationController pushViewController:self.likedSongs animated:YES];
        }
}

// 注册按钮点击的逻辑
- (void)registerButtonTapped:(id)sender {
    NSString *username = self.UsernameTextfield.text;
    NSString *password = self.PasswordTextfield.text;
    
    //filemanager版本的代码
//    if([self.datamanager registerUserWithUsername:username password:password favoriteSongs:[NSArray array]]){
//        self.currentUser = [self.datamanager loginWithUsername:username password:password];
//    }else{
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"注册失败" preferredStyle:  UIAlertControllerStyleAlert];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
//                                                       style:UIAlertActionStyleDefault
//                                                     handler:nil];
//        [alert addAction:okAction];
//        [self presentViewController:alert animated:YES completion:nil];
//    }
//
//
    
    [self.datamanager2 registerUserWithUsername:username password:password favoriteSongs:[NSArray array]];
    self.currentUser = [self.datamanager2 loginWithUsername:username password:password];
    
    if(!self.currentUser){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"登陆失败" preferredStyle:  UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
                 return;
    }else{
        self.likedSongs.currentUser = self.currentUser;
        [self.navigationController pushViewController:self.likedSongs animated:YES];
    }
    
}

// 选择喜欢的逻辑
- (void)addFavorSongToUserwith:(NSDictionary*)songFilename{
    [self.datamanager2 updateuser:self.currentUser with:songFilename];
    self.currentUserFavoriteSong = self.currentUser.favoriteSongs;
    [self.datamanager2 saveCurrentUser:self.currentUser andwith:self.currentUserFavoriteSong];
    self.likedSongs.currentUser = self.currentUser;
    [self.likedSongs.tableView reloadData];
}

// 取消喜欢的逻辑
- (void)deleteFavorSongfromUserwith:(NSDictionary*)songFilename{
    [self.datamanager2 updateuser:self.currentUser bydelete:songFilename];
    self.currentUserFavoriteSong = self.currentUser.favoriteSongs;
    [self.datamanager2 saveCurrentUser:self.currentUser andwith:self.currentUserFavoriteSong];
    self.likedSongs.currentUser = self.currentUser;
    [self.likedSongs.tableView reloadData];
}

// 判断这首歌是否被喜欢
- (BOOL)isSonglikedWith:(nonnull NSDictionary *)songFile {
    NSString *filename = [songFile objectForKey:@"filename"];
    for(NSDictionary *dict in self.currentUser.favoriteSongs){
        if([[dict objectForKey:@"filename"] isEqualToString:filename]){
            return YES;
        }
    }
    return NO;
}

// 判断是否登陆
- (BOOL)isUserLogin {
    BOOL is;
    if(self.currentUser){
        is = YES;
    }else{
        is = NO;
    }
    return is;
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
