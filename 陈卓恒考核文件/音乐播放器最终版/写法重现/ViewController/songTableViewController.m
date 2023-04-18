//
//  songTableViewController.m
//  写法重现
//
//  Created by jimmy on 3/20/23.
//

#import "songTableViewController.h"
#import "DetailViewController.h"

@interface songTableViewController ()<UITableViewDelegate,UITableViewDataSource,Passable,UISearchBarDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayerall;
@property (nonatomic, strong) NSArray *searchResultIndex;
@property (nonatomic, strong) NSArray *filteredSongList; // 根据搜索条件过滤出的歌曲
@property (nonatomic, strong) UISearchBar *searchView;
@property (nonatomic) UITableViewStyle tableViewStyle;
@property (nonatomic) NSInteger songindex;

@end

@implementation songTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建UITableView并设置代理
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.audioPlayerall = [AVAudioPlayer new];
    
    //初始化searchbar
    self.searchView = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    self.searchView.delegate = self;
    self.tableView.tableHeaderView = self.searchView;
    self.filteredSongList = self.songsMutableArray;
    
    [self.tableView reloadData];
    [self.searchView becomeFirstResponder];
    [self.view addSubview:self.searchView];
}




#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredSongList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    NSDictionary *songsInfoDict = [self.filteredSongList objectAtIndex:indexPath.row];
    
    // 歌名
    NSString *title = [songsInfoDict objectForKey:@"title"];
    if(title){
    }else{
        title = [songsInfoDict objectForKey:@"filename"];
    }
    
    // 歌手
    NSString *artist = [songsInfoDict objectForKey:@"artist"];
    
    // 封面
    UIImage *albumArt = [songsInfoDict objectForKey:@"albumArt"];
    
    // 将信息写入cell的标题、子标题和图片
    cell.textLabel.text = [NSString stringWithFormat:title, indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:artist, indexPath.row];
    cell.imageView.image = albumArt;

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSLog(@"你点击了");
//    NSLog(@"%ld",self.songindex);
    self.songindex = [self.songsMutableArray indexOfObject: [self.filteredSongList objectAtIndex:indexPath.row]];
    [self.songTableViewdelegate passSongIndex:self.songindex];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.filteredSongList = self.songsMutableArray;
    } else {
        // 根据搜索框输入的内容，过滤出符合条件的歌曲
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ OR artist CONTAINS[cd] %@ OR filename CONTAINS[cd] %@" , searchText, searchText ,searchText];
        self.filteredSongList = [self.songsMutableArray filteredArrayUsingPredicate:predicate];
        // 存储符合条件的歌曲在原数组中的索引
    }
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchView becomeFirstResponder];
}



@end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

