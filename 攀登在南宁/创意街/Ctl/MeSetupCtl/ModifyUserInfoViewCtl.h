//
//  ModifyUserInfoViewCtl.h
//  创意街
//
//  Created by ios on 14-11-27.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MobileCoreServices/MobileCoreServices.h"
@interface ModifyUserInfoViewCtl : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet    UIImageView     * _iconImgView;
    IBOutlet    UITextField     * _userNameField;
    IBOutlet    UITextField     * _telNumField;
    IBOutlet    UITextField     * _addressField;
}

- (void)back:(id)sender ;
- (void)GetResult:(ASIHTTPRequest *)request;
- (void)GetErr:(ASIHTTPRequest *)request;

@end
