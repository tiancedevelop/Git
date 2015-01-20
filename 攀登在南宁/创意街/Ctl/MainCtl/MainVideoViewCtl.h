//
//  MainVideoViewCtl.h
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@protocol MainVideoViewCtlDelegate <NSObject>
- (void)pushViewCtl:(UIViewController *)viewCtl;
@end

@interface MainVideoViewCtl : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,EGORefreshTableDelegate>
{
    IBOutlet    UITableView     * _tableView;
    int         tCurrentPlayVideoTag;
    BOOL        tPlayState;
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    BOOL _reloading;
    id<MainVideoViewCtlDelegate>   * _delegate;
}

@property(readwrite,assign)id<MainVideoViewCtlDelegate> delegate;

- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;

- (void)stopVideoAndRefresh;

@end
