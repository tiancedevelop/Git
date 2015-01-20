//
//  MyTagViewCtl.m
//  创意街
//
//  Created by yu tang on 15-1-18.
//  Copyright (c) 2015年 com.cn.chuangyijie. All rights reserved.
//

#import "MyTagViewCtl.h"
#import "MyLabelCollectCell.h"
#import "MBProgressHUD.h"

enum{
    RequestNone,
    RequestUserLabelType,
    RequestSaveUserLabelType,
    RequestAllLabelType
};

typedef int RequestType;

@interface MyTagViewCtl (){
    RequestType      _requestType;
    NSArray         * _allLabelAry;
    NSMutableArray  * _myLabelAry;
}

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation MyTagViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[Common shareCommon] setBackItemImg:self];
        _requestType = RequestNone;
        _myLabelAry = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的标签";
    [self showHud:@"加载中..." mode:MBProgressHUDModeText];
    [self getAllLabel];
    [_collectionView registerClass:[MyLabelCollectCell class] forCellWithReuseIdentifier:@"cell"];
    UIButton * tRightBtn= [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
    [tRightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [tRightBtn addTarget:self action:@selector(submitLabelStr:) forControlEvents:UIControlEventTouchUpInside];
    [tRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIBarButtonItem *_RightBtn = [[UIBarButtonItem alloc] initWithCustomView:tRightBtn];
    self.navigationItem.rightBarButtonItem  = _RightBtn;
}

- (void)showHud:(NSString *)msg mode:(MBProgressHUDMode)mode
{
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        
    }
    _hud.labelText = msg;
    [_hud show:YES];
    if (mode != MBProgressHUDModeNone) {
        [_hud setMode:mode];
    }
    
    [self.view addSubview:_hud];
}

- (void)hideHud
{
    [_hud hide:YES];
}

- (void)hideHudAndCtl
{
    [_hud hide:YES];
    [self back:nil];
}

- (IBAction)submitLabelStr:(id)sender
{
    [self saveMyLabel];
}

- (IBAction)stateBtnAction:(id)sender
{
    NSInteger tIndex = [sender tag]%2;
    NSInteger tSectionIndex = [sender tag]/2;
    NSIndexPath  * indexPath = [NSIndexPath indexPathForItem:tIndex inSection:tSectionIndex];;
    MyLabelCollectCell  * tCollectCell = (MyLabelCollectCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    
    NSDictionary    * tSelectDic = [_allLabelAry objectAtIndex:[sender tag]];
    int tSelectLid = [[tSelectDic objectForKey:@"lid"] intValue];
    
    BOOL selected = NO;
    for (int index = 0; index<[_myLabelAry count]; index++) {
        NSDictionary    * tDic = [_myLabelAry objectAtIndex:index];
        int tLabelTag = [[tDic objectForKey:@"lid"] intValue];
        if (tLabelTag == tSelectLid) {
            selected = YES;
            [_myLabelAry removeObjectAtIndex:index];
            break;
        }
    }
    
    if (!selected) {
        [_myLabelAry addObject:tSelectDic];
        [tCollectCell.stateBtn setImage:[UIImage imageNamed:@"gou.png"] forState:UIControlStateNormal];
    }else{
        [tCollectCell.stateBtn setImage:[UIImage imageNamed:@"jia.png"] forState:UIControlStateNormal];
    }
    NSLog(@"%ld",(long)[sender tag]);
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveMyLabel
{
    _requestType = RequestSaveUserLabelType;
    NSString * tUrlStr = [NSString stringWithFormat:@"%@/Label/set_my_label",UrlStr];
    NSString * tLabelId = @"";
    for (int index = 0; index < [_myLabelAry count]; index++) {
        NSDictionary    * tDic = [_myLabelAry objectAtIndex:index];
        if (index == 0) {
            tLabelId = [tDic objectForKey:@"lid"];
        }else{
            tLabelId = [NSString stringWithFormat:@"%@,%@",tLabelId,[tDic objectForKey:@"lid"]];
        }
        
    }
    NSMutableDictionary     * tMutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UserDefalut objectForKey:UserUid],@"uid",tLabelId,@"lid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)getUsrLabel
{
    _requestType = RequestUserLabelType;
    NSString * tUrlStr = [NSString stringWithFormat:@"%@/Label/get_label",UrlStr];
    NSMutableDictionary     * tMutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UserDefalut objectForKey:UserUid],@"uid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

- (void)getAllLabel
{
    _requestType = RequestAllLabelType;
    NSString * tUrlStr = [NSString stringWithFormat:@"%@/Label/get_label",UrlStr];
    NSMutableDictionary     * tMutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"uid", nil];
    [[Common shareCommon] postData:tUrlStr delegate:self postDataDic:tMutableDic];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark 服务器返回数据
- (void)GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSMutableArray    * tAry = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (_requestType == RequestAllLabelType) {
        NSLog(@"all label : %@ ",tAry);
        if (tAry) {
            SafeRelease(_allLabelAry);
            _allLabelAry = [tAry retain];
        }
        [self getUsrLabel];
        
    }else if (_requestType == RequestUserLabelType){
        NSLog(@"user label : %@",tAry);
        if (tAry) {
            SafeRelease(_myLabelAry);
            _myLabelAry = [[NSMutableArray arrayWithArray:tAry] retain];
        }
        [_collectionView reloadData];
        [self hideHud];
    }else if(_requestType == RequestSaveUserLabelType){
        NSDictionary * tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [self hideHud];
        [self showHud:[tDic objectForKey:@"msg"] mode:MBProgressHUDModeText];
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
        if ([[tDic objectForKey:@"status"] intValue] == 1) {
            [UserDefalut setObject:_myLabelAry forKey:UserLabel];
        }
    }
    
}

- (void)GetErr:(ASIHTTPRequest *)request
{
    NSLog(@"网络连接错误");
}

#pragma mark -
#pragma mark uicollectionView
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_allLabelAry count]/2;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"cell";
    MyLabelCollectCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MyLabelCollectCell alloc] init];
    }
    
    NSInteger tIndex = [indexPath indexAtPosition:1];
    NSInteger tSectionIndex = [indexPath indexAtPosition:0];
    NSDictionary * tNormalDic = [_allLabelAry objectAtIndex:tIndex+tSectionIndex*2];
    [cell.labelBtn setTitle:[tNormalDic objectForKey:@"labelname"] forState:UIControlStateNormal];
    
    BOOL    selectIndex = NO;
    for (int index = 0; index < [_myLabelAry count]; index++) {
        NSDictionary    * tMyDic = [_myLabelAry objectAtIndex:index];
        int myLabelLid = [[tMyDic objectForKey:@"lid"] intValue];
        if ([[tNormalDic objectForKey:@"lid"] intValue] == myLabelLid) {
            [cell.stateBtn setImage:[UIImage imageNamed:@"gou.png"] forState:UIControlStateNormal];
            selectIndex = YES;
            break;
        }
    }
    if (!selectIndex) {
        [cell.stateBtn setImage:[UIImage imageNamed:@"jia.png"] forState:UIControlStateNormal];
    }
    
    
    [cell.stateBtn setTag:tSectionIndex*2 + tIndex];
    [cell.labelBtn setTag:tSectionIndex*2 + tIndex];
    [cell.stateBtn addTarget:self action:@selector(stateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.labelBtn addTarget:self action:@selector(stateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
@end
