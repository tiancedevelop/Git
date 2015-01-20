//
//  RegistViewCtl.m
//  创意街
//
//  Created by tusm on 15-1-4.
//  Copyright (c) 2015年 com.cn.chuangyijie. All rights reserved.
//

#import "RegistViewCtl.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

enum{
    RequestVertifyType,
    RequestRegistType
};

typedef int RequestType;

@interface RegistViewCtl ()
{
    RequestType     _requestType;
}
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation RegistViewCtl

@synthesize showType = _showType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        _showType = ShowRegistType;
        [[Common shareCommon] setBackItemImg:self];
    }
    return self;
}

- (void)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_showType == ShowRegistType) {
        self.navigationItem.title = @"注册";
    }else if (_showType == ShowLookPassWType){
        self.navigationItem.title = @"忘记密码";
        [_registBtn setTitle:@"修改密码" forState:UIControlStateNormal];
    }
    
    [_phoneNumTxt setDelegate:self];
    [_setupPasTxt setDelegate:self];
    [_surePasTxt  setDelegate:self];
    [_verificationTxt setDelegate:self];
    
    _phoneNumTxt.clearButtonMode        = UITextFieldViewModeWhileEditing;
    _setupPasTxt.clearButtonMode        = UITextFieldViewModeWhileEditing;
    _surePasTxt.clearButtonMode         = UITextFieldViewModeWhileEditing;
    _verificationTxt.clearButtonMode    = UITextFieldViewModeWhileEditing;
    
    _phoneNumTxt.keyboardType           = UIKeyboardTypeNumberPad;
    _verificationTxt.keyboardType       = UIKeyboardTypeNumberPad;
    
    _phoneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IcoError"]];
    _phoneImgView.frame = CGRectMake(-5, 0, 15, 15);
    
    _setupPasView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IcoError"]];
    _setupPasView.frame = CGRectMake(-5, 0, 15, 15);
    
    _surePasView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IcoError"]];
    _surePasView.frame = CGRectMake(-5, 0, 15, 15);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
    SafeRelease(_mutableDic);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)getVerificationNum:(id)sender
{
    if (![[Common shareCommon] checkTel:_phoneNumTxt.text]) {
        [self showHud:@"请输入正确的手机号" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.7];
        return;
    }
    if (_mutableDic != nil) {
        [_mutableDic release];
    }
    
    if (_showType == ShowLookPassWType) {
        _mutableDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_phoneNumTxt.text, @"phone",@"2",@"type", nil];
    }else if (_showType == ShowRegistType){
        _mutableDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_phoneNumTxt.text, @"phone",@"1",@"type", nil];
    }
    
    NSString * tStrUrl = [NSString stringWithFormat:@"%@/User/send_sms",UrlStr];
    [self startTime];
    _requestType = RequestVertifyType;
    [[Common shareCommon] postData:tStrUrl delegate:self postDataDic:_mutableDic];
//    [self postData:tStrUrl];
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


- (IBAction)registe:(id)sender
{
    if (_mutableDic != nil) {
        [_mutableDic release];
    }
    if (![_surePasTxt.text isEqualToString:_setupPasTxt.text]) {
        [self showHud:@"两次密码输入不一致" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.8];
        return;
    }
    _mutableDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_phoneNumTxt.text, @"phone",
                   _verificationTxt.text,@"code",
                   _surePasTxt.text,@"pwd", nil];
    NSString * tStrUrl = [NSString stringWithFormat:@"%@/User/phone_reg",UrlStr];
    
    if (_showType == ShowLookPassWType) {
        tStrUrl = [NSString stringWithFormat:@"%@/User/update_pwd",UrlStr];
    }else if (_showType == ShowRegistType){
        tStrUrl = [NSString stringWithFormat:@"%@/User/phone_reg",UrlStr];
    }
    _requestType = RequestRegistType;
    [[Common shareCommon] postData:tStrUrl delegate:self postDataDic:_mutableDic];
}

- (IBAction)restoreMyself:(id)sender
{
    [self.view removeFromSuperview];
}

#pragma mark -
#pragma mark TxtDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    BOOL tRegistBtnFlag = YES;
    if (_phoneNumTxt.text == nil) {
        tRegistBtnFlag = NO;
    }
    
    if (![[Common shareCommon] checkTel:_phoneNumTxt.text]) {
        tRegistBtnFlag = NO;
        _phoneImgView.image = [UIImage imageNamed:@"IcoError"];
        _phoneNumTxt.rightView = _phoneImgView;
        _phoneNumTxt.rightViewMode = UITextFieldViewModeAlways;
    }else{
        _phoneImgView.image = [UIImage imageNamed:@"IcoRight"];
        _phoneNumTxt.rightView = _phoneImgView;
        _phoneNumTxt.rightViewMode = UITextFieldViewModeAlways;
    }
    
    
    if ([_surePasTxt.text isEqualToString:@""] || [_setupPasTxt.text isEqualToString:@""]) {
        tRegistBtnFlag = NO;
        
    }
    
    if (![_setupPasTxt.text isEqualToString:_surePasTxt.text]) {
        tRegistBtnFlag = NO;
        _surePasView.image = [UIImage imageNamed:@"IcoError"];
        _surePasTxt.rightView = _surePasView;
        _surePasTxt.rightViewMode = UITextFieldViewModeAlways;
    }else if(![_setupPasTxt.text isEqualToString:@""]){
        _surePasView.image = [UIImage imageNamed:@"IcoRight"];
        _surePasTxt.rightView = _surePasView;
        _surePasTxt.rightViewMode = UITextFieldViewModeAlways;
    }
    
    if ([_verificationTxt.text isEqualToString:@""]) {
        tRegistBtnFlag = NO;
    }
    
    _registBtn.enabled = tRegistBtnFlag;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual: _phoneNumTxt]) {
        _phoneNumTxt.rightViewMode = UITextFieldViewModeNever;
        _phoneNumTxt.backgroundColor = [UIColor whiteColor];
    }
    
    if ([textField isEqual:_surePasTxt] || [textField isEqual:_setupPasTxt]) {
        textField.rightViewMode = UITextFieldViewModeNever;
    }
}

#pragma mark -
#pragma mark Asi

//获取请求结果
- (void)GetResult:(ASIHTTPRequest *)request{
    
    NSData *data =[request responseData];
//    MyNSLog([request responseString]);
    NSDictionary *tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (_requestType == RequestRegistType) {
        if ([[tDic valueForKey:@"status"] isEqual:[NSNumber numberWithInt:1]]) {
            if (_showType == ShowLookPassWType) {
                [self showHud:@"密码修改成功" mode:MBProgressHUDModeText];
            }else if (_showType == ShowRegistType){
                [self showHud:@"注册成功" mode:MBProgressHUDModeText];
            }
            
            [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.8];
            [self back:nil];
        }else{
            [self showHud:@"注册失败" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.8];
        }
    }else if (_requestType == RequestVertifyType){
        if (_showType == ShowRegistType){
            if ([[tDic valueForKey:@"status"] isEqual:[NSNumber numberWithInt:0]]) {
                [self showHud:@"手机号已注册" mode:MBProgressHUDModeText];
                [self performSelector:@selector(hideHud) withObject:nil afterDelay:0.8];
            }
        }
    }
    
}

//连接错误调用这个函数
- (void) GetErr:(ASIHTTPRequest *)request{
    //    [_loadView showLoadingView:NO view:self.view];
//    [[Common shareCommon] showLoadingFailView:self.view tip:@"网络错误"];
//    MyNSLog(@"连不上服务器");
}


-(void)startTime{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_getVerBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
                _getVerBtn.userInteractionEnabled = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
//            MyNSLog(@"---sdf");
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_getVerBtn setTitle:[NSString stringWithFormat:@"%@秒",strTime] forState:UIControlStateNormal];
                _getVerBtn.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
}

@end