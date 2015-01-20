//
//  RegistViewCtl.h
//  创意街
//
//  Created by tusm on 15-1-4.
//  Copyright (c) 2015年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
enum
{
    ShowRegistType,
    ShowLookPassWType
};

typedef int ShowType;
@interface RegistViewCtl : UIViewController<UITextFieldDelegate>
{
    IBOutlet    UITextField     * _phoneNumTxt;
    IBOutlet    UITextField     * _setupPasTxt;
    IBOutlet    UITextField     * _surePasTxt;
    IBOutlet    UITextField     * _verificationTxt;
    
    IBOutlet    UIButton        * _registBtn;
    IBOutlet    UIButton        * _getVerBtn;
    
    NSMutableDictionary         * _mutableDic;
    
    UIImageView     * _phoneImgView;
    UIImageView     * _setupPasView;
    UIImageView     * _surePasView;
    
    ShowType          _showType;
}

@property(readwrite,assign)ShowType  showType;

- (IBAction)getVerificationNum:(id)sender;
- (IBAction)registe:(id)sender;
- (void)back:(id)sender;
- (IBAction)restoreMyself:(id)sender;
@end