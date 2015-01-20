//
//  RZImageDisplay.m
//  FMDBDemo
//
//  Created by Reese on 13-10-31.
//  Copyright (c) 2013年 Reese@objcoder.com. All rights reserved.
//

#import "RZImageDisplay.h"
#import "UIImageView+RZWebImage.h"

@implementation RZImageDisplay

- (id)initWithFrame:(CGRect)frame
{
    NSString    * tNibStr = @"RZImageDisplay";
//    if (iPhone5) {
//        tNibStr = @"RZImageDisplay@2x";
//    }
    self = [[NSBundle mainBundle]loadNibNamed:tNibStr owner:self options:nil][0];
    if (self) {
        // Initialization code
        id weakSelf=self;
        [backScroll setDelegate:weakSelf];

    }
    return self;
}

- (void)awakeFromNib{
    _frontImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(UesrClicked:)];
    
    [self addGestureRecognizer:tap];
    [downBtn setImage:[UIImage imageNamed:@"down_img_btn_pressed.png"] forState:UIControlStateSelected];
    [tap release];
}


- (void)UesrClicked:(id)sender
{
    [self closeView:sender];
}

- (IBAction)downImgFile:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.frontImage, nil, nil, nil);
    
    [self showHud:@"保存成功" mode:MBProgressHUDModeText];
    [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
}

- (void)showHud:(NSString *)msg mode:(MBProgressHUDMode)mode
{
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self];
        
    }
    _hud.labelText = msg;
    [_hud show:YES];
    if (mode != MBProgressHUDModeNone) {
        [_hud setMode:mode];
    }
    
    [self addSubview:_hud];
}

- (void)hideHud
{
    [_hud hide:YES];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%@",self.frontImage);
    CGRect currentFrame=self.frontImageView.frame;
    [self.frontImageView setFrame:self.originFrame];
    [self.frontImageView setImage:self.frontImage];
    [UIView animateWithDuration:0.5 animations:^{
        [self.frontImageView setFrame:currentFrame];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray * touchesAry = [[event allTouches] allObjects];
    if ([touchesAry count] == 1) {
        [self closeView:nil];
    }
}



- (IBAction)makeZoom:(UIStepper *)sender {
    NSLog(@"缩放:%f",sender.value);
    [backScroll setZoomScale:sender.value animated:YES];
}

- (IBAction)closeView:(id)sender {
    [backScroll setZoomScale:1.0 animated:YES];
    [self removeFromSuperview];
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.2 animations:^{
            [self.frontImageView setFrame:self.originFrame];
        } completion:^(BOOL finished) {
            
            [self.delegate willEndDisplay];
            [self removeFromSuperview];
            
        }];

    });
    
    
    
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.frontImageView;
}


- (void)setImgArys:(NSMutableArray *)ImgAry
{
    #define kALPHA  0.7
    UIScrollView * _hpScrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_hpScrollV setPagingEnabled:YES];
    [_hpScrollV setShowsHorizontalScrollIndicator:NO];
    [_hpScrollV setContentSize:CGSizeMake(_hpScrollV.frame.size.width * 2, _hpScrollV.frame.size.height)];
    [self addSubview:_hpScrollV];
    [_hpScrollV scrollRectToVisible:CGRectMake(_hpScrollV.frame.size.width, 0, self.frame.size.width, _hpScrollV.frame.size.height) animated:NO];
    [_hpScrollV setBackgroundColor:[UIColor clearColor]];
    [_hpScrollV setZoomScale:3 animated:YES];
    [backScroll setPagingEnabled:YES];
    [backScroll setShowsHorizontalScrollIndicator:NO];
    [backScroll setContentSize:CGSizeMake(backScroll.frame.size.width * 2, backScroll.frame.size.height)];
    [backScroll scrollRectToVisible:CGRectMake(backScroll.frame.size.width, 0, self.frame.size.width, backScroll.frame.size.height) animated:NO];
    [backScroll setBackgroundColor:[UIColor clearColor]];
    

    CGRect tRect = self.frame;
    for (int index = 0; index < [ImgAry count]; index++) {
        UIImageView * tImgView = nil;
        if (index == 0) {
            tImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 120, self.frame.size.width - 20, 300)];
        }else{
            tImgView = [[UIImageView alloc] initWithFrame:tRect];
        }
        
        [tImgView setWebImage:[NSURL URLWithString:[ImgAry objectAtIndex:index]] placeHolder:[UIImage imageNamed:@"defaultImg"] downloadFlag:1];
        [tImgView setTag:1];
        [backScroll addSubview:tImgView];
        tRect = CGRectMake(self.frame.size.width + 10, 120, self.frame.size.width - 20, 300);
    }
}

@end
