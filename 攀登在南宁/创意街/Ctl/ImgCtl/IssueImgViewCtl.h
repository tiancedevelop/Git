//
//  IssueImgViewCtl.h
//  创意街
//
//  Created by ios on 14-11-27.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MobileCoreServices/MobileCoreServices.h"
@interface IssueImgViewCtl : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet    UITextView      * _videoDescribeTxtView;
    IBOutlet    UIImageView     * _imgView;
    IBOutlet    UIImageView     * _deleteImgView;
    IBOutlet    UILabel         * _describeSize;
}
- (void)back:(id)sender ;

- (void)GetResult:(ASIHTTPRequest *)request;
- (void) GetErr:(ASIHTTPRequest *)request;
@end
