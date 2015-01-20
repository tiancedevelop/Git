//
//  Common.h
//  BlackBear
//
//  Created by IOS on 14-5-23.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LoginViewCtl.h"

#define UrlStr              @"http://ocyj.nntzd.com/index.php/API"
#define ShareIconUrl        @"http://hellonn.nntzd.com/icon.png"
#define ShareUrl            @"http://hellonn.nntzd.com/"
#define ProtoctolUrl        @"http://hellonn.nntzd.com/APP/agreement.html"
#define AppName             @"攀登在南宁"
#define ShareTxtAndImgMsg   @"攀登在南宁"
#define CellHeigh  48
#define CellCommentHeigh 53

#define ShareToWxResultNotification @"ShareToWxResultNotification"
#define ShareToQQResultNotification @"ShareToQQResultNotification"
#define CanScrollNotification       @"CanScrollNotification"
#define CannotScrollNotification    @"CannotScrollNotification"

#define IphoneWidth [UIScreen mainScreen].bounds.size.width
#define UserDefalut         [NSUserDefaults standardUserDefaults]
#define FirstLaunch         @"FirstLaunch"
#define IsLogin             @"isLogin"
#define IsFirstLogin        @"isFirstLogin"
#define UserIconPath        @"UserIconPath"
#define UserName            @"userName"
#define UserUid             @"userUid"
#define UserAddress         @"UserAddress"
#define UserTelNum          @"UserTelNum"
#define UserLabel           @"UserLabel"
#define UserPermission      @"UserPermission"

#define CurrentIssueVideoPath   @"currentIssueVideoPath"
#define CurrentIssueVideoUrl    @"currentIssueVideoUrl"
#define ZanThemAry              @"zanThemDic"
#define ZanCommentAry           @"zanCommentAry"
#define CaiThemAry              @"caiThemDic"

#define GetUserUid              [[UserDefalut objectForKey:UserUid] isEqualToString:@""]?@"-1":[UserDefalut objectForKey:UserUid]
#define judgeNull(obj) (NSNull *)obj==[NSNull null]?@"":obj

#define ReportAry   [[NSArray alloc] initWithObjects:@"广告欺诈",@"淫秽色情",@"骚扰谩骂",@"反动政治",@"其他", nil]

enum{
    RequestNoneType,
    RequestThemType,
    RequestMoreThemType,
    RequestThemCommentType,
    RequestMoreThemCommentType,
    RequestSubmitZanOrCaiType,
    RequestSubmitZanCommentType,
    RequestSubmitShareType,
    RequestSubmitReportType,
    RequestSubmitBrowserType,
    RequestSubmitDelType,
    RequestSubmitCommentType
    
};

typedef int RequestType;

enum{
    ShowActivityNoneType,
    ShowActivityIssueType,
    ShowActivityShareType
};
typedef int ShowActivityType;

@interface Common : NSObject
{
    LoginViewCtl    * _loginViewCtl;
}
+(Common *)shareCommon;


/*
 * Method
 * abstract : 判断是否是第一次启动
 * param : void
 * result   : bool 值,Yes 第一次启动,No 不是第一次启动
 */
- (BOOL)isFirstLaunch;

/*
 * Method
 * abstract : 判断是否登录
 * param : void
 * result   : bool值,Yes  已经登录，No  未登录
 */
- (BOOL)isLogin;

/*
 * Method
 * abstract : 判断是否登录 ,未登录则跳转到登录界面
 * param : void
 * result   : bool值,Yes  已经登录，No  未登录
 */
- (BOOL)isLoginAndShowCtl:(UINavigationController *)navCtl;

/*
 * Method
 * abstract : 向服务器上传数据(异步)
 * param : urlStr: 上传数据的地址
 * param : delegate:接收上传数据后返回返回的内容
 * param : dataDic:需要上传的数据
 * result   : void
 */
- (void)postData:(NSString *)urlStr delegate:(id)delegate postDataDic:(NSMutableDictionary *)dataDic;

/*
 * Method
 * abstract : 向服务器上传数据(同步)
 * param : urlStr: 上传数据的地址
 * param : delegate:接收上传数据后返回返回的内容
 * param : dataDic:需要上传的数据
 * result   : void
 */
- (void)postDataSynchronous:(NSString *)urlStr delegate:(id)delegate postDataDic:(NSMutableDictionary *)dataDic;

/*
 * Method
 * abstract : 像服务器上传图片
 * param : urlStr: 上传数据的地址
 * param : delegate:接收上传数据后返回返回的内容
 * param : imgData:需要上传的图片
 * result   : void
 */
- (void)postImgWithUrl:(NSString *)urlStr delegate:(id)delegate imgData:(NSData *)imgData;


/*
 * Method
 * abstract : 向服务器上传视频
 * param : urlStr: 上传数据的地址
 * param : delegate:接收上传数据后返回返回的内容
 * param : imgData:需要上传的视频
 * result   : void
 */
- (void)postVideoWithUrl:(NSString *)urlStr delegate:(id)delegate imgData:(NSData *)imgData;

/*
 * Method
 * abstract : get方式请求数据
 * param : urlStr:请求数据的地址
 * result   : void
 */
- (void)requestWithUrlStr:(NSString *)urlStr delegate:(id)delegate;


/*
 * Method
 * abstract : 设置界面nagavbaritem的返回按钮
 * param : viewControl:要设置的界面ctl
 * result   : void
 */
- (void)setBackItemImg:(UIViewController *)viewControl;

/*
 * Method
 * abstract : 时间戳转换时间
 * param : timeSecend:时间戳
 * result   : nsstring:返回 yy-MM-dd HH:mm:ss的时间格式
 */
- (NSString *)convTimeSeconds:(NSString *)timeSecend;

/*
 * Method
 * abstract : 根据url获取文件的本地路径
 * param : url:文件的地址
 * result   : nsstring 返回文件的本地地址
 */
- (NSString *)getFilePathWithUrl:(NSURL *)url;


/*
 * Method
 * abstract : 根据字符串来计算控件高度
 * param : commentStr : 要计算的字符串
 * result   : int 返回字符串的高度
 */
- (int)getCommentHeigh:(NSString *)commentStr;


/*
 * Method
 * abstract : 根据文件获取文件的大小
 * param : filePath : 要计算的文件路径
 * result   : int 返回文件的大小(单位 byte)
 */
- (long long) fileSizeAtPath:(NSString*) filePath;

/*
 * Method
 * abstract : 根据文件夹获取文件夹的大小
 * param : filePath : 要计算的文件夹路径
 * result   : int 返回文件夹的大小(单位 M)
 */
- (float ) folderSizeAtPath:(NSString*) folderPath;

/*
 * Method
 * abstract : 删除文件夹下的所有文件
 * param : filePath : 要删除的文件夹路径,ext文件后缀，@""为所有文件
 * result   : void
 */
- (void)delDirectoryFile:(NSString *)directory ext:(NSString *)ext;

/*
 * Method
 * abstract : 检测当前是否连接wify
 * param : nil
 * result   : bool :yes 连接wify状态
 */
+ (BOOL) IsEnableWIFI;


/*
 * Method
 * abstract : 判断是否为手机号码
 * param : str:手机号码
 * result   : bool   yes:是手机号  no:不是手机号
 */
- (BOOL)checkTel:(NSString *)str;

/*
 * Method
 * abstract : 判断是否为超级用户
 * param : nil
 * result   : bool   yes:是  no:不是
 */
- (BOOL)isAdmin;
@end