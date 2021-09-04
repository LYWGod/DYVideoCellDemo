//
//  DYVideoViewController.m
//  DYVideoCellDemo
//
//  Created by git on 2021/9/4.
//

#import "DYVideoViewController.h"
#import "DYVideoCell.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

static NSUInteger kDataSourceCount = 80;

@interface DYVideoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger    currentIndex;

@end

@implementation DYVideoViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentIndex = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTouchBegin) name:StatusBarTouchBeginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)statusBarTouchBegin {
    _currentIndex = 0; //KVO
}

- (void)applicationBecomeActive {
    DYVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
//    if(!_isCurPlayerPause) {
//        [cell.playerView play];
//    }
}

- (void)applicationEnterBackground {
    DYVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
//    _isCurPlayerPause = ![cell.playerView rate];
//    [cell.playerView pause];
}

//观察currentIndex变化
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentIndex"]) {
        //获取当前显示的cell
        DYVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        //用cell控制相关视频播放
        
    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)dealloc {
    [_tableView.layer removeAllAnimations];
   
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"currentIndex"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initNavigationBarTransparent];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)initNavigationBarTransparent {
    [self setNavigationBarTitleColor:[UIColor whiteColor]];
    [self setNavigationBarBackgroundImage:[UIImage new]];
    [self setNavigationBarShadowImage:[UIImage new]];
    [self setStatusBarStyle:UIStatusBarStyleLightContent];
    [self initLeftBarButton:@"icon_titlebar_whiteback"];
    self.view.backgroundColor = [UIColor whiteColor];
}

//设置到含量标题
- (void)setNavigationBarTitleColor:(UIColor *)color {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:color}];
}

//导航栏透明
- (void) setNavigationBarBackgroundImage:(UIImage *)image {
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}


//状态栏样式
- (void)setStatusBarStyle:(UIStatusBarStyle)style {
    [UIApplication sharedApplication].statusBarStyle = style;
}

//导航栏暗影透明
- (void)setNavigationBarShadowImage:(UIImage *)image {
    [self.navigationController.navigationBar setShadowImage:image];
}

//返回按钮
- (void)initLeftBarButton:(NSString *)imageName {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kDataSourceCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //填充视频数据
    DYVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DYVideoCell.class)];
    cell.backgroundColor = [self randomColor];
    cell.currentIndex = indexPath.row;
    return cell;
}


- (UIColor *)randomColor {
    CGFloat hue = (arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        //UITableView禁止响应其他滑动手势
        scrollView.panGestureRecognizer.enabled = NO;
        
        if(translatedPoint.y < -50 && self.currentIndex < (kDataSourceCount - 1)) {
            self.currentIndex ++;   //向下滑动索引递增
        }
        if(translatedPoint.y > 50 && self.currentIndex > 0) {
            self.currentIndex --;   //向上滑动索引递减
        }
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
                                //UITableView滑动到指定cell
                                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            } completion:^(BOOL finished) {
                                //UITableView可以响应其他滑动手势
                                scrollView.panGestureRecognizer.enabled = YES;
                            }];
        
    });
}


- (void)setupUI
{
    [self.view addSubview:self.tableView];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view addSubview:self.tableView];
//        self.data = self.awemes;
        [self.tableView reloadData];
        
        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:curIndexPath atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:NO];
        [self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    });
    
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT * 5)];
        _tableView.contentInset = UIEdgeInsetsMake(SCREEN_HEIGHT, 0, SCREEN_HEIGHT * 3, 0);
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        //注册cell XIB创建
        [self.tableView registerClass:DYVideoCell.class forCellReuseIdentifier:NSStringFromClass(DYVideoCell.class)];
    }
    return _tableView;
}

@end
