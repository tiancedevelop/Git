//
//  SUNSlideSwitchDemoViewController.h
//  SUNCommonComponent
//
//  Created by 麦志泉 on 13-9-4.
//  Copyright (c) 2013年 中山市新联医疗科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SUNSlideSwitchView.h"
#import "MainTextViewCtl.h"
#import "MainTxtImgViewCtl.h"
#import "MainVideoViewCtl.h"
#import "MainMeViewCtl.h"
#import "SUNViewController.h"

@interface SUNSlideSwitchDemoViewController : UIViewController<SUNSlideSwitchViewDelegate,MainMeViewCtlDelegate,MainVideoViewCtlDelegate,MainTxtImgViewCtlDelegate>
{
    SUNSlideSwitchView *_slideSwitchView;
    MainTxtImgViewCtl *_vc1;
    MainVideoViewCtl *_vc2;
    MainTextViewCtl *_vc3;
    MainMeViewCtl *_vc4;

}

@property (nonatomic, strong) IBOutlet SUNSlideSwitchView *slideSwitchView;

@property (nonatomic, strong) MainTxtImgViewCtl *vc1;
@property (nonatomic, strong) MainVideoViewCtl *vc2;
@property (nonatomic, strong) MainTextViewCtl *vc3;
@property (nonatomic, strong) MainMeViewCtl *vc4;

- (void)pushViewCtlMe:(UIViewController *)viewCtl;
@end
