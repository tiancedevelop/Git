//
//  MianMeViewCtl.h
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "LoginViewCtl.h"
@protocol MainMeViewCtlDelegate <NSObject>
- (void)pushViewCtl:(UIViewController *)viewCtl;
@end

@interface MainMeViewCtl : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet    UITableView     * _tableView;
    id<MainMeViewCtlDelegate>   * _delegate;
    
    LoginViewCtl                * _loginViewCtl;
    
    UINavigationController *_navSlideSwitchVC;                //滑动切换视图
    UINavigationController *_navCommonComponentVC;              //通用控件
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property(readwrite,assign)id<MainMeViewCtlDelegate> delegate;
@property (nonatomic, strong) IBOutlet UINavigationController *navSlideSwitchVC;
@property (nonatomic, strong) IBOutlet UINavigationController *navCommonComponentVC;

- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;

@end
