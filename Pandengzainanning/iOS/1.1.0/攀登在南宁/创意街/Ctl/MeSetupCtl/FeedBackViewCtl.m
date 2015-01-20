//
//  FeedBackViewCtl.m
//  创意街
//
//  Created by ios on 14-11-18.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "FeedBackViewCtl.h"
#import "MBProgressHUD.h"

@interface FeedBackViewCtl ()
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation FeedBackViewCtl

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_feedBackTxtField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [_feedBackTxtField setText:@""];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"DIY";
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
    [tRightBtn setTitle:@"提交" forState:UIControlStateNormal];
    [tRightBtn addTarget:self action:@selector(submitFeedBackStr:) forControlEvents:UIControlEventTouchUpInside];
    [tRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
    self.navigationItem.rightBarButtonItem  = _RightBtn;
    // Do any additional setup after loading the view.
}

- (IBAction)submitFeedBackStr:(id)sender
{
    [_feedBackTxtField resignFirstResponder];
    if (![_feedBackTxtField hasText]) {
        [self showHud:@"内容不能为空" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:self afterDelay:1.0];
        return;
    }
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/suggestion",UrlStr];
    NSMutableDictionary     * tDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UserDefalut objectForKey:UserUid],@"uid",[_feedBackTxtField text],@"content", nil];
    [self showHud:@"提交中..." mode:MBProgressHUDModeNone];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
