//
//  MainVideoViewCtl.m
//  创意街
//
//  Created by ios on 14-11-11.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "MainVideoViewCtl.h"
#import "MainVideoTabViewCell.h"
#import "MyMovieViewController.h"
#import "CaptureViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SBCaptureToolKit.h"
#import <AVFoundation/AVFoundation.h>
#import "HYActivityView.h"
#import "WXApi.h"
#import "MBProgressHUD.h"
#import "TencentOpenAPI/TencentOpenSDK.h"
#import "UIImageView+RZWebImage.h"
#import "IssueTxtViewCtl.h"
#import "MainVideoCommentViewCtl.h"
#import "IssueImgViewCtl.h"


@interface MainVideoViewCtl ()<HYActivityViewDelegate>
{
    MPMoviePlayerController *moviePlayCtl;
    enum WXScene        _scene;
    RequestType         _requestType;
    NSMutableArray      * _themMutableAry;
    IssueTxtViewCtl     * _issueTxtViewCtl;
    CaptureViewController   * _captureViewCtl;
    IssueImgViewCtl         * _issueImgViewCtl;
    MainVideoCommentViewCtl * _mainVideoCommentViewCtl;
    ShowActivityType    _showActivityType;
    int                 _currentClickBtnTag;
    BOOL        _shareToWx;
}

@property (nonatomic, strong) HYActivityView *activityView;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation MainVideoViewCtl

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tPlayState = NO;
        tCurrentPlayVideoTag = -1;
        moviePlayCtl        = [[MPMoviePlayerController alloc] init];
        _scene = WXSceneSession;
        _requestType = RequestNoneType;
        _showActivityType = ShowActivityNoneType;
        _shareToWx  =   NO;
        _currentClickBtnTag = -1;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated{
    [self stopVideo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = ProductName;
    
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [tRightBtn addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
    [tRightBtn setImage:[UIImage imageNamed:@"navigationButtonRefresh"] forState:UIControlStateNormal];
    
    UIButton * tLeftBtn= [[UIButton alloc] initWithFrame:CGRectMake(-10, 0, 50, 50)];
    [tLeftBtn addTarget:self action:@selector(clickLeft) forControlEvents:UIControlEventTouchUpInside];
    [tLeftBtn setImage:[UIImage imageNamed:@"comment-bar-write-icon"] forState:UIControlStateNormal];
    
    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
    UIBarButtonItem *_LeftBtn = [[UIBarButtonItem alloc] initWithCustomView:tLeftBtn];
    
    
    [_RightBtn setCustomView:tRightBtn];
    
    self.navigationItem.leftBarButtonItem   = _LeftBtn;
    self.navigationItem.rightBarButtonItem  = _RightBtn;
    
    [self getThem:@"0"];
    [self createHeaderView];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]
     
     addObserver:self selector:@selector(shareToWxResult:) name:ShareToWxResultNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareToQqResult:) name:ShareToQQResultNotification object:nil];
}

- (void)clickLeft
{
//    [self selectVideo];
    [self shareIssueActivity:nil];
}


- (void)clickRight
{
    [self getThem:@"0"];
    [self scrollToTop:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushMyCtl:(UIViewController *)viewCtl
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushViewCtl:)]) {
        [self.delegate pushViewCtl:viewCtl];
    }
}

#pragma mark -
#pragma mark tableview delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tIndex          = [indexPath indexAtPosition:1];
    id sender = [[UIButton alloc] init];
    [sender setTag:tIndex];
//    [self replayAction:sender];
    return indexPath;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    return 0.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if (section == 0) {
    //        return 1;
    //    }else if (section == 1){
    //        return 2;
    //    }
    return [_themMutableAry count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger tIndex = [indexPath indexAtPosition:1];
    
    int tContentHight = [self getContentHeigh:tIndex];
        
    return 400+(tContentHight - CellHeigh);


}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCell";
    
    NSUInteger tIndex        = [indexPath indexAtPosition:1];
    
    NSDictionary    * tDic = [_themMutableAry objectAtIndex:tIndex];
    
    MainVideoTabViewCell *cell = (MainVideoTabViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SafeRelease(cell);
    if (nil == cell) {
        cell = [[MainVideoTabViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        [cell setTag:tIndex];
        UIView  * backView = [[UIView alloc] initWithFrame:cell.contentView.frame];
        backView.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = backView;
    }
    if (cell.moviePlayCtl.playbackState == MPMoviePlaybackStatePlaying) {
//        NSLog(@"movie is playing");
        [cell.bbsContentView addSubview:[cell.moviePlayCtl view]];
    }


//    NSLog(@"--- %d",(int)tIndex);
    NSArray     * tCellAry = [_tableView visibleCells];
    BOOL tFlag = NO;
    for (int index = 0; index < [tCellAry count]; index++) {
        MainVideoTabViewCell * cell = (MainVideoTabViewCell *)[tCellAry objectAtIndex:index];
        if (tCurrentPlayVideoTag == cell.tag) {
            tFlag = YES;
        }
    }
    if (!tFlag && tCurrentPlayVideoTag != -1) {
        [self stopVideo];
        
//        if ([tCellAry count] > 1) {
//            MainVideoTabViewCell * cell = (MainVideoTabViewCell *)[tCellAry objectAtIndex:0];
//            UIButton * tBtn = [[UIButton alloc] init];
//            [tBtn setTag:cell.tag];
//            [self playVideo:tBtn];
//        }
        
    }else if (tCurrentPlayVideoTag == -1){
        if ([tCellAry count] >= 1) {
            MainVideoTabViewCell * cell = (MainVideoTabViewCell *)[tCellAry objectAtIndex:0];
            UIButton * tBtn = [[UIButton alloc] init];
            [tBtn setTag:cell.tag];
//            [self performSelectorInBackground:@selector(waitPlay:) withObject:tBtn];
//            [self playVideo:tBtn];
        }
    }
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieReadyPlay:)
                                                 name:MPMoviePlayerReadyForDisplayDidChangeNotification
                                               object:cell.moviePlayCtl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerPlaybackStateDidChangeNotification:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:cell.moviePlayCtl];
    
    [self refreshCellView:cell index:(int)tIndex];
    [self initCellData:cell tDic:tDic index:(int)tIndex];
    [self initCellEvent:cell tIndex:(int)tIndex];
    return cell;
}

#pragma mark -
#pragma mark 播放控制

- (IBAction)moviePlayBackDidchange:(id)sender
{
    NSLog(@"did change");
}

- (void)waitPlay:(id)sender
{
    sleep(1);
    [self performSelectorOnMainThread:@selector(playVideo:) withObject:sender waitUntilDone:NO];
}

- (IBAction)moviePlayBackDidFinish:(id)sender
{
    NSLog(@"sdfaldfjsdlk");
}


- (IBAction)moviePlaTypesAvailablechange:(id)sender
{
    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:tCurrentPlayVideoTag inSection:0];
    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    [btnCell.indicatorView removeFromSuperview];
    NSLog(@"moviePlaTypesAvailablechange");
}

- (IBAction)movieReadyPlay:(id)sender
{
    NSLog(@"moviePlayTypeAvailabBackDidchange");
    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:tCurrentPlayVideoTag inSection:0];
    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    [btnCell.videoThumImgView addSubview:moviePlayCtl.view];
    [btnCell.videoThumImgView addSubview:btnCell.bbsBrowserCount];
}

- (IBAction)MPMoviePlayerPlaybackStateDidChangeNotification:(id)sender
{
    [self refreshPlayTime];
    NSLog(@"MPMoviePlayerPlaybackStateDidChangeNotification");
    [self performSelector:@selector(refreshPlayTime) withObject:self afterDelay:1.0];
}

- (void)refreshPlayTime
{
    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:tCurrentPlayVideoTag inSection:0];
    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    int   currentDuration  = moviePlayCtl.duration;
    int   duration = moviePlayCtl.playableDuration;
    int   playTime = currentDuration - duration;
    NSString * tStr = [NSString stringWithFormat:@"00:0%d",playTime];
    if (playTime >= 10) {
        tStr = [NSString stringWithFormat:@"00:%d",playTime];
    }
    btnCell.playDuration.text = tStr;
    [btnCell.bbsContentView addSubview:btnCell.playDuration];
    if (playTime > 0) {
        [self performSelector:@selector(refreshPlayTime) withObject:self afterDelay:1.0];
    }
}

- (IBAction)playVideo:(id)sender{
    int tTag = [sender tag];
    tCurrentPlayVideoTag = tTag;

    NSDictionary    * tDic = [_themMutableAry objectAtIndex:tTag];
    
    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:tTag inSection:0];
    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    moviePlayCtl = [[MPMoviePlayerController alloc] init];
//    [btnCell.videoThumImgView addSubview:moviePlayCtl.view];
    [[moviePlayCtl view] setFrame:CGRectMake(0, 0, btnCell.bbsContentView.frame.size.width, btnCell.bbsContentView.frame.size.height)];
    [moviePlayCtl setContentURL:[NSURL URLWithString:[self getVideoUrl:tDic]]];
    
    double t = moviePlayCtl.duration;
    moviePlayCtl.scalingMode = MPMovieScalingModeAspectFit;
    [btnCell.playBtn setHidden:YES];
    [btnCell.videoThumImgView addSubview:btnCell.indicatorView];
    
    moviePlayCtl.repeatMode = MPMovieRepeatModeOne;
    [moviePlayCtl play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieReadyPlay:)
                                                 name:MPMoviePlayerReadyForDisplayDidChangeNotification
                                               object:moviePlayCtl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerPlaybackStateDidChangeNotification:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:moviePlayCtl];
    [self submitBrowser:[tDic objectForKey:@"id"]];
    int tBrowserCount = [[tDic objectForKey:@"views"] intValue];
    [btnCell.bbsBrowserCount setText:[NSString stringWithFormat:@"%d播放",tBrowserCount+1]];
    NSMutableDictionary * tMutDic = [[NSMutableDictionary alloc] initWithDictionary:tDic];
    [tMutDic setObject:[NSString stringWithFormat:@"%d",tBrowserCount+1] forKey:@"views"];
    [_themMutableAry replaceObjectAtIndex:tTag withObject:tMutDic];
}

- (void)stopVideo
{
//    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:tCurrentPlayVideoTag inSection:0];
//    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    [moviePlayCtl stop];
    tCurrentPlayVideoTag = -1;
}

- (void)stopVideoAndRefresh
{
    [moviePlayCtl stop];
    tCurrentPlayVideoTag = -1;
    [_tableView reloadData];
}


#pragma mark -
#pragma mark 微信 QQ 分享
- (void)activityHide
{
    if (_showActivityType == ShowActivityShareType || _showActivityType == ShowActivityNoneType) {
        [self.tabBarController.tabBar setHidden:NO];
    }
}

- (IBAction)showShareActivity:(id)sender
{
    if (self.activityView.isShowing) {
        return;
    }
    _currentClickBtnTag = [sender tag];
    _showActivityType = ShowActivityShareType;
    
    [self.tabBarController.tabBar setHidden:YES];
    SafeRelease(self.activityView);
    
    if (!self.activityView) {
        self.activityView = [[HYActivityView alloc]initWithTitle:@"分享到" referView:self.view];
        
        //横屏会变成一行6个, 竖屏无法一行同时显示6个, 会自动使用默认一行4个的设置.
        self.activityView.numberOfButtonPerLine = 6;
        
        ButtonView *bv = [[ButtonView alloc]initWithText:@"QQ好友" image:[UIImage imageNamed:@"qq_normal"] handler:^(ButtonView *buttonView){
            NSLog(@"点击新浪微博");
            [self shareTxtToQqFriend:sender isQqFriend:YES];
            _shareToWx = YES;
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"QQ空间" image:[UIImage imageNamed:@"qzone_normal"] handler:^(ButtonView *buttonView){
            [self shareTxtToQqFriend:sender isQqFriend:NO];
            _shareToWx = YES;
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"微信好友" image:[UIImage imageNamed:@"wxfriend_normal"] handler:^(ButtonView *buttonView){
            _shareToWx = YES;
            NSLog(@"点击印象笔记");
            _scene = WXSceneSession;
            [self shareVideoToWX:sender];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"微信朋友圈" image:[UIImage imageNamed:@"wxgroup_normal"] handler:^(ButtonView *buttonView){
            _shareToWx = YES;
            NSLog(@"点击QQ");
            _scene = WXSceneTimeline;
            [self shareVideoToWX:sender];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"举报" image:[UIImage imageNamed:@"report"] handler:^(ButtonView *buttonView){
            NSLog(@"点击举报");
            //            _shareToWx = YES;
            //            _scene = WXSceneTimeline;
            [self report:sender];
            
        }];
        [self.activityView addButtonView:bv];
    }
    
    [self.activityView show];
    self.activityView.delegate = self;
}

- (IBAction)shareIssueActivity:(id)sender
{
    if (self.activityView.isShowing) {
        return;
    }
    _showActivityType = ShowActivityNoneType;
    [self.tabBarController.tabBar setHidden:YES];
    SafeRelease(self.activityView);
    if (!self.activityView) {
        self.activityView = [[HYActivityView alloc]initWithTitle:@"发表类型" referView:self.view];
        
        //横屏会变成一行6个, 竖屏无法一行同时显示6个, 会自动使用默认一行4个的设置.
        self.activityView.numberOfButtonPerLine = 6;
        
        ButtonView *bv = [[ButtonView alloc]initWithText:@"图片" image:[UIImage imageNamed:@"issueImg"] handler:^(ButtonView *buttonView){
            _showActivityType = ShowActivityIssueType;
            [self showIssueImgView];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"文字" image:[UIImage imageNamed:@"issueTxt"] handler:^(ButtonView *buttonView){
            [self showIssueTxtView];
            _showActivityType = ShowActivityIssueType;
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"视频" image:[UIImage imageNamed:@"issueVideo"] handler:^(ButtonView *buttonView){
            [self showIssueVideoView];
            _showActivityType = ShowActivityIssueType;
            
        }];
        [self.activityView addButtonView:bv];
    }
    
    [self.activityView show];
    self.activityView.delegate = self;
}

- (void)showIssueImgView
{
    if (nil == _issueImgViewCtl) {
        _issueImgViewCtl = [[IssueImgViewCtl alloc] initWithNibName:@"IssueImgView" bundle:nil];
    }
    [self.navigationController pushViewController:_issueImgViewCtl animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
    //    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)showIssueTxtView
{
    if (_issueTxtViewCtl == nil) {
        _issueTxtViewCtl = [[IssueTxtViewCtl alloc] initWithNibName:@"IssueTxtView" bundle:nil];
        
    }
    [self.navigationController pushViewController:_issueTxtViewCtl animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
    [moviePlayCtl stop];
    tCurrentPlayVideoTag = -1;
}


- (void)showIssueVideoView
{
    SafeRelease(_captureViewCtl);
    if (_captureViewCtl == nil) {
        _captureViewCtl = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    }

    [self.navigationController pushViewController:_captureViewCtl animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [moviePlayCtl stop];
    tCurrentPlayVideoTag = -1;
}

- (void)shareVideoToWX:(id)sender
{
    int tTag = (int)[sender tag];
    NSDictionary    * tDic = [_themMutableAry objectAtIndex:tTag];
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@?id=%d&type=ios",ShareUrl,[[tDic objectForKey:@"id"] intValue]];
    NSString    * tImgUrlStr = [self getImgUrlStr:tDic];
    NSURL       * tImgUrl = [NSURL URLWithString:tImgUrlStr];
    NSString    * tImgPath =[NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%u",tImgUrl.description.hash];
    UIImage     * tImg = [UIImage imageWithContentsOfFile:tImgPath];

    NSData      * tData=[NSData dataWithContentsOfFile:tImgPath];
    if ([tData length]>20000) {
        tData = UIImageJPEGRepresentation(tImg, 0.1);
    }
    WXMediaMessage *message = [WXMediaMessage message];
    if (_scene == WXSceneTimeline) {
        message.title = [NSString stringWithFormat:@"分享视频:%@",[tDic objectForKey:@"content"]];
    }else{
        message.title = @"分享视频";
        message.description = [tDic objectForKey:@"content"];
    }
    
    [message setThumbImage:[UIImage imageWithData:tData]];
    
    WXVideoObject *ext = [WXVideoObject object];
    ext.videoUrl = tUrlStr;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    
    [WXApi sendReq:req];
}

- (void)shareTxtToQqFriend:(id)sender isQqFriend:(BOOL)isQqFriend
{
    
    int tTag = [sender tag];
    NSDictionary    * tDic = [_themMutableAry objectAtIndex:tTag];
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@?id=%d&type=ios",ShareUrl,[[tDic objectForKey:@"id"] intValue]];
    NSString    * tImgUrlStr = [self getImgUrlStr:tDic];
    NSURL       * tImgUrl = [NSURL URLWithString:tImgUrlStr];
    
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:tUrlStr]
                                title: @"分享视频"
                                description:[tDic objectForKey:@"content"]
                                previewImageURL:tImgUrl];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];

    QQApiSendResultCode sent = 0;
    if (isQqFriend) {
        sent = [QQApiInterface sendReq:req];
    }else{
        sent = [QQApiInterface SendReqToQZone:req];
    }
    
    [self handleSendResult:sent];
}


- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯文本分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯图片分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}


#pragma mark -
#pragma mark 数据请求
- (void)getThem:(NSString *)sTime
{
    if ([sTime isEqualToString:@"0"]) {
        _requestType = RequestThemType;
    }else{
        _requestType = RequestMoreThemType;
    }
    
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/thread_list",UrlStr];
    NSMutableDictionary * tDic = [NSMutableDictionary   dictionaryWithObjectsAndKeys:@"3",@"type_id",[UserDefalut objectForKey:UserUid],@"uid",sTime,@"stime", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
    [self showHud:@"加载中..." mode:MBProgressHUDModeNone];
}


- (void)submitZanOrCai:(BOOL)isZan themId:(NSString *)themId
{
    _requestType = RequestSubmitZanOrCaiType;
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/zan_cai",UrlStr];
    int tZanOrCai = 1;
    if (!isZan) {
        tZanOrCai = -1;
    }
    NSMutableDictionary     * tMutableDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:themId,@"tid",
                                             GetUserUid,@"uid",[NSString stringWithFormat:@"%d",tZanOrCai],@"operation", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)submitShare:(NSString *)themId
{
    _requestType = RequestSubmitShareType;
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/add_share_info",UrlStr];

    NSMutableDictionary     * tMutableDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:themId,@"tid",
                                             [UserDefalut objectForKey:UserUid],@"uid",@"123",@"shareTo", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)submitBrowser:(NSString *)themId
{
    _requestType = RequestSubmitBrowserType;
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/add_view",UrlStr];
    
    NSMutableDictionary     * tMutableDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:themId,@"tid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)submitReport:(NSString *)reportType
{
    _requestType = RequestSubmitReportType;
    NSString * tThemId = [[_themMutableAry objectAtIndex:_currentClickBtnTag] objectForKey:@"id"];
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/report",UrlStr];
    NSMutableDictionary     * tDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tThemId,@"tid",reportType,@"report_type",GetUserUid,@"uid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
}
#pragma mark -
#pragma mark 服务器返回数据
- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSMutableArray * tAry = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (_requestType == RequestThemType) {
        [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0.0f];
        [self handleThem:tAry];
        [self hideHud];
    }else if (_requestType == RequestMoreThemType){
        [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0.0f];
        [self handleMoreThem:tAry];
        
    }else if (_requestType == RequestSubmitShareType){
        
    }else if (_requestType == RequestSubmitZanOrCaiType){
        
    }else if (_requestType == RequestSubmitReportType){
        NSDictionary * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        int state = [[tDic objectForKey:@"status"] intValue];
        if (state == 1) {
            [self showHud:@"举报成功" mode:MBProgressHUDModeText];
        }else {
            [self showHud:@"举报失败" mode:MBProgressHUDModeText];
        }
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
    }
}

- (void)GetErr:(ASIHTTPRequest *)request
{
    NSLog(@"网络连接错误");
}

- (void)handleThem:(NSArray *)themAry
{
    if (themAry) {
        SafeRelease(_themMutableAry);
        _themMutableAry = [[NSMutableArray alloc] initWithArray:themAry];
        [_tableView reloadData];
    }
}

- (void)handleMoreThem:(NSArray *)themAry
{
    if (themAry) {
        [_themMutableAry addObjectsFromArray:themAry];
        [_tableView reloadData];
        [self hideHud];
    }else{
        [self showHud:@"没有更多数据了" mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
    }
}

#pragma mark -
#pragma mark private method

- (void)scrollToTop:(BOOL)animated {
    [_tableView setContentOffset:CGPointMake(0,0) animated:animated];
}

- (void)shareToWxResult:(NSNotification *)notification{
    NSString * tObject = [notification object];
    if (_shareToWx) {
        if ([tObject isEqualToString:@"-2"]) {
            [self showHud:@"分享失败" mode:MBProgressHUDModeText];
        }else if ([tObject isEqualToString:@"0"]){
            [self handleShareToWxSuc];
        }
        _shareToWx = NO;
        
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
    }
}

- (void)shareToQqResult:(NSNotification *)notification{
    NSString * tObject = [notification object];
    if (_shareToWx) {
        if ([tObject isEqualToString:@"-2"]) {
            [self showHud:@"分享失败" mode:MBProgressHUDModeText];
        }else if ([tObject isEqualToString:@"0"]){
            [self handleShareToWxSuc];
        }
        _shareToWx = NO;
        
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
    }
}

- (void)handleShareToWxSuc{
    [self showHud:@"分享成功" mode:MBProgressHUDModeText];
    NSDictionary * tDic = [_themMutableAry objectAtIndex:_currentClickBtnTag];
    NSMutableDictionary * tMutableDic = [NSMutableDictionary dictionaryWithDictionary:tDic];
    if (_currentClickBtnTag != -1) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:_currentClickBtnTag inSection:0];
        MainVideoTabViewCell  * tCell = (MainVideoTabViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        int  shareCount = [[tDic objectForKey:@"sharecount"] intValue];
        [tCell.shareNumBtn setTitle:[NSString stringWithFormat:@"%d",shareCount+1] forState:UIControlStateNormal];
        
        [tMutableDic setObject:[NSString stringWithFormat:@"%d",shareCount+1] forKey:@"sharecount"];
        [_themMutableAry replaceObjectAtIndex:_currentClickBtnTag withObject:tMutableDic];
        
        NSDictionary * tDic = [_themMutableAry objectAtIndex:_currentClickBtnTag];
        [self submitShare:[tDic objectForKey:@"id"]];
    }
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

- (NSString *)getVideoUrl:(NSDictionary *)tDic
{
    NSString    * tImgVideoUrl = [tDic objectForKey:@"attachment"];
    NSArray     * tAry = [tImgVideoUrl componentsSeparatedByString:@"|"];
    NSString    * tImgUrlStr = @"";
    NSString    * tVideoUrlStr = @"";
    for (int index = 0; index < [tAry count]; index++) {
        NSString    * tStr = [tAry objectAtIndex:index];
        if ([[tStr pathExtension ] isEqualToString:@"mp4"] || [[tStr pathExtension ]isEqualToString:@"3pg"]) {
            tVideoUrlStr = tStr;
        }else if ([[tStr pathExtension ] isEqualToString:@"jpg"]){
            tImgUrlStr = tStr;
        }
    }
    return tVideoUrlStr;
}

- (NSString *)getImgUrlStr:(NSDictionary *)tDic
{
    NSString    * tImgVideoUrl = [tDic objectForKey:@"attachment"];
    NSArray     * tAry = [tImgVideoUrl componentsSeparatedByString:@"|"];
    NSString    * tImgUrlStr = @"";
    NSString    * tVideoUrlStr = @"";
    for (int index = 0; index < [tAry count]; index++) {
        NSString    * tStr = [tAry objectAtIndex:index];
        if ([[tStr pathExtension ] isEqualToString:@"mp4"] || [[tStr pathExtension ]isEqualToString:@"3pg"]) {
            tVideoUrlStr = tStr;
        }else if ([[tStr pathExtension ] isEqualToString:@"jpg"]){
            tImgUrlStr = tStr;
        }
    }
    return tImgUrlStr;
}

- (int)getContentHeigh:(int)tIndex
{
    
    NSString    * tContent = [[_themMutableAry objectAtIndex:tIndex] objectForKey:@"content"];
    int     tHeigh = CellHeigh;
    if ([tContent length] > 32) {
        tHeigh = (([tContent length] - 32)/16 +1)*20;
        tHeigh = tHeigh + CellHeigh + 10;
    }
    return tHeigh;
}

- (void)refreshCellView:(MainVideoTabViewCell *)cell index:(int)index
{
    int tContentHeigh = [self getContentHeigh:index];
    [cell.bbsTxtContent setFrame:CGRectMake(cell.bbsTxtContent.frame.origin.x,
                                            cell.bbsTxtContent.frame.origin.y,
                                            cell.bbsTxtContent.frame.size.width,
                                            [self getContentHeigh:index])];
    
    [cell.videoThumImgView setFrame:CGRectMake(cell.videoThumImgView.frame.origin.x,
                                             cell.videoThumImgView.frame.origin.y+(tContentHeigh - CellHeigh),
                                             cell.videoThumImgView.frame.size.width, cell.videoThumImgView.frame.size.height)];
    [cell.bbsContentView setFrame:cell.videoThumImgView.frame];
    [cell.praiseBtn setFrame:CGRectMake(cell.praiseBtn.frame.origin.x,
                                        cell.praiseBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                        cell.praiseBtn.frame.size.width,
                                        cell.praiseBtn.frame.size.height)];
    
    [cell.prasieNumBtn setFrame:CGRectMake(cell.prasieNumBtn.frame.origin.x,
                                           cell.prasieNumBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                           cell.prasieNumBtn.frame.size.width,
                                           cell.prasieNumBtn.frame.size.height)];
    
    [cell.caiBtn setFrame:CGRectMake(cell.caiBtn.frame.origin.x,
                                     cell.caiBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                     cell.caiBtn.frame.size.width,
                                     cell.caiBtn.frame.size.height)];
    
    [cell.caiNumBtn setFrame:CGRectMake(cell.caiNumBtn.frame.origin.x,
                                        cell.caiNumBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                        cell.caiNumBtn.frame.size.width,
                                        cell.caiNumBtn.frame.size.height)];
    
    [cell.shareBtn setFrame:CGRectMake(cell.shareBtn.frame.origin.x,
                                       cell.shareBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                       cell.shareBtn.frame.size.width,
                                       cell.shareBtn.frame.size.height)];
    
    [cell.shareNumBtn setFrame:CGRectMake(cell.shareNumBtn.frame.origin.x,
                                          cell.shareNumBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                          cell.shareNumBtn.frame.size.width,
                                          cell.shareNumBtn.frame.size.height)];
    
    [cell.replayImgBtn setFrame:CGRectMake(cell.replayImgBtn.frame.origin.x,
                                           cell.replayImgBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                           cell.replayImgBtn.frame.size.width,
                                           cell.replayImgBtn.frame.size.height)];
    
    [cell.replyNumBtn setFrame:CGRectMake(cell.replyNumBtn.frame.origin.x,
                                          cell.replyNumBtn.frame.origin.y+(tContentHeigh - CellHeigh),
                                          cell.replyNumBtn.frame.size.width,
                                          cell.replyNumBtn.frame.size.height)];
}

- (void)initCellData:(MainVideoTabViewCell *)cell tDic:(NSDictionary *)tDic index:(int)index
{
    [cell.headIconImgView setWebImage:[NSURL URLWithString:judgeNull([tDic objectForKey:@"avatar"])] placeHolder:[UIImage imageNamed:@"icon"] downloadFlag:1];
    [cell.headIconImgView setTag:1];
    cell.userNameLabel.text = judgeNull([tDic objectForKey:@"poster"]);
    cell.bbsTxtContent.text = judgeNull([tDic objectForKey:@"content"]);
    cell.bbsAddTimeLabel.text = [[Common shareCommon] convTimeSeconds:[tDic objectForKey:@"atime"]];
    cell.bbsAddTimeLabel.font = [UIFont systemFontOfSize:11.0];
    
    [cell.prasieNumBtn  setTitle:[tDic objectForKey:@"zancount"] forState:UIControlStateNormal];
    [cell.replyNumBtn   setTitle:[tDic objectForKey:@"replycount"] forState:UIControlStateNormal];
    [cell.shareNumBtn   setTitle:[tDic objectForKey:@"sharecount"] forState:UIControlStateNormal];
    [cell.caiNumBtn     setTitle:[tDic objectForKey:@"caicount"] forState:UIControlStateNormal];
    
    
    if ([[Common shareCommon] isLogin]) {
        int tZan = [[tDic objectForKey:@"isZan"] intValue];
        int tCai = [[tDic objectForKey:@"isCai"] intValue];
        
        if (tZan == 1) {
            [cell.praiseBtn setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
        }
        if (tCai == 1) {
            [cell.caiBtn setImage:[UIImage imageNamed:@"cai_has_clicked"] forState:UIControlStateNormal];
        }
    }else{
        NSArray * tZanAry = [UserDefalut objectForKey:ZanThemAry];
        NSArray * tCaiAry = [UserDefalut objectForKey:CaiThemAry];
        for (int index = 0; index < [tZanAry count]; index++) {
            NSString    * tThemId = [tZanAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tDic objectForKey:@"id"]]) {
                [cell.praiseBtn setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
            }
        }
        
        for (int index = 0; index < [tCaiAry count]; index++) {
            NSString    * tThemId = [tCaiAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tDic objectForKey:@"id"]]) {
                [cell.caiBtn setImage:[UIImage imageNamed:@"cai_has_clicked"] forState:UIControlStateNormal];
            }
        }
    }

    
    NSString    * tImgVideoUrl = [tDic objectForKey:@"attachment"];
    NSArray     * tAry = [tImgVideoUrl componentsSeparatedByString:@"|"];
    NSString    * tImgUrlStr = @"";
    NSString    * tVideoUrlStr = @"";
    for (int index = 0; index < [tAry count]; index++) {
        NSString    * tStr = [tAry objectAtIndex:index];
        if ([[tStr pathExtension ] isEqualToString:@"mp4"] || [[tStr pathExtension ]isEqualToString:@"3pg"]) {
            tVideoUrlStr = tStr;
        }else if ([[tStr pathExtension ] isEqualToString:@"jpg"]){
            tImgUrlStr = tStr;
        }
    }
    
    [cell.videoThumImgView setWebImage:[NSURL URLWithString:tImgUrlStr] placeHolder:[UIImage imageNamed:@"icon"] downloadFlag:1];
    cell.videoThumImgView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.videoThumImgView setBackgroundColor:[UIColor blackColor]];
    [cell.videoThumImgView setTag:1];
    
    cell.bbsBrowserCount.text = [NSString stringWithFormat:@"%@播放",[tDic objectForKey:@"views"]];
    [cell.videoThumImgView addSubview:cell.bbsBrowserCount];
}


- (void)initCellEvent:(MainVideoTabViewCell *)cell tIndex:(int)tIndex{
    [cell.praiseBtn         addTarget:self action:@selector(zanAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.prasieNumBtn      addTarget:self action:@selector(zanAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.caiBtn         addTarget:self action:@selector(caiAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.caiNumBtn      addTarget:self action:@selector(caiAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.shareBtn      addTarget:self action:@selector(showShareActivity:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareNumBtn   addTarget:self action:@selector(showShareActivity:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.replayImgBtn addTarget:self action:@selector(replayAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.replyNumBtn   addTarget:self action:@selector(replayAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.prasieNumBtn  setTag:tIndex];
    [cell.replyNumBtn   setTag:tIndex];
    [cell.shareNumBtn   setTag:tIndex];
    [cell.caiNumBtn     setTag:tIndex];
    
    [cell.praiseBtn         setTag:tIndex];
    [cell.replayImgBtn      setTag:tIndex];
    [cell.shareBtn          setTag:tIndex];
    [cell.caiBtn            setTag:tIndex];
    [cell.playBtn           setTag:tIndex];
}

- (IBAction)zanAction:(id)sender{
    NSDictionary    * tDic = [_themMutableAry objectAtIndex:[sender tag]];
    NSMutableDictionary * tMutableDic = [[NSMutableDictionary alloc] initWithDictionary:tDic];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[sender tag] inSection:0];
    MainVideoTabViewCell    * tCell = (MainVideoTabViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    int tZan = [[tDic objectForKey:@"isZan"] intValue];
    int tCai = [[tDic objectForKey:@"isCai"] intValue];
    int tZanCount = [[tDic objectForKey:@"zancount"] intValue];
    
    if ([[Common shareCommon] isLogin]) {
        if (tZan == 1 || tCai == 1) {
            return;
        }
    }else{
        NSArray * tZanAry = [UserDefalut objectForKey:ZanThemAry];
        NSArray * tCaiAry = [UserDefalut objectForKey:CaiThemAry];
        for (int index = 0; index < [tZanAry count]; index++) {
            NSString    * tThemId = [tZanAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tDic objectForKey:@"id"]]) {
                return;
            }
        }
        
        for (int index = 0; index < [tCaiAry count]; index++) {
            NSString    * tThemId = [tCaiAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tDic objectForKey:@"id"]]) {
                return;
            }
        }
        NSMutableArray  * tAry = [NSMutableArray arrayWithArray:tZanAry];
        [tAry addObject:[tDic objectForKey:@"id"]];
        [UserDefalut setObject:tAry forKey:ZanThemAry];
    }

    [tCell.praiseBtn    setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
    [tCell.prasieNumBtn setTitle:[NSString stringWithFormat:@"%d",tZanCount+1] forState:UIControlStateNormal];
    [tMutableDic setObject:[NSString stringWithFormat:@"%d",tZanCount+1] forKey:@"zancount"];
    [tMutableDic setObject:@"1" forKey:@"isZan"];
    [_themMutableAry replaceObjectAtIndex:[sender tag] withObject:tMutableDic];
    NSString * tThemId = [tMutableDic objectForKey:@"id"];
    [self submitZanOrCai:YES themId:tThemId];
}

- (IBAction)caiAction:(id)sender{
    NSDictionary    * tDic = [_themMutableAry objectAtIndex:[sender tag]];
    NSMutableDictionary * tMutableDic = [[NSMutableDictionary alloc] initWithDictionary:tDic];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[sender tag] inSection:0];
    MainVideoTabViewCell    * tCell = (MainVideoTabViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    int tZan = [[tDic objectForKey:@"isZan"] intValue];
    int tCai = [[tDic objectForKey:@"isCai"] intValue];
    int tCaicount = [[tDic objectForKey:@"caicount"] intValue];
    
    if ([[Common shareCommon] isLogin]) {
        if (tZan == 1 || tCai == 1) {
            return;
        }
    }else{
        NSArray * tZanAry = [UserDefalut objectForKey:ZanThemAry];
        NSArray * tCaiAry = [UserDefalut objectForKey:CaiThemAry];
        for (int index = 0; index < [tZanAry count]; index++) {
            NSString    * tThemId = [tZanAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tDic objectForKey:@"id"]]) {
                return;
            }
        }
        
        for (int index = 0; index < [tCaiAry count]; index++) {
            NSString    * tThemId = [tCaiAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tDic objectForKey:@"id"]]) {
                return;
            }
        }
        NSMutableArray  * tAry = [NSMutableArray arrayWithArray:tCaiAry];
        [tAry addObject:[tDic objectForKey:@"id"]];
        [UserDefalut setObject:tAry forKey:CaiThemAry];
    }

    [tCell.caiBtn setImage:[UIImage imageNamed:@"cai_has_clicked"] forState:UIControlStateNormal];
    [tCell.caiNumBtn setTitle:[NSString stringWithFormat:@"%d",tCaicount+1] forState:UIControlStateNormal];
    [tMutableDic setObject:[NSString stringWithFormat:@"%d",tCaicount+1] forKey:@"caicount"];
    [tMutableDic setObject:@"1" forKey:@"isCai"];
    [_themMutableAry replaceObjectAtIndex:[sender tag] withObject:tMutableDic];

    NSString * tThemId = [tMutableDic objectForKey:@"id"];
    [self submitZanOrCai:NO themId:tThemId];
}


- (IBAction)replayAction:(id)sender{
    if (_mainVideoCommentViewCtl == nil) {
        _mainVideoCommentViewCtl = [[MainVideoCommentViewCtl alloc] initWithNibName:@"MainVideoCommentView" bundle:nil];
    }
    [self stopVideo];
    [_tableView reloadData];
    [_mainVideoCommentViewCtl setThemDic:[_themMutableAry objectAtIndex:[sender tag]]];
    [self pushMyCtl:_mainVideoCommentViewCtl];
//    [self.navigationController pushViewController:_mainVideoCommentViewCtl animated:YES];
//    [self.tabBarController.tabBar setHidden:YES];
    double tt = moviePlayCtl.playableDuration;
    NSLog(@"%f",tt);
    SafeRelease(moviePlayCtl);
    
    tCurrentPlayVideoTag = -1;
}

- (void)report:(id)sender
{
    NSArray * _portRaitAry = ReportAry;
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"举报"
                                                    otherButtonTitles:[_portRaitAry objectAtIndex:0],
                                  [_portRaitAry objectAtIndex:1],
                                  [_portRaitAry objectAtIndex:2],
                                  [_portRaitAry objectAtIndex:3],
                                  [_portRaitAry objectAtIndex:4], nil];
    
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSArray * tReportAry = ReportAry;
    if (buttonIndex != 0 && buttonIndex <= [tReportAry count]) {
        [self submitReport:[NSString stringWithFormat:@"%d",buttonIndex]];
    }
    
}


//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
//初始化刷新视图
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#pragma mark
#pragma methods for creating and removing the header view

-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                     self.view.frame.size.width, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    
	[_tableView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)removeHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = nil;
}

-(void)setFooterView{
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(_tableView.contentSize.height, _tableView.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview]) {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              _tableView.frame.size.width,
                                              self.view.bounds.size.height);
    }else {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         _tableView.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [_tableView addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}

-(void)removeFooterView{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark-
#pragma mark force to show the refresh headerView
-(void)showRefreshHeader:(BOOL)animated{
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		_tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        // scroll the table view to the top region
        [_tableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [UIView commitAnimations];
	}
	else
	{
        _tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[_tableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
	}
    
    [_refreshHeaderView setState:EGOOPullRefreshLoading];
}
//===============
//刷新delegate
#pragma mark -
#pragma mark data reloading methods that must be overide by the subclass

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
	
	//  should be calling your tableviews data source model to reload
	_reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader) {
        // pull down to refresh data
        //        [self performSelector:@selector(refreshView) withObject:nil afterDelay:2.0];
        [self refreshView];
    }else if(aRefreshPos == EGORefreshFooter){
        [self getNextPageView];
        // pull up to load more data
        //        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:2.0];
    }
    
	// overide, the actual loading data operation is done in the subclass
}

#pragma mark -
#pragma mark method that should be called when the refreshing is finished
- (void)finishReloadingData{
	
	//  model should call this when its done loading
	_reloading = NO;
    
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        [self setFooterView];
    }
    
    // overide, the actula reloading tableView operation and reseting position operation is done in the subclass
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
	if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
	
	[self beginToReloadData:aRefreshPos];
	
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}


// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

//刷新调用的方法
-(void)refreshView{
    [self getThem:@"0"];
}
//加载调用的方法
-(void)getNextPageView{
    NSString    * tStime = [[_themMutableAry lastObject] objectForKey:@"atime"];
    [self getThem:tStime];
}

-(void)testFinishedLoadData{
    
    [self finishReloadingData];
    [self setFooterView];
}
@end
