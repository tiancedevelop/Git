//
//  MyLabel.h
//  创意街
//
//  Created by yu tang on 14-12-7.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyLabel;
@protocol MyLabelDelegate <NSObject>
@required
- (void)myLabel:(MyLabel *)myLabel touchesWtihTag:(NSInteger)tag;
@end

@interface MyLabel : UILabel {
    id <MyLabelDelegate> delegate;
}
@property (nonatomic, assign) id <MyLabelDelegate> delegate;
- (id)initWithFrame:(CGRect)frame;
@end
