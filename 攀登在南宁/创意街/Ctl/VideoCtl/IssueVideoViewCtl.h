//
//  IssueVideoViewCtl.h
//  创意街
//
//  Created by ios on 14-11-20.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface IssueVideoViewCtl : UIViewController
{
    IBOutlet    UITextView      * _videoDescribeTxtView;
    IBOutlet    UIView          * _videoView;
    IBOutlet    UILabel         * _describeSize;
}

- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;
@end
