//
//  IssueImgViewCtl.m
//  创意街
//
//  Created by ios on 14-11-27.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "IssueImgViewCtl.h"
#import "MBProgressHUD.h"

enum{
    UploadNoneType,
    UploadVideoType,
    UploadVideoThumType,
    UploadThemType
};

typedef int UploadType;

@interface IssueImgViewCtl (){
    UploadType  _uploadType;
    UIImage     * _issueImg;
    NSString    * _imgUrl;
}
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation IssueImgViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[Common shareCommon] setBackItemImg:self];
        _uploadType = UploadNoneType;
        
    }
    return self;
}

- (void)back:(id)sender {
    [_issueImg release];
    [_videoDescribeTxtView setText:@""];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self delClick];
    [_videoDescribeTxtView setText:@""];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_videoDescribeTxtView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_videoDescribeTxtView setText:@""];
    self.navigationItem.title = @"发帖";
    [self initNavBarBtn];
    [self refreshImgView];
    
    
}

- (void)imgClick
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

- (void)delClick
{
    SafeRelease(_issueImg);
    [self refreshImgView];
}

- (void)sure
{
    if (![_videoDescribeTxtView hasText]) {
        [self showTip:@"内容不能为空" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideTip) withObject:self afterDelay:1.0];
        return;
    }else if (!_issueImg){
        [self showTip:@"请添加图片" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideTip) withObject:self afterDelay:1.0];
        return;
    }
    [_videoDescribeTxtView resignFirstResponder];
    if ([[Common shareCommon] isLoginAndShowCtl:self.navigationController]) {
        [self showTip:@"正在上传" mode:MBProgressHUDModeNone];
        [self uploadImg];
    }
}

#pragma mark -
#pragma mark 服务器交互

- (void)uploadImg{
    _uploadType = UploadVideoThumType;
    
    NSData          * tData = UIImageJPEGRepresentation(_issueImg, 0.1);
    NSString        * tUrlStr = [NSString stringWithFormat:@"%@/Upload/upload_pic",UrlStr];
    
    [[Common shareCommon] postImgWithUrl:tUrlStr delegate:self imgData:tData];
}

- (void)uploadThem{
    _uploadType = UploadThemType;
    NSString        * tUrlStr = [NSString stringWithFormat:@"%@/Thread/post_thread",UrlStr];
    NSString        * tAttachmentStr = [NSString stringWithFormat:@"%@",_imgUrl];
    NSMutableDictionary     * tMutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"type_id",@"title",@"title",_videoDescribeTxtView.text,@"content",[UserDefalut objectForKey:UserUid],@"uid",tAttachmentStr,@"attachment", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSMutableDictionary * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (_uploadType == UploadVideoThumType){
        int statues = [[tDic objectForKey:@"status"] intValue];
        if (statues == 1) {
            SafeRelease(_imgUrl);
            _imgUrl = [[tDic objectForKey:@"path"] retain];
            [self uploadThem];
        }
    }else if (_uploadType == UploadThemType){
        int statues = [[tDic objectForKey:@"status"] intValue];
        
        if (statues == 1) {
            NSLog(@"上传成功");
            [self showTip:@"提交成功" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideTipAndRootViewCtl) withObject:self afterDelay:1.0];
        }else{
            [self showTip:@"提交失败" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideTip) withObject:self afterDelay:1.0];
        }
        
    }
    
}


- (void)GetErr:(ASIHTTPRequest *)request
{
    NSLog(@"网络连接错误");
}

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshImgView
{
    _imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick)];
    [_imgView addGestureRecognizer:singleTap1];
    _imgView.image = [UIImage imageNamed:@"AddImg"];
    _deleteImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delClick)];
    [_deleteImgView addGestureRecognizer:singleTap2];
    [_deleteImgView setImage:[UIImage imageNamed:@"liveDelete"]];
    if (!_issueImg) {
        [_deleteImgView setHidden:YES];
    }else{
        [_imgView setImage:_issueImg];
        [_deleteImgView setHidden:NO];
    }
    
}

- (void)initNavBarBtn
{
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [tRightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [tRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tRightBtn addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton * tLeftBtn= [[UIButton alloc] initWithFrame:CGRectMake(-10, 0, 50, 50)];
//    [tLeftBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
//    [tLeftBtn setTitle:@"取消" forState:UIControlStateNormal];
//    [tLeftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
//    UIBarButtonItem *_LeftBtn = [[UIBarButtonItem alloc] initWithCustomView:tLeftBtn];
    
    
    [_RightBtn setCustomView:tRightBtn];
    
//    self.navigationItem.leftBarButtonItem   = _LeftBtn;
    self.navigationItem.rightBarButtonItem  = _RightBtn;
}

- (void)showTip:(NSString *)tipStr mode:(MBProgressHUDMode)mode
{
    
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    _hud.labelText = tipStr;
    if (mode!= MBProgressHUDModeNone) {
        _hud.mode = mode;
    }
    
    [_hud show:YES];
    [self.view addSubview:_hud];
}

- (void)hideTip
{
    [_hud hide:YES];
}

- (void)hideTipAndRootViewCtl
{
    [_hud hide:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (portraitImg) {
            SafeRelease(_issueImg);
            _issueImg = [portraitImg retain];
            [self refreshImgView];
        }
        
        
    }];
}

@end
