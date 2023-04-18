//
//  UserLikedSongsTableViewController.m
//  写法重现
//
//  Created by jimmy on 3/28/23.
//

#import "UserLikedSongsTableViewController.h"

@interface UserLikedSongsTableViewController ()<UITableViewDelegate,UITableViewDelegate>

@end

@implementation UserLikedSongsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    NSDictionary *songsInfoDict = [self.currentUser.favoriteSongs objectAtIndex:indexPath.row];
    
    //歌名
    NSString *title = [songsInfoDict objectForKey:@"title"];
    if(title){
    }else{
        title = [songsInfoDict objectForKey:@"filename"];
    }
    
    //歌手
    NSString *artist = [songsInfoDict objectForKey:@"artist"];
    
    //封面
    UIImage *albumArt = [songsInfoDict objectForKey:@"albumArt"];
    

    // 将信息写入cell的标题、子标题和图片
    cell.textLabel.text = [NSString stringWithFormat:title, indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:artist, indexPath.row];
    cell.imageView.image = albumArt;
    cell.imageView.frame = CGRectMake(0, 0, 10, 10);
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 0.0;
    cell.imageView.layer.masksToBounds = YES;

    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentUser.favoriteSongs.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *songSelected = [self.currentUser.favoriteSongs objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"likedSongSelected" object:nil userInfo:songSelected];
    
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
