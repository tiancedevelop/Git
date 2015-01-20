//
//  LoginViewCtl.h
//  创意街
//
//  Created by ios on 14-11-26.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface LoginViewCtl : UIViewController

{
    IBOutlet UIImageView     * _iconImgView;
    IBOutlet UIImageView     * _lineImgView;
    IBOutlet UIButton        * _qqLoginImgBtn;
    IBOutlet UIButton        * _btn;
    IBOutlet UIButton        * _qqLoginBtn;
}

- (IBAction)loginAction:(id)sender;

- (IBAction)registAction:(id)sender;

- (IBAction)loginTelAction:(id)sender;

- (IBAction)showProctolAction:(id)sender;

- (IBAction)accessProAction:(id)sender;

- (void)back:(id)sender;

- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;

@end
