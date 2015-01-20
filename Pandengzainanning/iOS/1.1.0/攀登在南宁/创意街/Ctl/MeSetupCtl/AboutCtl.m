//
//  AboutCtl.m
//  创意街
//
//  Created by yu tang on 14-12-7.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "AboutCtl.h"
#import "MyLabel.h"
@interface AboutCtl ()<MyLabelDelegate,UIAlertViewDelegate>
{
    MyLabel *addressUrl;
    MyLabel *telNum;
    MyLabel *email;
}

- (NSAttributedString *)attributedString:(NSArray *__autoreleasing *)outURLs
                               URLRanges:(NSArray *__autoreleasing *)outURLRanges
                                 showStr:(NSString *)showStr;

@end

@implementation AboutCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[Common shareCommon] setBackItemImg:self];
    }
    return self;
}
//
- (void)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"关于";

    addressUrl = [[MyLabel alloc] initWithFrame:addressUrlView.frame];
    [addressUrl setText:@"http://www.nntzd.com/"];
    [addressUrl setTag:1];
    [addressUrl  setDelegate:self];
    [self.view addSubview:addressUrl];
    [addressUrl  release];
    
    email = [[MyLabel alloc] initWithFrame:companyEmailView.frame];
    [email setText:@"tiancedevelop@sina.com"];
    [email setTag:2];
    [email  setDelegate:self];
    [self.view addSubview:email];
    [email  release];
    
    telNum = [[MyLabel alloc] initWithFrame:companyTelView.frame];
    [telNum setText:@"07715345371"];
    [telNum setTag:3];
    [telNum  setDelegate:self];
    [self.view addSubview:telNum];
    [telNum  release];

}

#pragma mark MyLabel Delegate Methods
// myLabel是你的MyLabel委托的实例, tag是该实例的tag值, 有点多余, 哈哈
- (void)myLabel:(MyLabel *)myLabel touchesWtihTag:(NSInteger)tag {
    if (tag == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:addressUrl.text]];
    }else if (tag == 3)
    {
        NSString *telUrl = [NSString stringWithFormat:@"telprompt:%@",telNum.text];
        NSURL *url = [[NSURL alloc] initWithString:telUrl];
        [[UIApplication sharedApplication] openURL:url];
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:telNum.text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - privates
- (NSAttributedString *)attributedString:(NSArray *__autoreleasing *)outURLs
                               URLRanges:(NSArray *__autoreleasing *)outURLRanges
                                 showStr:(NSString *)showStr
{
    NSString *HTMLText = showStr;
    NSArray *URLs;
    NSArray *URLRanges;
    UIColor *color = [UIColor blackColor];
    UIFont *font = [UIFont fontWithName:@"Baskerville" size:19.];
    NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
    mps.lineSpacing = ceilf(font.pointSize * .5);
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSString *str = [NSString stringWithHTMLText:HTMLText baseURL:[NSURL URLWithString:@"http://en.wikipedia.org/"] URLs:&URLs URLRanges:&URLRanges];
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:str attributes:@
                                      {
                                          NSForegroundColorAttributeName : color,
                                          NSFontAttributeName            : font,
                                          NSParagraphStyleAttributeName  : mps,
                                          NSShadowAttributeName          : shadow,
                                      }];
    [URLRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [mas addAttributes:@
         {
             NSForegroundColorAttributeName : [UIColor blueColor],
             NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle)
         } range:[obj rangeValue]];
    }];
    
    *outURLs = URLs;
    *outURLRanges = URLRanges;
    
    return [mas copy];
}

@end
