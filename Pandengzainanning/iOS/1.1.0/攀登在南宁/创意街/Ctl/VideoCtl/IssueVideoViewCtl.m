//
//  IssueVideoViewCtl.m
//  创意街
//
//  Created by ios on 14-11-20.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "IssueVideoViewCtl.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "LoginViewCtl.h"
#define DEVICE_SIZE [[UIScreen mainScreen] applicationFrame].size
enum{
    UploadNoneType,
    UploadVideoType,
    UploadVideoThumType,
    UploadThemType
};

typedef int UploadType;

@interface IssueVideoViewCtl (){
    MPMoviePlayerController *moviePlayCtl;
    UIImage     * _VideoImg;
    UploadType _uploadType;
    LoginViewCtl    * _loginViewCtl;
    NSString    * _videoThumUrl;
    NSString    * _videoUrl;
}
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

@implementation IssueVideoViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        moviePlayCtl        = [[MPMoviePlayerController alloc] init];
        _uploadType = UploadNoneType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_videoDescribeTxtView setText:@""];
    self.navigationItem.title = @"发表视频";
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [tRightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [tRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tRightBtn addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * tLeftBtn= [[UIButton alloc] initWithFrame:CGRectMake(-10, 0, 50, 50)];
    [tLeftBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [tLeftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [tLeftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
    UIBarButtonItem *_LeftBtn = [[UIBarButtonItem alloc] initWithCustomView:tLeftBtn];
    
    
    [_RightBtn setCustomView:tRightBtn];
    
    self.navigationItem.leftBarButtonItem   = _LeftBtn;
    self.navigationItem.rightBarButtonItem  = _RightBtn;
    
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [_videoView setBackgroundColor:[UIColor colorWithRed:16 / 255.0f green:16 / 255.0f blue:16 / 255.0f alpha:1.0f]];
    
    NSURL * tVideoUrl = [NSURL URLWithString:[UserDefalut objectForKey:CurrentIssueVideoUrl]];
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:tVideoUrl options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 0, _videoView.frame.size.width, _videoView.frame.size.height);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [_videoView.layer addSublayer:_playerLayer];

    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 25, 30, 30)];
    [self.playButton setImage:[UIImage imageNamed:@"video_icon.png"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [_videoView addSubview:self.playButton];
    
    [self getVideoThum:movieAsset];
}

- (void)getVideoThum:(AVAsset *)avAsset
{
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    SafeRelease(_VideoImg);
    _VideoImg = [thumb retain];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [_videoDescribeTxtView setText:@""];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_videoDescribeTxtView resignFirstResponder];
}

#pragma mark - PlayEndNotification
- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification
{
    if ((AVPlayerItem *)notification.object != _playerItem) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        _playButton.alpha = 1.0f;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressPlayButton:(UIButton *)button
{
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    _playButton.alpha = 0.0f;
}


- (void)sure
{
    [_player pause];
    if (![_videoDescribeTxtView hasText]) {
        [self showTip:@"内容不能为空" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideTip) withObject:self afterDelay:1.0];
        return;
    }
    [_videoDescribeTxtView resignFirstResponder];
    if ([[Common shareCommon] isLoginAndShowCtl:self.navigationController]) {
        [self showTip:@"正在上传" mode:MBProgressHUDModeNone];
        [self uploadVideo];
    }
    
}

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
    [_player pause];
}




- (void)uploadVideo{
    _uploadType = UploadVideoType;
    
    NSString * tVideoPath = [UserDefalut objectForKey:CurrentIssueVideoPath];
    
    NSData          * tData = [NSData dataWithContentsOfFile:tVideoPath];
    NSString        * tUrlStr = [NSString stringWithFormat:@"%@/Upload/upload_video",UrlStr];
    
    [[Common shareCommon] postVideoWithUrl:tUrlStr delegate:self imgData:tData];
}

- (void)uploadImg{
    _uploadType = UploadVideoThumType;

    NSData          * tData = UIImageJPEGRepresentation(_VideoImg, 0.1);
    NSString        * tUrlStr = [NSString stringWithFormat:@"%@/Upload/upload_pic",UrlStr];

    [[Common shareCommon] postImgWithUrl:tUrlStr delegate:self imgData:tData];
}

- (void)uploadThem{
    _uploadType = UploadThemType;
    NSString        * tUrlStr = [NSString stringWithFormat:@"%@/Thread/post_thread",UrlStr];
    NSString        * tAttachmentStr = [NSString stringWithFormat:@"%@|%@",_videoThumUrl,_videoUrl];
    NSMutableDictionary     * tMutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"3",@"type_id",@"title",@"title",_videoDescribeTxtView.text,@"content",[UserDefalut objectForKey:UserUid],@"uid",tAttachmentStr,@"attachment", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSMutableDictionary * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (_uploadType == UploadVideoType) {
        int statues = [[tDic objectForKey:@"status"] intValue];
        if (statues == 1) {
            SafeRelease(_videoUrl);
            _videoUrl = [[tDic objectForKey:@"path"] retain];
            [self uploadImg];
        }
    }else if (_uploadType == UploadVideoThumType){
        int statues = [[tDic objectForKey:@"status"] intValue];
        if (statues == 1) {
            SafeRelease(_videoThumUrl);
            _videoThumUrl = [[tDic objectForKey:@"path"] retain];
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

@end
