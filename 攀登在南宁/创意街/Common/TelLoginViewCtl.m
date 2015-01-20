//
//  TelLoginViewCtl.m
//  创意街
//
//  Created by tusm on 15-1-4.
//  Copyright (c) 2015年 com.cn.chuangyijie. All rights reserved.
//

#import "TelLoginViewCtl.h"
#import "RegistViewCtl.h"
#import "MBProgressHUD.h"
@interface TelLoginViewCtl ()
{
    RegistViewCtl       * _registViewCtl;
}
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation TelLoginViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[Common shareCommon] setBackItemImg:self];
    }
    return self;
}

- (void)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    _phoneNumTxt.keyboardType           = UIKeyboardTypeNumberPad;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginAction:(id)sender
{
    if (![[Common shareCommon] checkTel:_phoneNumTxt.text]) {
        [self showHud:@"请输入正确的手机号" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.7];
        return;
    }
    NSMutableDictionary * tDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_phoneNumTxt.text,@"phone",_pasTxt.text,@"pwd", nil];
    NSString * tUrlStr = [NSString stringWithFormat:@"%@/User/normal_login",UrlStr];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
}

- (IBAction)registAction:(id)sender
{
    SafeRelease(_registViewCtl);
    if (nil == _registViewCtl) {
        _registViewCtl = [[RegistViewCtl alloc] initWithNibName:@"RegistView" bundle:nil];
    }
    _registViewCtl.showType = ShowRegistType;
    [self.navigationController pushViewController:_registViewCtl animated:YES];
}

- (IBAction)lookPassWordAction:(id)sender
{
    SafeRelease(_registViewCtl);
    if (nil == _registViewCtl) {
        _registViewCtl = [[RegistViewCtl alloc] initWithNibName:@"RegistView" bundle:nil];
    }
    _registViewCtl.showType = ShowLookPassWType;
    [self.navigationController pushViewController:_registViewCtl animated:YES];
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
}

- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    //    MyNSLog([request responseString]);
    NSDictionary *tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([[tDic valueForKey:@"status"] isEqual:[NSNumber numberWithInt:0]]){
        [self showHud:@"账号或密码错误" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.7];
    }else if ([[tDic valueForKey:@"status"] isEqual:[NSNumber numberWithInt:1]]){
        [self showHud:@"登录成功" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.7];
        NSUserDefaults  * tUserdefaults = [NSUserDefaults standardUserDefaults];
        [tUserdefaults setObject:@"Login" forKey:IsLogin];
        
        NSString * tUserName = judgeNull([tDic objectForKey:@"name"]);
        NSString    * tUserUid = judgeNull([tDic objectForKey:@"uid"]);
        NSString    * tUserIconPath = judgeNull([tDic objectForKey:@"avatar"]);
        NSString    * tUserTelNum   = judgeNull([tDic objectForKey:@"tel_number"]);
        NSString    * tUserAddress  = judgeNull([tDic objectForKey:@"address"]);
        [UserDefalut setObject:tUserIconPath forKey:UserIconPath];
        [UserDefalut setObject:tUserName forKey:UserName];
        [UserDefalut setObject:tUserUid forKey:UserUid];
        [UserDefalut setObject:tUserTelNum forKey:UserTelNum];
        [UserDefalut setObject:tUserAddress forKey:UserAddress];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
//        [self back:nil];
    }
}

- (void)GetErr:(ASIHTTPRequest *)request
{
    
}


@end
