//
//  SUNSlideSwitchDemoViewController.m
//  SUNCommonComponent
//
//  Created by 麦志泉 on 13-9-4.
//  Copyright (c) 2013年 中山市新联医疗科技有限公司. All rights reserved.
//

#import "SUNSlideSwitchDemoViewController.h"
#import "UIViewController+MMDrawerController.h"
//#import "SUNListViewController.h"

@interface SUNSlideSwitchDemoViewController ()

@end

@implementation SUNSlideSwitchDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = AppName;
    self.navigationController.navigationBar.backgroundColor=[UIColor clearColor];
    self.slideSwitchView.tabItemNormalColor = [SUNSlideSwitchView colorFromHexRGB:@"868686"];
    self.slideSwitchView.tabItemSelectedColor = [SUNSlideSwitchView colorFromHexRGB:@"bb0b15"];
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                                        stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    
    
    self.vc1 = [[MainTxtImgViewCtl alloc] initWithNibName:@"MainTxtImgView" bundle:nil];
    self.vc1.title = @"图文";
    self.vc1.delegate = self;
    
    self.vc2 = [[MainVideoViewCtl alloc] initWithNibName:@"MainVideoView" bundle:nil];
    self.vc2.title = @"视频";
    self.vc2.delegate = self;
    
    self.vc3 = [[MainTextViewCtl alloc] initWithNibName:@"MainTextView" bundle:nil];
    self.vc3.title = @"精华";
    
    self.vc4 = [[MainMeViewCtl alloc] initWithNibName:@"MainMeView" bundle:nil];
    self.vc4.title = @"话题";
    self.vc4.delegate = self;

    
    UIButton *rightSideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightSideButton setImage:[UIImage imageNamed:@"icon_rightarrow.png"] forState:UIControlStateNormal];
    [rightSideButton setImage:[UIImage imageNamed:@"icon_rightarrow.png"]  forState:UIControlStateHighlighted];
    rightSideButton.frame = CGRectMake(0, 0, 20.0f, 30.0f);
    rightSideButton.userInteractionEnabled = NO;
    self.slideSwitchView.rigthSideButton = rightSideButton;
    
    [self.slideSwitchView buildUI];
    
    [self buildNavBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
}

- (void)buildNavBtn
{
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [tRightBtn addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
    [tRightBtn setImage:[UIImage imageNamed:@"comment-bar-write-icon"] forState:UIControlStateNormal];
    
    UIButton * tLeftBtn= [[UIButton alloc] initWithFrame:CGRectMake(-10, 0, 50, 50)];
    [tLeftBtn addTarget:self action:@selector(clickLeft) forControlEvents:UIControlEventTouchUpInside];
    [tLeftBtn setImage:[UIImage imageNamed:@"tabbarSetup"] forState:UIControlStateNormal];
    
    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
    UIBarButtonItem *_LeftBtn = [[UIBarButtonItem alloc] initWithCustomView:tLeftBtn];
    
    
    [_RightBtn setCustomView:tRightBtn];
    
    self.navigationItem.leftBarButtonItem   = _LeftBtn;
    self.navigationItem.rightBarButtonItem  = _RightBtn;
}

- (void)clickLeft
{
    SUNViewController *drawerController = (SUNViewController *)self.navigationController.mm_drawerController;
    [drawerController showLeftMenu];
//    UIPanGestureRecognizer * regist = [[UIPanGestureRecognizer alloc] initWithTarget:<#(id)#> action:<#(SEL)#>]
//    [drawerController panGestureCallback:panParam];
}

- (void)clickRight
{
//    [self getThem:@"0"];
//    [self scrollToTop:YES];
}

- (void)pushViewCtl:(UIViewController *)viewCtl{
    [self.navigationController pushViewController:viewCtl animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:CannotScrollNotification
                                                        object:nil];
    
}

- (void)pushViewCtlMe:(UIViewController *)viewCtl
{
//    [_slideSwitchView showAllView];
    [self beginAppearanceTransition:YES animated:YES];
    [self pushViewCtl:viewCtl];
}

#pragma mark - 滑动tab视图代理方法

- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 4;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {
        return self.vc1;
    } else if (number == 1) {
        return self.vc2;
    } else if (number == 2) {
        return self.vc3;
    } else if (number == 3) {
        return self.vc4;
    } else {
        return nil;
    }
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer *)panParam
{
    SUNViewController *drawerController = (SUNViewController *)self.navigationController.mm_drawerController;
    [drawerController panGestureCallback:panParam];
//    UIView * view1 = [[UIView alloc] initWithFrame:[ UIScreen mainScreen ].bounds];
//    [view1 setBackgroundColor:[UIColor blackColor]];
//    [self.view addSubview:view1];
    
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    if (number != 1) {
        [self.vc2 stopVideoAndRefresh];
    }
//    SUNListViewController *vc = nil;
//    if (number == 0) {
//        vc = self.vc1;
//    } else if (number == 1) {
//        vc = self.vc2;
//    } else if (number == 2) {
//        vc = self.vc3;
//    } else if (number == 3) {
//        vc = self.vc4;
//    }
//    [vc viewDidCurrentView];
}

#pragma mark - 内存报警

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
