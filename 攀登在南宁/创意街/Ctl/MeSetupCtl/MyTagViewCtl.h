//
//  MyTagViewCtl.h
//  创意街
//
//  Created by yu tang on 15-1-18.
//  Copyright (c) 2015年 com.cn.chuangyijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface MyTagViewCtl : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    IBOutlet UICollectionView    * _collectionView;
}

- (void)back:(id)sender ;
- (void)GetResult:(ASIHTTPRequest *)request;
- (void)GetErr:(ASIHTTPRequest *)request;

@end
