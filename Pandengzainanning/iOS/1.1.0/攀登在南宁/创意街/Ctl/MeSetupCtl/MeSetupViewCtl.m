//
//  MeSetupViewCtl.m
//  创意街
//
//  Created by ios on 14-11-12.
//  Copyright (c) 2014年 com.cn.chuangyijie. All rights reserved.
//

#import "MeSetupViewCtl.h"
#import "AboutCtl.h"

@interface MeSetupViewCtl ()
{
    AboutCtl                * _aboutCtl;
}

@end

@implementation MeSetupViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[Common shareCommon] setBackItemImg:self];
    }
    return self;
}

- (void)back:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:CanScrollNotification
                                                        object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tIndexSection = [indexPath indexAtPosition:0];
    int tIndex          = [indexPath indexAtPosition:1];
    if (tIndexSection == 0 && tIndex == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
        
        [alert show];
        
        [alert release];
    }else if (tIndexSection == 1 && tIndex == 0){
        NSUserDefaults * tUserDefault = [NSUserDefaults standardUserDefaults];
        [tUserDefault setObject:@"" forKey:IsLogin];
        [tUserDefault setObject:@"" forKey:UserUid];
        [tUserDefault setObject:@"" forKey:UserName];
        [tUserDefault setObject:@"" forKey:UserTelNum];
        [tUserDefault setObject:@"" forKey:UserAddress];
        [self back:nil];
        
    }else if (tIndexSection == 0 && tIndex == 1)
    {
        if (nil == _aboutCtl) {
            _aboutCtl = [[AboutCtl alloc] initWithNibName:@"AboutView" bundle:nil];
        }
        [self.navigationController pushViewController:_aboutCtl animated:YES];
    }
    return indexPath;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![[Common shareCommon] isLogin]) {
        return 1;
    }
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    return 15.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCell";
    
    NSUInteger tIndexSection = [indexPath indexAtPosition:0];
    NSUInteger tIndex        = [indexPath indexAtPosition:1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SafeRelease(cell);
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (tIndexSection == 3) {

        cell.textLabel.text = @"Wify下自动播放";
        UISwitch    * tSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-60, 5, 80, 30)];
        [cell addSubview:tSwitch];
    }else if (tIndexSection == 0){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (tIndex == 0){
            cell.textLabel.text =@"清除缓存";
            NSString *path=[NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/"];
            NSString * videoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/"];
            float t = [[Common shareCommon] folderSizeAtPath:path]/1024/1024;
            float tSize = t + [[Common shareCommon] folderSizeAtPath:videoPath];
            NSString * tFolderSize = [NSString stringWithFormat:@"%f",tSize];
            tFolderSize = [tFolderSize substringWithRange:NSMakeRange(0, tFolderSize.length - 5)];
            tFolderSize = [NSString stringWithFormat:@"%@M",tFolderSize];
            cell.detailTextLabel.text=tFolderSize;
        }else if (tIndex == 1){
            cell.textLabel.text = @"关于";
        }
    }
    
    if (tIndexSection == 1) {
//        cell.textLabel.text = @"退出登录";
        UILabel     * tLable = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/2-50, 0, 100, cell.frame.size.height)];
        tLable.textAlignment = NSTextAlignmentCenter;
        tLable.font = [UIFont systemFontOfSize:17];
        tLable.text = @"退出登录";
        [cell addSubview:tLable];
    }
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *path=[NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/"];
        NSString * videoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/"];
        NSString * videoCamerPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/videos"];
        [[Common shareCommon] delDirectoryFile:path ext:@""] ;
        [[Common shareCommon] delDirectoryFile:videoPath ext:@"mp4"];
        [[Common shareCommon] delDirectoryFile:videoCamerPath ext:@""];
        [_tableView reloadData];
    }
}

@end
