//
//  IssueTxtViewCtl.h
//  创意街
//
//  Created by ios on 14-11-24.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface IssueTxtViewCtl : UIViewController
{
    IBOutlet    UITextView      * _txtView;
}

- (void)back:(id)sender ;
- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;
@end
