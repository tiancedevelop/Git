//
//  MainTxtImgViewCtl.h
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "ASIHTTPRequest.h"

@protocol MainTxtImgViewCtlDelegate <NSObject>
- (void)pushViewCtl:(UIViewController *)viewCtl;
@end

@interface MainTxtImgViewCtl : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,EGORefreshTableDelegate>
{
    IBOutlet    UITableView     * _tableView;
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    BOOL _reloading;
    id<MainTxtImgViewCtlDelegate>   * _delegate;
}
@property(readwrite,assign)id<MainTxtImgViewCtlDelegate> delegate;

- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;

@end
