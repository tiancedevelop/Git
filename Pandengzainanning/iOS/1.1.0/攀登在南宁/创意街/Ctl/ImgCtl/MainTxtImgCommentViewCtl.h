//
//  MainTxtImgCommentViewCtl.h
//  创意街
//
//  Created by ios on 14-11-28.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface MainTxtImgCommentViewCtl : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EGORefreshTableDelegate,UIActionSheetDelegate>
{
    IBOutlet    UITableView     * _tableView;
    IBOutlet    UITextView      * _txtView;
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    BOOL _reloading;
}

- (void)back:(id)sender;

- (void)setThemDic:(NSDictionary *)themDic;

- (IBAction)commentAction:(id)sender;


- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;

@end
