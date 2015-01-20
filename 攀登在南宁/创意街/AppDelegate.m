//
//  AppDelegate.m
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTextViewCtl.h"
#import "MainTxtImgViewCtl.h"
#import "MainVideoViewCtl.h"
#import "MainMeViewCtl.h"
#import "IQKeyboardManager.h"
#import "SUNLeftMenuViewController.h"
#import "SUNViewController.h"

static const CGFloat kPublicLeftMenuWidth = 280.0f;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] setEnable:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MainMeViewCtl *leftVC = [[MainMeViewCtl alloc]
                                         initWithNibName:@"MainMeView"
                                         bundle:nil];
//    SUNLeftMenuViewController *leftVC = [[SUNLeftMenuViewController alloc]
//                                         initWithNibName:@"SUNLeftMenuViewController"
//                                         bundle:nil];
    SUNViewController * drawerController = [[SUNViewController alloc]
                                            initWithCenterViewController:leftVC.navSlideSwitchVC
                                            leftDrawerViewController:leftVC
                                            rightDrawerViewController:nil];
    
    [drawerController setMaximumLeftDrawerWidth:IphoneWidth*2/3];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
//    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//        MMDrawerControllerDrawerVisualStateBlock block;
//        block = [MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:2.0];
//        block(drawerController, drawerSide, percentVisible);
//    }];
    
    [self.window setRootViewController:drawerController];
    [self.window makeKeyAndVisible];
    [[Common shareCommon] isFirstLaunch];
    
    [[TencentOAuth alloc] initWithAppId:AppQqID andDelegate:self];
    [WXApi registerApp:AppWxId];
    [self initData];
    return YES;
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    _mainTextViewCtl    = [[MainTextViewCtl alloc] initWithNibName:@"MainTextView" bundle:nil];
//    _mainMeViewCtl      = [[MainMeViewCtl alloc] initWithNibName:@"MainMeView" bundle:nil];
//    _mainTxtImgViewCtl  = [[MainTxtImgViewCtl alloc] initWithNibName:@"MainTxtImgView" bundle:nil];
//    _mainVideoViewCtl   = [[MainVideoViewCtl alloc] initWithNibName:@"MainVideoView" bundle:nil];
//    
//    UINavigationController  * tTextNavCtl   = [[UINavigationController alloc] initWithRootViewController:_mainTextViewCtl];
//    UINavigationController  * tMeNavCtl     = [[UINavigationController alloc] initWithRootViewController:_mainMeViewCtl];
//    UINavigationController  * tTxtImgNavCtl = [[UINavigationController alloc] initWithRootViewController:_mainTxtImgViewCtl];
//    UINavigationController  * tVideoNavCtl  = [[UINavigationController alloc] initWithRootViewController:_mainVideoViewCtl];
//
//    
//    UITabBarItem *tabItem1 = [[UITabBarItem alloc] initWithTitle:@"图文" image:[UIImage imageNamed:@"Profile_filter_ImageIcon"] tag:1];
//    UITabBarItem *tabItem2 = [[UITabBarItem alloc] initWithTitle:TxtTitleName image:[UIImage imageNamed:@"Profile_filter_contentIcon"] tag:2];
//    UITabBarItem *tabItem3 = [[UITabBarItem alloc] initWithTitle:@"视频" image:[UIImage imageNamed:@"tabbarVideo"] tag:3];
//    UITabBarItem *tabItem4 = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"tabbarSetup"] tag:4];
//    
//    tTxtImgNavCtl.tabBarItem    = tabItem1;
//    tTextNavCtl.tabBarItem      = tabItem2;
//    tVideoNavCtl.tabBarItem     = tabItem3;
//    tMeNavCtl.tabBarItem        = tabItem4;
//    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//    {
//        //          [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:26.0f/255.0f green:174.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
//    }
//    
//    
//    //    [nav1.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar_bg"] forBarMetrics:UIBarMetricsDefaultPrompt];
//    
//    
//    tMeNavCtl.navigationBar.tintColor = [UIColor colorWithRed:26.0f/255.0f green:174.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
//    tTxtImgNavCtl.navigationBar.tintColor = [UIColor colorWithRed:26.0f/255.0f green:174.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
//    tTextNavCtl.navigationBar.tintColor = [UIColor colorWithRed:26.0f/255.0f green:174.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
//    tVideoNavCtl.navigationBar.tintColor = [UIColor colorWithRed:26.0f/255.0f green:174.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
////    nav5.navigationBar.tintColor = [UIColor colorWithRed:26.0f/255.0f green:174.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
//    
//    //    nav5.navigationBarHidden = YES;
//    
//    _tabBarController = [[UITabBarController alloc] init];
//    _tabBarController.viewControllers = [NSArray arrayWithObjects:tTxtImgNavCtl,tTextNavCtl,tVideoNavCtl,tMeNavCtl,nil];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    self.window.rootViewController = _tabBarController;
//    [self.window makeKeyAndVisible];
//    [[Common shareCommon] isFirstLaunch];
//    
//    [[TencentOAuth alloc] initWithAppId:AppQqID andDelegate:self];
//    [WXApi registerApp:AppWxId];
//    [self initData];
//    return YES;
}

- (void)initData
{
    NSMutableArray  * tCommentAry = [UserDefalut objectForKey:ZanCommentAry];
    if (tCommentAry == nil) {
        NSMutableArray  * tAry = [[NSMutableArray alloc] init];
        [UserDefalut setObject:tAry forKey:ZanCommentAry];
    }
    
    NSMutableArray  * tZanAry = [UserDefalut objectForKey:ZanThemAry];
    if (tZanAry == nil) {
        NSMutableArray  * tAry = [[NSMutableArray alloc] init];
        [UserDefalut setObject:tAry forKey:ZanThemAry];
    }
    
    NSMutableArray  * tCaiAry = [UserDefalut objectForKey:CaiThemAry];
    if (tCaiAry == nil) {
        NSMutableArray  * tAry = [[NSMutableArray alloc] init];
        [UserDefalut setObject:tAry forKey:CaiThemAry];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //    NSString *strUrl = @"http://dajdklajdka?";
    //    url = [NSURL URLWithString:strUrl];
    
#if __QQAPI_ENABLE__
    [QQApiInterface handleOpenURL:url delegate:self];
#endif
    
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Where from" message:url.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        //[alertView show];
        return [TencentOAuth HandleOpenURL:url];
    }
    
    if (YES == [WXApi handleOpenURL:url delegate:self]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#if __QQAPI_ENABLE__
    [QQApiInterface handleOpenURL:url delegate:self];
#endif
    
    if (YES == [WXApi handleOpenURL:url delegate:self]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}


-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
        [alert release];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = @"sdfsdfds";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ShareToWxResultNotification object:[NSString stringWithFormat:@"%d",resp.errCode]];

    }else if ([resp isKindOfClass:[SendMessageToQQResp class]]){
        QQBaseResp * resp1 = (QQBaseResp *)resp;
        if (resp1.errorDescription == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ShareToQQResultNotification object:[NSString stringWithFormat:@"%d",0]];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:ShareToQQResultNotification object:[NSString stringWithFormat:@"%d",-2]];
        }
        
    }
}


- (BOOL)onTencentReq:(TencentApiReq *)req{
    NSLog(@"%@",req);
    return YES;
}

/**
 * 响应请求答复 当前版本只支持腾讯业务相应第三方的请求答复
 */
- (BOOL)onTencentResp:(TencentApiResp *)resp
{
    NSLog(@"%@",resp);
    return YES;
}

@end
