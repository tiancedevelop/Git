//
//  AppDelegate.h
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#if __QQAPI_ENABLE__
#import "TencentOpenAPI/QQApiInterface.h"
#import "TencentOpenAPI/QQApiInterfaceObject.h"
#endif

@class MainTextViewCtl;
@class MainTxtImgViewCtl;
@class MainVideoViewCtl;
@class MainMeViewCtl;
@interface AppDelegate : UIResponder <UIApplicationDelegate,TencentSessionDelegate,WXApiDelegate,QQApiInterfaceDelegate>{
    MainTextViewCtl     * _mainTextViewCtl;
    MainMeViewCtl       * _mainMeViewCtl;
    MainTxtImgViewCtl   * _mainTxtImgViewCtl;
    MainVideoViewCtl    * _mainVideoViewCtl;
    
    UITabBarController  * _tabBarController;
}

@property (strong, nonatomic) UIWindow *window;

@end
