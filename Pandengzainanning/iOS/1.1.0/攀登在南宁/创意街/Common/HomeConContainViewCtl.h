//
//  HomeConServiceViewCtl.h
//  GrandmaBear
//
//  Created by ios on 14-8-25.
//  Copyright (c) 2014年 com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeConContainViewCtl : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView      * _webView;
}

@property (readwrite,assign)NSString    * loadUrl;
- (void)back:(id)sender;
@end
