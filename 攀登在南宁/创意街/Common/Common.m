//
//  Common.m
//  BlackBear
//
//  Created by IOS on 14-5-23.
//  Copyright (c) 2014年 IOS. All rights reserved.
//


#import "Common.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"
@implementation Common
static Common * shareCommon = nil;

+(Common *)shareCommon
{
    @synchronized(self){
        if( nil == shareCommon){
            shareCommon = [[self alloc] init] ;
        }
    }
    return shareCommon;
}


+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if ( nil == shareCommon ) {
            shareCommon = [super allocWithZone:zone];
            return  shareCommon;
        }
    }
    return nil;
}

- (BOOL)isFirstLaunch
{
    //读取沙盒数据
    NSUserDefaults * tUserdefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tValue = [tUserdefaults objectForKey:FirstLaunch];
    if (nil == tValue) {
        [tUserdefaults setObject:@"" forKey:IsLogin];
        [tUserdefaults setObject:@"Flag" forKey:FirstLaunch];
        [tUserdefaults setObject:@"" forKey:IsFirstLogin];
        return YES;
    }
    return NO;
}


- (BOOL)isLogin
{
    NSUserDefaults  * tUserdefaults = [NSUserDefaults standardUserDefaults];
    NSString    * tValue = [tUserdefaults objectForKey:IsLogin];
    if ([tValue isEqualToString:@""] || tValue == nil) {
        return NO;
    }
    return YES;
}

- (BOOL)isLoginAndShowCtl:(UINavigationController *)navCtl
{
    if (![self isLogin]) {
        if (nil == _loginViewCtl) {
            _loginViewCtl = [[LoginViewCtl alloc] initWithNibName:@"LoginView" bundle:nil];
        }
        [navCtl pushViewController:_loginViewCtl animated:YES];
        return NO;
    }
    return YES;
}

- (void)exitLogin
{
    NSUserDefaults * tUserDefault = [NSUserDefaults standardUserDefaults];
    [tUserDefault setObject:@"" forKey:IsLogin];
}

- (void)postData:(NSString *)urlStr delegate:(id)delegate postDataDic:(NSMutableDictionary *)dataDic
{
    if ([NSJSONSerialization isValidJSONObject:dataDic])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic options:NSJSONWritingPrettyPrinted error: nil];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.timeOutSeconds = 40;
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"multipart/form-data; boundary=WebKitFormBoundary0POKQRnhmB8YTzKl"];
        [request setPostValue:jsonStr forKey:@"data"];
        [request setDelegate:delegate];
        [request setDidFinishSelector:@selector(GetResult:)];
        [request setDidFailSelector:@selector(GetErr:)];
        [request startAsynchronous];
    }
    
}


- (void)postImgWithUrl:(NSString *)urlStr delegate:(id)delegate imgData:(NSData *)imgData
{
    NSMutableData * data = [[NSMutableData alloc] initWithData:imgData];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = 40;
    [request setRequestMethod:@"POST"];
    [request setData:data withFileName:@"file.jpg" andContentType:@"image/jpg" forKey:@"pic"];
    [request setDelegate:delegate];
    [request setDidFinishSelector:@selector(GetResult:)];
    [request setDidFailSelector:@selector(GetErr:)];
    [request startAsynchronous];
}

- (void)postVideoWithUrl:(NSString *)urlStr delegate:(id)delegate imgData:(NSData *)imgData
{
    NSMutableData * data = [[NSMutableData alloc] initWithData:imgData];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.timeOutSeconds = 40;
    [request setRequestMethod:@"POST"];
    [request setData:data withFileName:@"file.mp4" andContentType:@"video/mp4" forKey:@"video"];
    [request setDelegate:delegate];
    [request setDidFinishSelector:@selector(GetResult:)];
    [request setDidFailSelector:@selector(GetErr:)];
    [request startAsynchronous];
}


- (void)requestWithUrlStr:(NSString *)urlStr delegate:(id)delegate{
    
    ASIFormDataRequest * _getCloudFileListRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [_getCloudFileListRequest setStringEncoding:NSUTF8StringEncoding];
    [_getCloudFileListRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    _getCloudFileListRequest.delegate = delegate;
    [_getCloudFileListRequest setDidFinishSelector:@selector(GetResult:)];
    [_getCloudFileListRequest setDidFailSelector:@selector(GetErr:)];
    //    [_getCloudFileListRequest setNumberOfTimesToRetryOnTimeout:3];
    
    [_getCloudFileListRequest startAsynchronous];
    
}


- (void)postDataSynchronous:(NSString *)urlStr delegate:(id)delegate postDataDic:(NSMutableDictionary *)dataDic
{
    if ([NSJSONSerialization isValidJSONObject:dataDic])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic options:NSJSONWritingPrettyPrinted error: nil];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.timeOutSeconds = 40;
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"multipart/form-data; boundary=WebKitFormBoundary0POKQRnhmB8YTzKl"];
        [request setPostValue:jsonStr forKey:@"data"];
        [request setDelegate:delegate];
        [request setDidFinishSelector:@selector(GetResult:)];
        [request setDidFailSelector:@selector(GetErr:)];
        [request startSynchronous];
    }
    
}

- (void)setBackItemImg:(UIViewController *)viewControl
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 3.0, 15.0, 21.0);
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    //        [backButton setImage:[UIImage imageNamed:@"Btn_Back_On.png"] forState:UIControlStateSelected];
    [backButton addTarget:viewControl action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    temporaryBarButtonItem.title = @"";
    viewControl.navigationItem.leftBarButtonItem=temporaryBarButtonItem;
    [temporaryBarButtonItem release];
}


- (NSString *)convTimeSeconds:(NSString *)timeSecend
{
    if ((NSNull *)timeSecend == [NSNull null]) {
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeSecend doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    [formatter release];
    return confromTimespStr;
}


- (NSString *)getFilePathWithUrl:(NSURL *)url
{
    NSString *path=[NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%u",url.description.hash];
    return path;
}

- (int)getCommentHeigh:(NSString *)commentStr
{
    int     tHeigh = CellCommentHeigh;
    if ([commentStr length] > 32) {
        tHeigh = (([commentStr length] - 32)/16 +1)*20;
        tHeigh = tHeigh + CellCommentHeigh + 10;
    }
    return tHeigh;
}

// 是否wifi
+ (BOOL) IsEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (void)delDirectoryFile:(NSString *)directory ext:(NSString *)ext
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:directory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([ext isEqualToString:@""]) {
            [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:filename]
                                    error:NULL];
        }else{
            if ([[filename pathExtension] isEqualToString:ext]) {
                [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:filename]
                                        error:NULL];
            }
            
        }
    }
}

- (BOOL)checkTel:(NSString *)str

{
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:str] == YES)
        || ([regextestcm evaluateWithObject:str] == YES)
        || ([regextestct evaluateWithObject:str] == YES)
        || ([regextestcu evaluateWithObject:str] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    if ([str length] == 0) {
        
        return NO;
        
    }
    
    
    //    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    //
    //    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    //
    //    BOOL isMatch = [pred evaluateWithObject:str];
    //
    //    return isMatch;
    
}

- (BOOL)isAdmin
{
    if ([self isLogin]) {
        int tAdmin = [[UserDefalut objectForKey:UserPermission] intValue];
        if (tAdmin == 1) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}
@end
