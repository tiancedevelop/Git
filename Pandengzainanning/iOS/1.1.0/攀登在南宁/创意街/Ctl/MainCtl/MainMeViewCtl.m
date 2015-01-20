//
//  MianMeViewCtl.m
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "MainMeViewCtl.h"
#import "MeSetupViewCtl.h"
#import "TencentOpenAPI/TencentOAuth.h"
#import "ASIFormDataRequest.h"
#import "FeedBackViewCtl.h"
#import "UIImageView+RZWebImage.h"
#import "ModifyUserInfoViewCtl.h"
#import "MyIssueThemViewCtl.h"
#import "MyTagViewCtl.h"

#import "SUNSlideSwitchDemoViewController.h"
//#import "SUNTextFieldDemoViewController.h"
#import "UIViewController+MMDrawerController.h"

@interface MainMeViewCtl ()<TencentSessionDelegate,TencentLoginDelegate>
{
    MeSetupViewCtl          * _meSetupViewCtl;
    TencentOAuth            * _tencentOAuth;
    FeedBackViewCtl         * _feedBackViewCtl;
    ModifyUserInfoViewCtl   * _modifyUserInfoViewCtl;
    MyIssueThemViewCtl      * _myIssueThemViewCtl;
    SUNSlideSwitchDemoViewController *slideSwitchVC;
    MyTagViewCtl            * _myTagViewCtl;
    
}

@end

@implementation MainMeViewCtl

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        slideSwitchVC = [[SUNSlideSwitchDemoViewController alloc] init];

        self.navSlideSwitchVC = [[UINavigationController alloc] initWithRootViewController:slideSwitchVC];
    }
    return self;
}

- (void)setupUI
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"我的";
    [self setupUI];
    [_tableView setBackgroundColor:[UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [_tableView reloadData];
}


- (void)tencentDidLogin{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        NSUserDefaults  * tUserdefaults = [NSUserDefaults standardUserDefaults];
        [tUserdefaults setObject:@"Login" forKey:IsLogin];
        [_tableView reloadData];
        //  记录登录用户的OpenID、Token以及过期时间
        NSLog(@"%@",_tencentOAuth.accessToken);
        NSString    * tUrlStr = [NSString stringWithFormat:@"%@/user/qq_login",UrlStr];
        
        NSMutableDictionary * tMutableDic =[NSMutableDictionary dictionaryWithObjectsAndKeys:_tencentOAuth.accessToken,@"access_token",_tencentOAuth.openId,@"openid",AppQqID, @"oauth_consumer_key",nil];
        [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
    }
    else
    {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

-(void)tencentDidNotNetWork
{
	NSLog(@"无网络连接，请设置网络");
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        NSLog(@"用户取消登录");
	}
	else
    {
        NSLog(@"登录失败");
	}
}


- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    
    NSMutableDictionary * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (tDic) {
        NSString    * tUserName = judgeNull([tDic objectForKey:@"name"]);
        NSString    * tUserUid = judgeNull([tDic objectForKey:@"uid"]);
        NSString    * tUserIconPath = judgeNull([tDic objectForKey:@"avatar"]);
        NSString    * tUserTelNum   = judgeNull([tDic objectForKey:@"tel_number"]);
        NSString    * tUserAddress  = judgeNull([tDic objectForKey:@"address"]);
        [UserDefalut setObject:tUserIconPath forKey:UserIconPath];
        [UserDefalut setObject:tUserName forKey:UserName];
        [UserDefalut setObject:tUserUid forKey:UserUid];
        [UserDefalut setObject:tUserTelNum forKey:UserTelNum];
        [UserDefalut setObject:tUserAddress forKey:UserAddress];
        
        [_tableView reloadData];
    }
}


- (void)GetErr:(ASIHTTPRequest *)request
{
    NSLog(@"网络连接错误");
}

- (void)pushMyCtl:(UIViewController *)viewCtl
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushViewCtl:)]) {
        [self.delegate pushViewCtl:viewCtl];
    }
}

#pragma mark - Table view data source
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tIndexSection   = [indexPath indexAtPosition:0];
    int tIndex          = [indexPath indexAtPosition:1];
    if (tIndexSection == 2) {
        if (_meSetupViewCtl == nil) {
            _meSetupViewCtl = [[MeSetupViewCtl alloc] initWithNibName:@"MeSetupView" bundle:nil];
            
        }
        [slideSwitchVC pushViewCtlMe:_meSetupViewCtl];
        [self.mm_drawerController setCenterViewController:self.navSlideSwitchVC
                                       withCloseAnimation:YES completion:nil];

    }else if (tIndexSection == 0){
        
        if ([[Common shareCommon] isLogin]) {
            if (nil == _modifyUserInfoViewCtl) {
                _modifyUserInfoViewCtl = [[ModifyUserInfoViewCtl alloc] initWithNibName:@"ModifyUserInfoView" bundle:nil];
            }
            [slideSwitchVC pushViewCtlMe:_modifyUserInfoViewCtl];
            [self.mm_drawerController setCenterViewController:self.navSlideSwitchVC
                                           withCloseAnimation:YES completion:nil];
//            [self.navigationController pushViewController:_modifyUserInfoViewCtl animated:YES];
//            [self.tabBarController.tabBar setHidden:YES];
        }else{
            
            if (![[Common shareCommon] isLogin]) {
                
                if (nil == _loginViewCtl) {
                    _loginViewCtl = [[LoginViewCtl alloc] initWithNibName:@"LoginView" bundle:nil];
                }
                [slideSwitchVC pushViewCtlMe:_loginViewCtl];
                [self.mm_drawerController setCenterViewController:self.navSlideSwitchVC
                                           withCloseAnimation:YES completion:nil];
                
            }
            
        }
    }else if (tIndexSection == 1 && tIndex == 1){
        if (_feedBackViewCtl == nil) {
            _feedBackViewCtl = [[FeedBackViewCtl alloc] initWithNibName:@"FeedBackView" bundle:nil];
        }
        [slideSwitchVC pushViewCtlMe:_feedBackViewCtl];
        [self.mm_drawerController setCenterViewController:self.navSlideSwitchVC
                                       withCloseAnimation:YES completion:nil];
//        [self.navigationController pushViewController:_feedBackViewCtl animated:YES];
//        [self.tabBarController.tabBar setHidden:YES];
    }else if (tIndexSection == 1 && tIndex == 0){
        [self.tabBarController.tabBar setHidden:YES];
        if ([[Common shareCommon] isLoginAndShowCtl:self.navigationController]) {
            if (_myIssueThemViewCtl == nil) {
                _myIssueThemViewCtl = [[MyIssueThemViewCtl alloc] initWithNibName:@"MyIssueThemView" bundle:nil];
            }
            [slideSwitchVC pushViewCtlMe:_myIssueThemViewCtl];
            [self.mm_drawerController setCenterViewController:self.navSlideSwitchVC
                                           withCloseAnimation:YES completion:nil];
//            [self.navigationController pushViewController:_myIssueThemViewCtl animated:YES];
        }
        
        
    }else if (tIndexSection == 1 && tIndex == 2)
    {
        if (![[Common shareCommon] isLogin]) {
            
            if (nil == _loginViewCtl) {
                _loginViewCtl = [[LoginViewCtl alloc] initWithNibName:@"LoginView" bundle:nil];
            }
            [slideSwitchVC pushViewCtlMe:_loginViewCtl];
            [self.mm_drawerController setCenterViewController:self.navSlideSwitchVC
                                           withCloseAnimation:YES completion:nil];
            
        }else{
            if (nil == _myTagViewCtl) {
                _myTagViewCtl = [[MyTagViewCtl alloc] initWithNibName:@"MyTagView" bundle:nil];
            }
            [slideSwitchVC pushViewCtlMe:_myTagViewCtl];
            [self.mm_drawerController setCenterViewController:self.navSlideSwitchVC
                                           withCloseAnimation:YES completion:nil];
        }
    }
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    return 1.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 3;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0) {
        return 60;
    }
    return 40;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCell";
    
    NSUInteger tIndexSection = [indexPath indexAtPosition:0];
    NSUInteger tIndex        = [indexPath indexAtPosition:1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SafeRelease(cell);
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (tIndexSection == 0) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
        imageView.frame = CGRectMake(10.f, 10.f, 40.f, 40.f);
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 20;
        
        UILabel * tLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 20)];

        if ([[Common shareCommon] isLogin]) {
            tLabel.text = [UserDefalut objectForKey:UserName];
            NSURL * tUrl = [NSURL URLWithString:[UserDefalut objectForKey:UserIconPath]];
            [imageView setWebImage:tUrl placeHolder:[UIImage imageNamed:@"icon"] downloadFlag:1];
            [imageView setTag:1];
        }else{
            tLabel.text = @"登录/注册";
        }
        
        
        [cell addSubview:imageView];
        [cell addSubview:tLabel];
    }
    
    if (tIndexSection == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (tIndex == 0) {
            cell.textLabel.text = @"我发表的";
            cell.imageView.image = [UIImage imageNamed:@"myIssue"];
        }else if(tIndex == 1){
            cell.textLabel.text = @"这软件很烂";
//            cell.detailTextLabel.text = @"我来DIY";
            cell.imageView.image = [UIImage imageNamed:@"myFeedback"];
        }else if (tIndex == 2){
            cell.textLabel.text = @"我的标签";
        }
    }else if (tIndexSection == 2){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"设置";
        cell.imageView.image = [UIImage imageNamed:@"mine-setting-icon"];
    }
    [cell setBackgroundColor:[UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:0.5]];
    return cell;
}

@end
