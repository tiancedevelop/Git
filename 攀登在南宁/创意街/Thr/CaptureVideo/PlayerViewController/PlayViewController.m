//
//  PlayViewController.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-18.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SBCaptureDefine.h"
#import "IssueVideoViewCtl.h"

@interface PlayViewController (){
    IssueVideoViewCtl   * _issueVideoViewCtl;
}

@property (strong, nonatomic) UIButton  * useBtn;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) NSURL *videoFileURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@end

@implementation PlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideoFileURL:(NSURL *)videoFileURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.videoFileURL = videoFileURL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:16 / 255.0f green:16 / 255.0f blue:16 / 255.0f alpha:1.0f];
}

- (void)initUi
{
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [_backButton setImage:[UIImage imageNamed:@"vedio_nav_btn_back_nor.png"] forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"vedio_nav_btn_back_pre.png"] forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(pressBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.useBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, 20, 44, 44)];
    [self.useBtn setTitle:@"使用" forState:UIControlStateNormal];
    [self.useBtn addTarget:self action:@selector(pressUseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.useBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.useBtn];
    
    [self initPlayLayer];
    
    self.playButton = [[UIButton alloc] initWithFrame:_playerLayer.frame];
    [_playButton setImage:[UIImage imageNamed:@"video_icon.png"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self initUi];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)initPlayLayer
{
    if (!_videoFileURL) {
        return;
    }
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:_videoFileURL options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 64, DEVICE_SIZE.width, DEVICE_SIZE.width);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_playerLayer];

}

- (void)pressPlayButton:(UIButton *)button
{
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    _playButton.alpha = 0.0f;
}

- (void)pressUseBtn:(UIButton *)button
{
    [_player pause];
    NSLog(@"%@",_videoFileURL);
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:_videoFileURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString * resultPath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]] retain];
        NSLog(@"%@",resultPath);
        [formater release];
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     NSLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                 case AVAssetExportSessionStatusWaiting:
                     NSLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                 case AVAssetExportSessionStatusExporting:
                     NSLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     break;
                 case AVAssetExportSessionStatusFailed:
                     NSLog(@"AVAssetExportSessionStatusFailed");
                     break;
             }
             [exportSession release];
         }];
        long long fileLength = [self fileSizeAtPath:resultPath];
        NSLog(@"%llu",fileLength);
    }
    
    NSString * tVideoFilePath = [_videoFileURL absoluteString];
    tVideoFilePath = [tVideoFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    [UserDefalut setObject:tVideoFilePath forKey:CurrentIssueVideoPath];
    [UserDefalut setObject:[_videoFileURL absoluteString] forKey:CurrentIssueVideoUrl];
//    long long f = [self fileSizeAtPath:tVideoFilePath];
    
    [self showIssueView];
    
    
    
    
}

- (void)showIssueView
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    if (nil == _issueVideoViewCtl) {
        _issueVideoViewCtl = [[IssueVideoViewCtl alloc] initWithNibName:@"IssueVideoView" bundle:nil];
    }
    [self.navigationController pushViewController:_issueVideoViewCtl animated:YES];
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)pressBackButton:(UIButton *)button
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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

@end
