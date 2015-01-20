//
//  MainTxtTableViewCell.h
//  创意街
//
//  Created by ios on 14-11-12.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTxtTableViewCell : UITableViewCell
@property(readwrite,nonatomic,assign)UIImageView      * headIconImgView;
@property(readwrite,nonatomic,assign)UIButton         * praiseBtn;
@property(readwrite,nonatomic,assign)UILabel          * userNameLabel;
@property(readwrite,nonatomic,assign)UILabel          * bbsAddTimeLabel;
@property(readwrite,nonatomic,assign)UILabel            * bbsContentLabel;
@property(readwrite,nonatomic,assign)UIButton                   * prasieNumBtn;
@property(readwrite,nonatomic,assign)UIButton                   * replyNumBtn;
@property(readwrite,nonatomic,assign)UIButton                   * replayImgBtn;
@property(readwrite,nonatomic,assign)UIButton                   * shareNumBtn;
@property(readwrite,nonatomic,assign)UIButton                   * shareBtn;
@property(readwrite,nonatomic,assign)UIButton                   * caiBtn;
@property(readwrite,nonatomic,assign)UIButton                   * caiNumBtn;
@end
