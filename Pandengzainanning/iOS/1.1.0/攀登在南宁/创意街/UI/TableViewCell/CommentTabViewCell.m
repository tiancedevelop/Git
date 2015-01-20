//
//  CommentTabViewCell.m
//  创意街
//
//  Created by ios on 14-11-26.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "CommentTabViewCell.h"

@implementation CommentTabViewCell
@synthesize headIconImgView,bbsContentLabel,userNameLabel,prasieNumBtn,prasieBtn;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headIconImgView     = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 30, 30)];
        headIconImgView.layer.masksToBounds = YES;
        headIconImgView.layer.cornerRadius = 15;
        userNameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 100, 15)];
        bbsContentLabel      = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 230, 48)];
        userNameLabel.font   = [UIFont systemFontOfSize:12.0];
        bbsContentLabel.font    = [UIFont systemFontOfSize:15.0];
        bbsContentLabel.numberOfLines = 0;
        
        prasieNumBtn = [[UIButton alloc] initWithFrame:CGRectMake(IphoneWidth - 45, 25, 35, 25)];
        prasieBtn       = [[UIButton alloc] initWithFrame:CGRectMake(IphoneWidth - 40, 0, 25, 25)];
        
        [prasieBtn      setImage:[UIImage imageNamed:@"ding_not_clicked"] forState:UIControlStateNormal];

        [prasieNumBtn setTitle:@"+1" forState:UIControlStateNormal];
        [prasieNumBtn setFont:[UIFont systemFontOfSize:12]];
        [prasieNumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:headIconImgView];
        [self.contentView addSubview:userNameLabel];
        [self.contentView addSubview:bbsContentLabel];
        
        [self.contentView addSubview:prasieBtn];
        [self.contentView addSubview:prasieNumBtn];
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
