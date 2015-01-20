//
//  FeedBackViewCtl.h
//  创意街
//
//  Created by ios on 14-11-18.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface FeedBackViewCtl : UIViewController{
    IBOutlet    UITextView     * _feedBackTxtField;
    
}

- (IBAction)submitFeedBackStr:(id)sender;

- (void)back:(id)sender ;
- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;

@end
