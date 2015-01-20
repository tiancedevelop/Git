//
//  ModifyUserInfoViewCtl.m
//  创意街
//
//  Created by ios on 14-11-27.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "ModifyUserInfoViewCtl.h"
#import "MBProgressHUD.h"
#import "UIImageView+RZWebImage.h"

enum{
    RequestUserNoneType,
    RequestSubmitIconType,
    RequestSubmitUserInfoType
};

typedef int RequestUserType;

@interface ModifyUserInfoViewCtl ()
{
    UIImage     * _iconImg;
    UIImageView * _imageView;
    NSString    * _iconUrl;
    RequestUserType     _requestUserType;
}
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation ModifyUserInfoViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[Common shareCommon] setBackItemImg:self];
        _requestUserType = RequestUserNoneType;
        _iconUrl = @"";
    }
    return self;
}

- (void)back:(id)sender {
    SafeRelease(_iconImg);
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self initIconView];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_userNameField resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _telNumField.keyboardType           = UIKeyboardTypeNumberPad;
    self.navigationItem.title = @"个人资料";
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
    [tRightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [tRightBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [tRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
    self.navigationItem.rightBarButtonItem  = _RightBtn;
    
    [self initIconView];
    
    
}


- (void)initIconView
{
    _imageView = [[UIImageView alloc] initWithFrame:_iconImgView.frame];
    _imageView.layer.masksToBounds = YES;
    _imageView.layer.cornerRadius = _iconImgView.frame.size.width/2;
    NSURL * tUrl = [NSURL URLWithString:[UserDefalut objectForKey:UserIconPath]];
    [_imageView setWebImage:tUrl placeHolder:[UIImage imageNamed:@"icon"] downloadFlag:1];
    [_imageView setTag:1];
    _imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconClick)];
    [_imageView addGestureRecognizer:singleTap1];
    [self.view addSubview:_imageView];
    [_userNameField setText:[UserDefalut objectForKey:UserName]];
    [_telNumField   setText:[UserDefalut objectForKey:UserTelNum]];
    [_addressField  setText:[UserDefalut objectForKey:UserAddress]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)submit
{
    if (![_userNameField hasText]) {
        [self showHud:@"呢称不能为空" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:self afterDelay:1.0];
        return;
    }
    
    if (![_telNumField.text isEqualToString:@""] && _telNumField.text != nil) {
        if (![[Common shareCommon] checkTel:_telNumField.text]) {
            [self showHud:@"电话格式错误" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
            return;
        }
    }
    [_userNameField resignFirstResponder];
    if (_iconImg) {
        [self uploadIcon];
    }else{
        [self submitUserInfo];
    }
}

- (void)uploadIcon
{
    _requestUserType = RequestSubmitIconType;
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Upload/upload_avatar",UrlStr];
    NSData      * tData = UIImageJPEGRepresentation(_iconImg, 0.1);
    [[Common shareCommon] postImgWithUrl:tUrlStr  delegate:self imgData:tData];
}

- (void)submitUserInfo
{
    _requestUserType = RequestSubmitUserInfoType;
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/User/mod_info",UrlStr];
    NSMutableDictionary     * tDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UserDefalut objectForKey:UserUid],@"uid",_userNameField.text,@"name",_addressField.text,@"address",
                                      _telNumField.text,@"phone",_iconUrl,@"avatar", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
}

- (void)iconClick
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"本地图片",nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

-(IBAction)btnClick{
    
}


- (void)setUserInfo
{
    
}
#pragma mark -
#pragma UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex = [%d]",buttonIndex);
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            controller.allowsEditing = YES;
            controller.showsCameraControls = true;
            
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            controller.allowsEditing = YES;
            
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        [portraitImg retain];
        SafeRelease(_iconImg);
        _iconImg = portraitImg;
        [_imageView setImage:_iconImg];
        
    }];
}

#pragma mark -
#pragma mark 服务器返回数据
- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSDictionary    * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    int status = [[tDic objectForKey:@"status"] intValue];
    if (_requestUserType == RequestSubmitIconType) {
        if (status == 1) {
            SafeRelease(_iconUrl);
            _iconUrl = [[tDic objectForKey:@"path"] retain];
            [self submitUserInfo];
        }else{
            [self showHud:@"提交失败" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHud) withObject:self afterDelay:1.0];
        }
    }else if (_requestUserType == RequestSubmitUserInfoType){
        if (status == 1) {
            NSLog(@"上传成功");
            [self showHud:@"提交成功" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHudAndCtl) withObject:self afterDelay:1.0];
            if (![_iconUrl isEqualToString:@""]) {
                [UserDefalut setObject:_iconUrl forKey:UserIconPath];
            }
            [UserDefalut setObject:_addressField.text forKey:UserAddress];
            [UserDefalut setObject:_telNumField.text forKey:UserTelNum];
            [UserDefalut setObject:_userNameField.text forKey:UserName];
        }else{
            [self showHud:@"提交失败" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHud) withObject:self afterDelay:1.0];
        }
    }
    
}

- (void)GetErr:(ASIHTTPRequest *)request
{
    NSLog(@"网络连接错误");
}

- (void)showHud:(NSString *)msg mode:(MBProgressHUDMode)mode
{
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        
    }
    _hud.labelText = msg;
    [_hud show:YES];
    if (mode != MBProgressHUDModeNone) {
        [_hud setMode:mode];
    }
    
    [self.view addSubview:_hud];
}

- (void)hideHud
{
    [_hud hide:YES];
}

- (void)hideHudAndCtl
{
    [_hud hide:YES];
    [self back:nil];
}

@end
