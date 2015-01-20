//
//  MainTxtTableViewCell.m
//  创意街
//
//  Created by ios on 14-11-12.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "MainTxtTableViewCell.h"

@implementation MainTxtTableViewCell
@synthesize praiseBtn,prasieNumBtn,replayImgBtn,replyNumBtn,shareBtn,shareNumBtn,headIconImgView,userNameLabel,bbsAddTimeLabel,bbsContentLabel,caiBtn,caiNumBtn;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headIconImgView     = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
        headIconImgView.layer.masksToBounds = YES;
        headIconImgView.layer.cornerRadius = 12.5;
        userNameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(45, 8, 100, 15)];
        bbsAddTimeLabel     = [[UILabel alloc] initWithFrame:CGRectMake(45, 25, 150, 10)];
        bbsContentLabel      = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 280, 70)];
        bbsAddTimeLabel.font = [UIFont systemFontOfSize:2.0];
        userNameLabel.font   = [UIFont systemFontOfSize:12.0];
        bbsContentLabel.numberOfLines = 0;
        
        int tImgWidthOrHegih = 25;
        int tBtnY           = 100;
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
        [self.contentView addSubview:bbsContentLabel];
        [self.contentView addSubview:caiBtn];
        [self.contentView addSubview:caiNumBtn];
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
