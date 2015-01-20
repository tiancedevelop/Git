//
//  CommentTabViewCell.h
//  创意街
//
//  Created by ios on 14-11-26.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTabViewCell : UITableViewCell
@property(readwrite,nonatomic,assign)UIImageView      * headIconImgView;
@property(readwrite,nonatomic,assign)UILabel          * userNameLabel;
@property(readwrite,nonatomic,assign)UILabel          * bbsContentLabel;
@property(readwrite,nonatomic,assign)UIButton         * prasieNumBtn;
@property(readwrite,nonatomic,assign)UIButton         * prasieBtn;
@end
