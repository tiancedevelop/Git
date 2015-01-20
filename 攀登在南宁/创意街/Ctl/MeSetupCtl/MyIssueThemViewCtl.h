//
//  MyIssueThemView.h
//  创意街
//
//  Created by ios on 14-11-27.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface MyIssueThemViewCtl : UIViewController<UIAlertViewDelegate,EGORefreshTableDelegate>
{
    IBOutlet    UITableView     * _tableView;
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    BOOL _reloading;
}
- (void)back:(id)sender ;
- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;
@end
