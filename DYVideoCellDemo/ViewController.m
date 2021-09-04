//
//  ViewController.m
//  DYVideoCellDemo
//
//  Created by git on 2021/9/4.
//

#import "ViewController.h"
#import "DYVideoViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DYVideoViewController *videoVC = [[DYVideoViewController alloc] init];
    [self.navigationController pushViewController:videoVC animated:YES];
}

@end
