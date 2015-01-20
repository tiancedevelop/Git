//
//  MainVideoTabViewCell.m
//  创意街
//
//  Created by ios on 14-11-12.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "MainVideoTabViewCell.h"
#import "MyMovieViewController.h"
@implementation MainVideoTabViewCell
@synthesize praiseBtn,prasieNumBtn,replayImgBtn,replyNumBtn,shareBtn,shareNumBtn,headIconImgView,userNameLabel,bbsAddTimeLabel,bbsContentView,caiBtn,caiNumBtn,moviePlayCtl,indicatorView,playDuration,bbsTxtContent,playBtn,videoThumImgView,bbsBrowserCount;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        playBtn             = [[UIButton alloc] initWithFrame:CGRectMake(110, 110, 60, 60)];
        playDuration        = [[UILabel alloc] initWithFrame:CGRectMake(IphoneWidth-70, 270, 40, 15)];
        bbsBrowserCount     = [[UILabel alloc] initWithFrame:CGRectMake(IphoneWidth-110, 0, 70, 15)];
        bbsTxtContent       = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, IphoneWidth-30, CellHeigh)];
        headIconImgView     = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 25, 25)];
        headIconImgView.layer.masksToBounds = YES;
        headIconImgView.layer.cornerRadius = 12.5;
        userNameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 100, 15)];
        bbsAddTimeLabel     = [[UILabel alloc] initWithFrame:CGRectMake(45, 20, 150, 10)];
        bbsContentView      = [[UIView alloc] initWithFrame:CGRectMake(15, 70, 280, IphoneWidth-30)];
        videoThumImgView    = [[UIImageView alloc] initWithFrame:CGRectMake(15, 70, 280, IphoneWidth-30)];
        moviePlayCtl        = [[MPMoviePlayerController alloc] init];
        bbsAddTimeLabel.font = [UIFont systemFontOfSize:2.0];
        userNameLabel.font   = [UIFont systemFontOfSize:12.0];
        playDuration.backgroundColor    = [UIColor clearColor];
        playDuration.textColor          = [UIColor whiteColor];
        playDuration.font               = [UIFont systemFontOfSize:12.0];
        indicatorView        = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(IphoneWidth/2-35,125,30,30)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicatorView startAnimating];
        [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//        [bbsBrowserCount setBackgroundColor:[UIColor grayColor]];
        bbsTxtContent.numberOfLines = 0;
        [bbsBrowserCount setTextColor:[UIColor whiteColor]];
        bbsBrowserCount.textAlignment = NSTextAlignmentRight;
        bbsBrowserCount.font = [UIFont systemFontOfSize:10.0];
        [bbsBrowserCount setText:@"8900播放"];
        int tImgWidthOrHegih = 25;
        int tBtnY           = 370;
        int tWidth          = (IphoneWidth-30)/4;
        int tNumWidth       = tWidth-tImgWidthOrHegih;
        
        int tBtnX       = 15;
        int tNumBtnX    = tBtnX+tImgWidthOrHegih;
        
        praiseBtn       = [[UIButton alloc] initWithFrame:CGRectMake(tBtnX, tBtnY, tImgWidthOrHegih, tImgWidthOrHegih)];
        prasieNumBtn    = [[UIButton alloc] initWithFrame:CGRectMake(tNumBtnX, tBtnY, tNumWidth, 25)];
        
        tBtnX       = tBtnX + tWidth;
        tNumBtnX    = tNumBtnX + tWidth;
        
        caiBtn              = [[UIButton alloc] initWithFrame:CGRectMake(tBtnX, tBtnY, tImgWidthOrHegih, tImgWidthOrHegih)];
        caiNumBtn           = [[UIButton alloc] initWithFrame:CGRectMake(tNumBtnX, tBtnY, tNumWidth, 25)];
        
        tBtnX       = tBtnX + tWidth;
        tNumBtnX    = tNumBtnX + tWidth;
        
        shareBtn        = [[UIButton alloc] initWithFrame:CGRectMake(tBtnX, tBtnY, tImgWidthOrHegih, tImgWidthOrHegih)];
        shareNumBtn     = [[UIButton alloc] initWithFrame:CGRectMake(tNumBtnX, tBtnY, tNumWidth, 25)];
        
        tBtnX       = tBtnX + tWidth;
        tNumBtnX    = tNumBtnX + tWidth;
        
        replayImgBtn        = [[UIButton alloc] initWithFrame:CGRectMake(tBtnX, tBtnY, tImgWidthOrHegih, tImgWidthOrHegih)];
        replyNumBtn         = [[UIButton alloc] initWithFrame:CGRectMake(tNumBtnX, tBtnY, tNumWidth, 25)];
        
        
        
        [shareBtn       setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
        [praiseBtn      setImage:[UIImage imageNamed:@"ding_not_clicked"] forState:UIControlStateNormal];
        [replayImgBtn   setImage:[UIImage imageNamed:@"commend"] forState:UIControlStateNormal];
        [caiBtn         setImage:[UIImage imageNamed:@"cai_not_clicked"] forState:UIControlStateNormal];
        
        [shareNumBtn    setTitle:@"1111" forState:UIControlStateNormal];
        [prasieNumBtn   setTitle:@"2222" forState:UIControlStateNormal];
        [replyNumBtn    setTitle:@"43424" forState:UIControlStateNormal];
        [caiNumBtn      setTitle:@"123" forState:UIControlStateNormal];
        
//        caiNumBtn.titleLabel.text = @"1345";
        UIFont  * tSysFont = [UIFont systemFontOfSize:15];
        UIColor * tColor    = [UIColor grayColor];
        
        shareNumBtn.titleLabel.font = tSysFont;
        caiNumBtn.titleLabel.font = tSysFont;
        replyNumBtn.titleLabel.font = tSysFont;
        prasieNumBtn.titleLabel.font = tSysFont;
        
        bbsAddTimeLabel.textColor = tColor;
        
        [shareNumBtn setTitleColor:tColor forState:UIControlStateNormal];
        [caiNumBtn setTitleColor:tColor forState:UIControlStateNormal];
        [replyNumBtn setTitleColor:tColor forState:UIControlStateNormal];
        [prasieNumBtn setTitleColor:tColor forState:UIControlStateNormal];
        
//        shareNumBtn.titleLabel.textColor    = [UIColor blackColor];
//        prasieNumBtn.titleLabel.textColor   = [UIColor blackColor];
//        replyNumBtn.titleLabel.textColor    = [UIColor blackColor];
//        caiNumBtn.titleLabel.textColor      = [UIColor blackColor];
        
        [self.contentView addSubview:prasieNumBtn];
        [self.contentView addSubview:praiseBtn];
        [self.contentView addSubview:replyNumBtn];
        [self.contentView addSubview:replayImgBtn];
        [self.contentView addSubview:shareNumBtn];
        [self.contentView addSubview:shareBtn];
        [self.contentView addSubview:headIconImgView];
        [self.contentView addSubview:userNameLabel];
        [self.contentView addSubview:bbsAddTimeLabel];
        [self.contentView addSubview:bbsContentView];
        [self.contentView addSubview:caiBtn];
        [self.contentView addSubview:caiNumBtn];
        [self.contentView addSubview:bbsTxtContent];
//        [self.bbsContentView addSubview:playBtn];
        [self.contentView addSubview:videoThumImgView];
        [self.videoThumImgView addSubview:playBtn];
        [self.contentView addSubview:bbsBrowserCount];
    }
    return self;
}

- (void)awakeFromNib
{
    
    
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
