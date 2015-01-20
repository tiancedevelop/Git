//
//  IssueTxtViewCtl.m
//  创意街
//
//  Created by ios on 14-11-24.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "IssueTxtViewCtl.h"
#import "MBProgressHUD.h"

@interface IssueTxtViewCtl ()
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation IssueTxtViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[Common shareCommon] setBackItemImg:self];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_txtView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"发帖";
    
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [tRightBtn setTitle:@"发表" forState:UIControlStateNormal];
    [tRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tRightBtn addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
    
    [_RightBtn setCustomView:tRightBtn];
    self.navigationItem.rightBarButtonItem  = _RightBtn;
    // Do any additional setup after loading the view.
}

- (void)back:(id)sender {
    
    [_txtView setText:@""];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)sure
{
    if (![_txtView hasText]) {
        [self showHud:@"内容不能为空" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
        return;
    }
    [_txtView resignFirstResponder];
    if ([[Common shareCommon] isLoginAndShowCtl:self.navigationController]) {
        [self showHud:@"提交中..." mode:MBProgressHUDModeText];
        NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/post_thread",UrlStr];
        NSMutableDictionary * tMutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2",@"type_id",_txtView.text,@"content",[UserDefalut objectForKey:UserUid],@"uid", @"123",@"title",nil];
        [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
    }
    
}

#pragma mark -
#pragma mark 服务器返回数据
- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSDictionary    * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    int status = [[tDic objectForKey:@"status"] intValue];
    if (status == 1) {
        NSLog(@"上传成功");
        [self showHud:@"提交成功" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHudAndCtl) withObject:self afterDelay:1.0];
    }else{
        [self showHud:@"提交失败" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:self afterDelay:1.0];
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
}

- (void)hideHudAndCtl
{
    [_hud hide:YES];
    [self back:nil];
}


@end
