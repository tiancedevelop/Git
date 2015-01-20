//
//  LoginViewCtl.m
//  创意街
//
//  Created by ios on 14-11-26.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "LoginViewCtl.h"
#import "TencentOpenAPI/TencentOAuth.h"
#import "MBProgressHUD.h"
#import "RegistViewCtl.h"
#import "TelLoginViewCtl.h"
#import "HomeConContainViewCtl.h"
@interface LoginViewCtl ()<TencentSessionDelegate,TencentLoginDelegate>
{
    TencentOAuth        * _tencentOAuth;
    RegistViewCtl       * _registViewCtl;
    TelLoginViewCtl     * _telLoginViewCtl;
    HomeConContainViewCtl           * _homeConContainViewCtl;
    BOOL                _accessPro;
}
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation LoginViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[Common shareCommon] setBackItemImg:self];
        _accessPro = YES;
    }
    return self;
}

- (void)back:(id)sender {
    
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
}

- (void)showQqLogin:(BOOL)yesOrNo
{
    [_qqLoginBtn    setHidden:yesOrNo];
    [_lineImgView   setHidden:yesOrNo];
    [_qqLoginImgBtn setHidden:yesOrNo];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqqOpensdkSSoLogin://"]]) {
        
        [self showQqLogin:NO];
        
    }else{
        [self showQqLogin:YES];
        
    }
    
    _accessPro = YES;
    [_btn setImage:[UIImage imageNamed:@"check_green_on"] forState:UIControlStateNormal];
    if ([[Common shareCommon] isLogin]) {
        [self back:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    UIImageView     * tImgView = [[UIImageView alloc] initWithFrame:_iconImgView.frame];
    tImgView.layer.masksToBounds = YES;
    tImgView.layer.cornerRadius = _iconImgView.frame.size.width/2;
    tImgView.image = [UIImage imageNamed:@"icon"];
    [self.view addSubview:tImgView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)accessProAction:(id)sender
{
    if (_accessPro) {
        [_btn setImage:[UIImage imageNamed:@"check_green_off"] forState:UIControlStateNormal];
        _accessPro = NO;
    }else{
        [_btn setImage:[UIImage imageNamed:@"check_green_on"] forState:UIControlStateNormal];
        _accessPro = YES;
    }
}

- (IBAction)loginAction:(id)sender
{
    if (!_accessPro) {
        [self showHud:@"请同意《用户使用协议》" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
        return;
    }
    
    if ([[Common shareCommon] isLogin]) {
        
    }else{
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:AppQqID andDelegate:self];
        _tencentOAuth.redirectURI = @"www.qq.com";
        NSArray * tPermissions = [[NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t", nil] retain];
        [_tencentOAuth authorize:tPermissions inSafari:NO];
    }
}

- (void)tencentDidLogin{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        NSUserDefaults  * tUserdefaults = [NSUserDefaults standardUserDefaults];
        [tUserdefaults setObject:@"Login" forKey:IsLogin];
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
        NSString * tUserName = [tDic objectForKey:@"name"];
        NSString    * tUserUid = [tDic objectForKey:@"uid"];
        NSString    * tUserIconPath = [tDic objectForKey:@"avatar"];
        NSString    * tIsAdmin      = [tDic objectForKey:@"is_admin"];
        [UserDefalut setObject:tIsAdmin forKey:UserPermission];
        [UserDefalut setObject:tUserIconPath forKey:UserIconPath];
        [UserDefalut setObject:tUserName forKey:UserName];
        [UserDefalut setObject:tUserUid forKey:UserUid];
        [self showHud:@"登录成功" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
    }
}


- (void)GetErr:(ASIHTTPRequest *)request
{
    NSLog(@"网络连接错误");
}



- (void)showHud:(NSString *)msg mode:(MBProgressHUDMode)mode
{
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        
    }
    _hud.labelText = msg;
    [_hud show:YES];
    if (mode != MBProgressHUDModeNone) {
        [_hud setMode:mode];
    }
    
    [self.view addSubview:_hud];
}

- (void)hideHud
{
    [_hud hide:YES];
    if (_accessPro) {
        [self back:nil];
    }
}

- (IBAction)registAction:(id)sender
{
    if (nil == _registViewCtl) {
        _registViewCtl = [[RegistViewCtl alloc] initWithNibName:@"RegistView" bundle:nil];
    }
    [self.navigationController pushViewController:_registViewCtl animated:YES];
}

- (IBAction)showProctolAction:(id)sender
{
    [self showWebCtl:@"用户服务协议" urlStr:ProtoctolUrl];
}

- (IBAction)loginTelAction:(id)sender
{
    
    if (!_accessPro) {
        [self showHud:@"请同意《用户使用协议》" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
        return;
    }
    if (nil == _telLoginViewCtl) {
        _telLoginViewCtl = [[TelLoginViewCtl alloc] initWithNibName:@"TelLoginViewCtl" bundle:nil];
    }
    [self.navigationController pushViewController:_telLoginViewCtl animated:YES];
}

- (void)showWebCtl:(NSString *)title urlStr:(NSString *)urlStr
{
    if (_homeConContainViewCtl == nil) {
        _homeConContainViewCtl = [[HomeConContainViewCtl alloc] initWithNibName:@"HomeConCotainView" bundle:nil];
    }
    
    _homeConContainViewCtl.loadUrl = urlStr;
    _homeConContainViewCtl.title = title;
    
    [self.navigationController pushViewController:_homeConContainViewCtl animated:YES];
}

@end
