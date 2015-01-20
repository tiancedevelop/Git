//
//  RZImageDisplay.h
//  FMDBDemo
//
//  Created by Reese on 13-10-31.
//  Copyright (c) 2013年 Reese@objcoder.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol RZImageDisplayDelegate <NSObject>
@required
-(void)willEndDisplay;

@end

@interface RZImageDisplay : UIView
{
    IBOutlet UIScrollView *backScroll;
    IBOutlet UIButton        * downBtn;
    
}
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic,assign) id<RZImageDisplayDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *frontImageView;
//变化前的frame
@property (assign,nonatomic) CGRect originFrame;
@property (strong, nonatomic) UIImage *frontImage;
- (IBAction)makeZoom:(UIStepper *)sender;
- (IBAction)closeView:(id)sender;
- (IBAction)downImgFile:(id)sender;
- (void)setImgArys:(NSMutableArray *)ImgAry;
@end
