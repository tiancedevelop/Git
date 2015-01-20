//
//  HomeConServiceViewCtl.m
//  GrandmaBear
//
//  Created by ios on 14-8-25.
//  Copyright (c) 2014年 com.cn. All rights reserved.
//

#import "HomeConContainViewCtl.h"

@interface HomeConContainViewCtl ()
{

}
@end

@implementation HomeConContainViewCtl

@synthesize loadUrl;

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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadWeb];
    [_webView setDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated
{

}


- (void)loadWeb
{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:loadUrl]];

    [_webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadWeb];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_webView loadHTMLString:@" " baseURL:nil];
}

@end
