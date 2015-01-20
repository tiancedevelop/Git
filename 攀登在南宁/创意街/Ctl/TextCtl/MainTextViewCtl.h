//
//  MainTextViewCtl.h
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface MainTextViewCtl : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,EGORefreshTableDelegate>
{
    IBOutlet    UITableView     * _tableView;
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    BOOL _reloading;
}

- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;

@end
