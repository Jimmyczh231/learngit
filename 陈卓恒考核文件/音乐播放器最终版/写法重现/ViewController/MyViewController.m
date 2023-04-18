//
//  MyViewController.m
//  写法重现
//
//  Created by jimmy on 3/20/23.
//

#import "MyViewController.h"

@interface MyViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 创建并配置UILabel
    self.label = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = @"这是主页";
    [self.view addSubview:self.label];

    
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
