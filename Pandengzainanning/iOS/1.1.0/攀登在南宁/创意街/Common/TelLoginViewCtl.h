//
//  TelLoginViewCtl.h
//  创意街
//
//  Created by tusm on 15-1-4.
//  Copyright (c) 2015年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@class RegistViewCtl;

@interface TelLoginViewCtl : UIViewController<UITextFieldDelegate>
{
    IBOutlet    UITextField     * _phoneNumTxt;
    IBOutlet    UITextField     * _pasTxt;
    IBOutlet    UINavigationBar * _tabBar;
    IBOutlet    UIButton        * _loginBtn;
    RegistViewCtl     * _registerViewCtl;
    NSMutableDictionary         * _mutableDic;
}

- (IBAction)loginAction:(id)sender;

- (IBAction)registAction:(id)sender;

- (IBAction)lookPassWordAction:(id)sender;

- (void)back:(id)sender;
- (void)GetResult:(ASIHTTPRequest *)request;
- (void)GetErr:(ASIHTTPRequest *)request;
@end
