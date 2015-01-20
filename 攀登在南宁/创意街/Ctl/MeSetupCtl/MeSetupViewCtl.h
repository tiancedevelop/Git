//
//  MeSetupViewCtl.h
//  创意街
//
//  Created by ios on 14-11-12.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeSetupViewCtl : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    IBOutlet UITableView     * _tableView;
}

- (void)back:(id)sender;

@end
