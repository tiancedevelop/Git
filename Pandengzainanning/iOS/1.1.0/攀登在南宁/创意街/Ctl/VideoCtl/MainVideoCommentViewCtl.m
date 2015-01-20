//
//  MainVideoCommentViewCtl.m
//  创意街
//
//  Created by ios on 14-11-25.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "MainVideoCommentViewCtl.h"
#import "MainVideoTabViewCell.h"
#import "UIImageView+RZWebImage.h"
#import "HYActivityView.h"
#import "WXApi.h"
#import "MBProgressHUD.h"
#import "TencentOpenAPI/TencentOpenSDK.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommentTabViewCell.h"
#import "LoginViewCtl.h"
#import <AVFoundation/AVFoundation.h>

@interface MainVideoCommentViewCtl ()<HYActivityViewDelegate>
{
    MPMoviePlayerController * moviePlayCtl;
    LoginViewCtl            * _loginViewCtl;
    NSMutableDictionary     * _themDic;
    NSMutableArray          * _commentAry;
    RequestType         _requestType;
    enum WXScene        _scene;
    BOOL        _shareToWx;
}

@property (nonatomic, strong) HYActivityView *activityView;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation MainVideoCommentViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[Common shareCommon] setBackItemImg:self];
        moviePlayCtl = [[MPMoviePlayerController alloc] init];
    }
    return self;
}

- (void)back:(id)sender {
    [self stopVideo];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_txtView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"评论";
    // Do any additional setup after loading the view.
    [_txtView setDelegate:self];
    [[NSNotificationCenter defaultCenter]
     
     addObserver:self selector:@selector(shareToWxResult:) name:ShareToWxResultNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareToQqResult:) name:ShareToQQResultNotification object:nil];
    [self createHeaderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setThemDic:(NSDictionary *)themDic
{
    [themDic retain];
    SafeRelease(_themDic);
    SafeRelease(_commentAry);
    _themDic = [[NSMutableDictionary alloc] initWithDictionary:themDic];
    [self getCommentList:@"0"];
    [_tableView reloadData];
}

#pragma mark - Table view data source

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return indexPath;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    return 1.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_commentAry count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tIndex = [indexPath indexAtPosition:1];

    if (tIndex == 0) {
        int tContentHight = [self getContentHeigh:tIndex];
        
        return 400+(tContentHight - CellHeigh);
    }
    NSDictionary    * tDic = [_commentAry objectAtIndex:tIndex-1];
    int tContentHeigh = [[Common shareCommon] getCommentHeigh:judgeNull([tDic objectForKey:@"content"])]+15;
    return tContentHeigh;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCell";
    
    NSUInteger tIndex        = [indexPath indexAtPosition:1];
    
    if (tIndex == 0) {
        MainVideoTabViewCell *cell = (MainVideoTabViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        SafeRelease(cell);
        if (nil == cell) {
            cell = [[MainVideoTabViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            
            [cell setTag:tIndex];
            UIView  * backView = [[UIView alloc] initWithFrame:cell.contentView.frame];
            backView.backgroundColor = [UIColor whiteColor];
            cell.selectedBackgroundView = backView;
        }
        
        [self refreshCellView:cell index:tIndex];
        [self initCellData:cell tDic:_themDic index:0];
        [self initCellEvent:cell tIndex:0];
        return cell;
    }
    
    CommentTabViewCell *cell = (CommentTabViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SafeRelease(cell);
    if (nil == cell) {
        cell = [[CommentTabViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary    * tDic = [_commentAry objectAtIndex:tIndex-1];
    cell.userNameLabel.text = judgeNull([tDic objectForKey:@"name"]);
    cell.bbsContentLabel.text = judgeNull([tDic objectForKey:@"content"]);


    [cell.headIconImgView setWebImage:[NSURL URLWithString:judgeNull([tDic objectForKey:@"avatar"])] placeHolder:[UIImage imageNamed:@"icon"] downloadFlag:tIndex];
    [cell.headIconImgView setTag:tIndex];
    int tContentHeigh = [[Common shareCommon] getCommentHeigh:judgeNull([tDic objectForKey:@"content"])];
    [cell.bbsContentLabel setFrame:CGRectMake(cell.bbsContentLabel.frame.origin.x,
                                              cell.bbsContentLabel.frame.origin.y,
                                              cell.bbsContentLabel.frame.size.width,
                                              cell.bbsContentLabel.frame.size.height+(tContentHeigh - CellHeigh))];
    NSString * tRzcount = [tDic objectForKey:@"rzcount"] ;
    if (![tRzcount isEqualToString:@"0"] && tRzcount != nil) {
        [cell.prasieNumBtn setTitle:tRzcount forState:UIControlStateNormal];
    }else{
        [cell.prasieNumBtn setTitle:@"+1" forState:UIControlStateNormal];
    }
    
    [cell.prasieBtn addTarget:self action:@selector(zanCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.prasieNumBtn addTarget:self action:@selector(zanCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.prasieNumBtn setTag:tIndex];
    [cell.prasieBtn     setTag:tIndex];
    if ([[Common shareCommon] isLogin]) {
        int tZan = [[tDic objectForKey:@"iszanreply"] intValue];
        if (tZan == 1) {
            [cell.prasieBtn setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
        }
    }else{
        NSArray * tCommentAry = [UserDefalut objectForKey:ZanCommentAry];
        NSString * tRid = [tDic objectForKey:@"rid"];
        for (int index = 0; index < [tCommentAry count]; index++) {
            
            if ([[tCommentAry objectAtIndex:index] isEqualToString:tRid]) {
                [cell.prasieBtn setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
            }
        }
    }
    return cell;
}

#pragma mark -
#pragma mark private Method
- (int)getContentHeigh:(int)tIndex
{
    
    NSString    * tContent = [_themDic objectForKey:@"content"];
    int     tHeigh = CellHeigh;
    if ([tContent length] > 28) {
        tHeigh = (([tContent length] - 28)/14 +1)*20;
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
            NSString    * tThemId = judgeNull([tZanAry objectAtIndex:index]);
            if ([tThemId isEqualToString:[tDic objectForKey:@"id"]]) {
                [cell.praiseBtn setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
            }
        }
        
        for (int index = 0; index < [tCaiAry count]; index++) {
            NSString    * tThemId = judgeNull([tCaiAry objectAtIndex:index]);
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
    cell.bbsBrowserCount.text = [NSString stringWithFormat:@"%@播放",[_themDic objectForKey:@"views"]];
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
    NSMutableDictionary * tMutableDic = [[NSMutableDictionary alloc] initWithDictionary:_themDic];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[sender tag] inSection:0];
    MainVideoTabViewCell    * tCell = (MainVideoTabViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    int tZan = [[tMutableDic objectForKey:@"isZan"] intValue];
    int tCai = [[tMutableDic objectForKey:@"isCai"] intValue];
    int tZanCount = [[tMutableDic objectForKey:@"zancount"] intValue];
    
    if ([[Common shareCommon] isLogin]) {
        if (tZan == 1 || tCai == 1) {
            return;
        }
    }else{
        NSArray * tZanAry = [UserDefalut objectForKey:ZanThemAry];
        NSArray * tCaiAry = [UserDefalut objectForKey:CaiThemAry];
        for (int index = 0; index < [tZanAry count]; index++) {
            NSString    * tThemId = [tZanAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tMutableDic objectForKey:@"id"]]) {
                return;
            }
        }
        
        for (int index = 0; index < [tCaiAry count]; index++) {
            NSString    * tThemId = [tCaiAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tMutableDic objectForKey:@"id"]]) {
                return;
            }
        }
        NSMutableArray  * tAry = [NSMutableArray arrayWithArray:tZanAry];
        [tAry addObject:[tMutableDic objectForKey:@"id"]];
        [UserDefalut setObject:tAry forKey:ZanThemAry];
    }
    
    [tCell.praiseBtn    setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
    [tCell.prasieNumBtn setTitle:[NSString stringWithFormat:@"%d",tZanCount+1] forState:UIControlStateNormal];
    [tMutableDic setObject:@"1" forKey:@"isZan"];
    [tMutableDic setObject:[NSString stringWithFormat:@"%d",tZanCount+1] forKey:@"zancount"];

    NSString * tThemId = [tMutableDic objectForKey:@"id"];
    [self submitZanOrCai:YES themId:tThemId];
}

- (IBAction)zanCommentAction:(id)sender
{
    NSDictionary    * tDic = [_commentAry objectAtIndex:[sender tag]-1];
    NSMutableDictionary * tMutableDic = [[NSMutableDictionary alloc] initWithDictionary:tDic];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[sender tag] inSection:0];
    CommentTabViewCell    * tCell = (CommentTabViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    int tZan = [[tMutableDic objectForKey:@"iszanreply"] intValue];
    int tZanCount = [[tMutableDic objectForKey:@"rzcount"] intValue];
    
    if ([[Common shareCommon] isLogin]) {
        if (tZan == 1) {
            return;
        }
    }else{
        NSArray * tZanAry = [UserDefalut objectForKey:ZanCommentAry];

        for (int index = 0; index < [tZanAry count]; index++) {
            NSString    * tThemId = [tZanAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tMutableDic objectForKey:@"rid"]]) {
                return;
            }
        }
        
        NSMutableArray  * tAry = [NSMutableArray arrayWithArray:tZanAry];
        [tAry addObject:[tMutableDic objectForKey:@"rid"]];
        [UserDefalut setObject:tAry forKey:ZanCommentAry];
    }
    
    [tCell.prasieBtn    setImage:[UIImage imageNamed:@"ding_has_clicked"] forState:UIControlStateNormal];
    [tCell.prasieNumBtn setTitle:[NSString stringWithFormat:@"%d",tZanCount+1] forState:UIControlStateNormal];
    [tMutableDic setObject:[NSString stringWithFormat:@"%d",tZanCount+1] forKey:@"zancount"];
    [tMutableDic setObject:@"1" forKey:@"iszanreply"];
    NSString * tCommentId = [tMutableDic objectForKey:@"rid"];
    [_commentAry replaceObjectAtIndex:[sender tag]-1 withObject:tMutableDic];
    [self submitZanComment:tCommentId];
}

- (IBAction)caiAction:(id)sender{
    NSMutableDictionary * tMutableDic = [[NSMutableDictionary alloc] initWithDictionary:_themDic];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[sender tag] inSection:0];
    MainVideoTabViewCell    * tCell = (MainVideoTabViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    int tZan = [[tMutableDic objectForKey:@"isZan"] intValue];
    int tCai = [[tMutableDic objectForKey:@"isCai"] intValue];
    int tCaicount = [[tMutableDic objectForKey:@"caicount"] intValue];
    
    if ([[Common shareCommon] isLogin]) {
        if (tZan == 1 || tCai == 1) {
            return;
        }
    }else{
        NSArray * tZanAry = [UserDefalut objectForKey:ZanThemAry];
        NSArray * tCaiAry = [UserDefalut objectForKey:CaiThemAry];
        for (int index = 0; index < [tZanAry count]; index++) {
            NSString    * tThemId = [tZanAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tMutableDic objectForKey:@"id"]]) {
                return;
            }
        }
        
        for (int index = 0; index < [tCaiAry count]; index++) {
            NSString    * tThemId = [tCaiAry objectAtIndex:index];
            if ([tThemId isEqualToString:[tMutableDic objectForKey:@"id"]]) {
                return;
            }
        }
        NSMutableArray  * tAry = [NSMutableArray arrayWithArray:tCaiAry];
        [tAry addObject:[tMutableDic objectForKey:@"id"]];
        [UserDefalut setObject:tAry forKey:CaiThemAry];
    }
    
    [tCell.caiBtn setImage:[UIImage imageNamed:@"cai_has_clicked"] forState:UIControlStateNormal];
    [tCell.caiNumBtn setTitle:[NSString stringWithFormat:@"%d",tCaicount+1] forState:UIControlStateNormal];
    [tMutableDic setObject:@"1" forKey:@"isCai"];
    [tMutableDic setObject:[NSString stringWithFormat:@"%d",tCaicount+1] forKey:@"caicount"];
    
    NSString * tThemId = [tMutableDic objectForKey:@"id"];
    [self submitZanOrCai:NO themId:tThemId];
}


- (IBAction)replayAction:(id)sender{
//    [_txtView re]
}


- (IBAction)commentAction:(id)sender
{
    if (![[Common shareCommon] isLogin]) {
        if (nil == _loginViewCtl) {
            _loginViewCtl = [[LoginViewCtl alloc] initWithNibName:@"LoginView" bundle:nil];
        }
        [self.navigationController pushViewController:_loginViewCtl animated:YES];
    }else{
        [_txtView resignFirstResponder];
        if (![_txtView hasText]) {
            [self showHud:@"内容不能为空" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
            return;
        }
        [self submitComment];
    }
    
    
}
#pragma mark -
#pragma mark 服务器交互

- (void)submitBrowser:(NSString *)themId
{
    _requestType = RequestSubmitBrowserType;
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/add_view",UrlStr];
    
    NSMutableDictionary     * tMutableDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:themId,@"tid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)getCommentList:(NSString *)t
{
    if ([t isEqualToString:@"0"]) {
        _requestType = RequestThemCommentType;
    }else{
        _requestType = RequestMoreThemCommentType;
    }
    
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/thread_reply",UrlStr];
    NSMutableDictionary    * tDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[_themDic objectForKey:@"id"],@"tid",t,@"stime",[UserDefalut objectForKey:UserUid],@"uid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
}

- (void)submitComment
{
    _requestType = RequestSubmitCommentType;
    NSString * tUrlStr = [NSString stringWithFormat:@"%@/Thread/post_reply",UrlStr];
    NSMutableDictionary * tDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UserDefalut objectForKey:UserUid],@"uid",[_themDic objectForKey:@"id"],@"tid",_txtView.text,@"content", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
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

- (void)submitZanComment:(NSString *)rid
{
    _requestType = RequestSubmitZanCommentType;
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/praise_reply",UrlStr];
    NSMutableDictionary * tMutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:rid,@"rid",GetUserUid,@"uid", nil];
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

- (void)submitReport:(NSString *)reportType
{
    _requestType = RequestSubmitReportType;
    NSString * tThemId = [_themDic objectForKey:@"id"];
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@/Thread/report",UrlStr];
    NSMutableDictionary     * tDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tThemId,@"tid",reportType,@"report_type",GetUserUid,@"uid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tDic];
}


- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSDictionary    * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSArray * tAry = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//    int status = [[tDic objectForKey:@"status"] intValue];
    if (_requestType == RequestThemCommentType) {
        [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0.0f];
        if (tAry) {
            SafeRelease(_commentAry);
            _commentAry = [[NSMutableArray alloc] initWithArray:tAry];
            [self stopVideo];
            [_tableView reloadData];
        }
    }else if (_requestType == RequestMoreThemCommentType){
        [self performSelector:@selector(testFinishedLoadData) withObject:nil afterDelay:0.0f];
        if (tAry) {
            [_commentAry addObjectsFromArray:tAry];
            [_tableView reloadData];
        }
    }else if (_requestType == RequestSubmitCommentType){
        int status = [[tDic objectForKey:@"status"] intValue];
        if (status == 1) {
            [self showHud:@"评论成功" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
            NSDictionary   * tDic = [NSDictionary dictionaryWithObjectsAndKeys:_txtView.text,@"content",[UserDefalut objectForKey:UserName],@"name",[UserDefalut objectForKey:UserIconPath],@"avatar", nil];
            [_themDic setValue:[NSString stringWithFormat:@"%d",[[_themDic objectForKey:@"replycount"] intValue]+1] forKeyPath:@"replycount"];
            if (_commentAry == nil) {
                _commentAry = [[NSMutableArray alloc] init];
            }
            [_commentAry insertObject:tDic atIndex:0];
            [_tableView reloadData];
            [_txtView setText:@""];
        }else{
            [self showHud:@"评论失败" mode:MBProgressHUDModeText];
            [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
        }
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

#pragma mark -
#pragma mark 微信 QQ 分享
- (void)activityHide
{
//    [self.tabBarController.tabBar setHidden:NO];
}

- (IBAction)showShareActivity:(id)sender
{

    if (self.activityView.isShowing) {
        return;
    }
    [self.tabBarController.tabBar setHidden:YES];
    SafeRelease(self.activityView);
    
    if (!self.activityView) {
        self.activityView = [[HYActivityView alloc]initWithTitle:@"分享到" referView:self.view];
        
        //横屏会变成一行6个, 竖屏无法一行同时显示6个, 会自动使用默认一行4个的设置.
        self.activityView.numberOfButtonPerLine = 6;
        
        ButtonView *bv = [[ButtonView alloc]initWithText:@"QQ好友" image:[UIImage imageNamed:@"qq_normal"] handler:^(ButtonView *buttonView){
            NSLog(@"点击新浪微博");
            [self shareTxtToQqFriend:sender isQqFriend:YES];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"QQ空间" image:[UIImage imageNamed:@"qzone_normal"] handler:^(ButtonView *buttonView){
            [self shareTxtToQqFriend:sender isQqFriend:NO];
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

- (void)shareVideoToWX:(id)sender
{
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@?id=%d&type=ios",ShareUrl,[[_themDic objectForKey:@"id"] intValue]];
    NSString    * tImgUrlStr = [self getImgUrlStr:_themDic];
    NSURL       * tImgUrl = [NSURL URLWithString:tImgUrlStr];
    NSString    * tImgPath =[NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%u",tImgUrl.description.hash];
    NSData      * tData=[NSData dataWithContentsOfFile:tImgPath];
    
    WXMediaMessage *message = [WXMediaMessage message];
    if (_scene == WXSceneTimeline) {
        message.title = [NSString stringWithFormat:@"分享视频:%@",[_themDic objectForKey:@"content"]];
    }else{
        message.title = @"分享视频";
        message.description = [_themDic objectForKey:@"content"];
    }
    
    if ([tData length] > 20000) {
        UIImage * tImg = [UIImage imageWithContentsOfFile:tImgPath];
        tData = UIImageJPEGRepresentation(tImg, 0.1);
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
    
    NSString    * tUrlStr = [NSString stringWithFormat:@"%@?id=%d&type=ios",ShareUrl,[[_themDic objectForKey:@"id"] intValue]];
    NSString    * tImgUrlStr = [self getImgUrlStr:_themDic];
    NSURL       * tImgUrl = [NSURL URLWithString:tImgUrlStr];
    
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:tUrlStr]
                                title: @"分享视频"
                                description:[_themDic objectForKey:@"content"]
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
#pragma mark private method
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

    NSMutableDictionary * tMutableDic = [NSMutableDictionary dictionaryWithDictionary:_themDic];
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        MainVideoTabViewCell  * tCell = (MainVideoTabViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        int  shareCount = [[_themDic objectForKey:@"sharecount"] intValue];
        [tCell.shareNumBtn setTitle:[NSString stringWithFormat:@"%d",shareCount+1] forState:UIControlStateNormal];
        
        [tMutableDic setObject:[NSString stringWithFormat:@"%d",shareCount+1] forKey:@"sharecount"];

        [self submitShare:[_themDic objectForKey:@"id"]];
}


#pragma mark -
#pragma mark play
- (IBAction)playVideo:(id)sender{
    int tTag = [sender tag];
    
    
    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:tTag inSection:0];
    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    //    [btnCell.videoThumImgView addSubview:moviePlayCtl.view];
    [[moviePlayCtl view] setFrame:CGRectMake(0, 0, btnCell.bbsContentView.frame.size.width, btnCell.bbsContentView.frame.size.height)];
    [moviePlayCtl setContentURL:[NSURL URLWithString:[self getVideoUrl:_themDic]]];
    
    [moviePlayCtl setControlStyle:MPMovieControlStyleNone];
    [btnCell.playBtn setHidden:YES];
    [btnCell.videoThumImgView addSubview:btnCell.indicatorView];
    
    moviePlayCtl.repeatMode = MPMovieRepeatModeOne;
    [moviePlayCtl play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieReadyPlay:)
                                                 name:MPMoviePlayerReadyForDisplayDidChangeNotification
                                               object:moviePlayCtl];
    
    [self submitBrowser:[_themDic objectForKey:@"id"]];
    int tBrowserCount = [[_themDic objectForKey:@"views"] intValue];
    [btnCell.bbsBrowserCount setText:[NSString stringWithFormat:@"%d播放",tBrowserCount+1]];
    [_themDic setObject:[NSString stringWithFormat:@"%d",tBrowserCount+1] forKey:@"views"];
}

- (void)stopVideo
{
//    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:0 inSection:0];
//    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    [moviePlayCtl stop];
}

- (IBAction)moviePlaTypesAvailablechange:(id)sender
{
    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:0 inSection:0];
    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    [btnCell.indicatorView removeFromSuperview];
    NSLog(@"moviePlaTypesAvailablechange");
}

- (IBAction)movieReadyPlay:(id)sender
{
    NSLog(@"moviePlayTypeAvailabBackDidchange");
    NSIndexPath * tIndexPathBtn = [NSIndexPath indexPathForRow:0 inSection:0];
    MainVideoTabViewCell * btnCell = (MainVideoTabViewCell *) [_tableView cellForRowAtIndexPath:tIndexPathBtn];
    [btnCell.videoThumImgView addSubview:moviePlayCtl.view];
    [btnCell.videoThumImgView addSubview:btnCell.bbsBrowserCount];
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
                          CGRectMake(0.0f, 0.0f - _tableView.frame.size.height,
                                     _tableView.frame.size.width, _tableView.frame.size.height)];
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
                                         _tableView.frame.size.width, _tableView.frame.size.height)];
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
    [self getCommentList:@"0"];
}
//加载调用的方法
-(void)getNextPageView{
    NSString    * tStime = [[_commentAry lastObject] objectForKey:@"atime"];
    [self getCommentList:tStime];
}

-(void)testFinishedLoadData{
    
    [self finishReloadingData];
    [self setFooterView];
}

@end
