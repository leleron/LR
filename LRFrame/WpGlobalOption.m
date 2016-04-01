//
//  WpSdkLibGlobalOption.m
//  WeiboPaySdkLib
//
//  Created by Mark on 13-5-29.
//  Copyright (c) 2013年 WeiboPay. All rights reserved.
//

//#import "WpCommonFunction.h"
#import "WpGlobalOption.h"
#import "LRBaseRequset.h"
//#import "WpSaveDeviceInfoAdapter.h"
#import "LRNetResponse.h"
//#import "ASIHTTPRequest.h"
#import "Reachability.h"
//#import "WHGlobalHelper.h"
#import "WHStringHelper.h"
//#import "ViewControllerManager.h"

//#import "WpAlertViewCommon.h"


@interface WpGlobalOption ()
{
    NSOperationQueue* _imageOperationQueue;
    NSOperationQueue* _sdkOperationQueue;
    
    QUServiceState _preServiceCallStatus;
    
    // 设备Hash值
    NSString* _deviceHashValue;
    Reachability* _hostReach;
//    WpSaveDeviceInfoAdapter* _saveDeviceInfoAdapter;
//    
//    // 允许忽视不弹出alert的错误类型
//    NSDictionary* allowMissErrorOperationName;
//    NSDictionary* allowMissErrorRetCode;
}

- (void)createGlobalObject;

// 设备网络环境变化回调
- (void)reachabilityChanged:(NSNotification*)note;
- (void)saveDeviceInfoAdapterCallback:(LRNetResponse*)response;

@end


@implementation WpGlobalOption

// 获得全局的GlobalOption
+ (WpGlobalOption*)sharedOption
{
    //
    static dispatch_once_t wpSdkLibGlobalOptionOnceToken;
    static WpGlobalOption* globalWpSdkLibGlobalOption = nil;
    
    dispatch_once(&wpSdkLibGlobalOptionOnceToken, ^{
        globalWpSdkLibGlobalOption = [[WpGlobalOption alloc] init];
        [globalWpSdkLibGlobalOption createGlobalObject];
    });
    
    return globalWpSdkLibGlobalOption;
}

- (void)createGlobalObject
{
    _imageOperationQueue = [[NSOperationQueue alloc] init];
    [_imageOperationQueue setMaxConcurrentOperationCount:16];
    
    _sdkOperationQueue = [[NSOperationQueue alloc] init];
    [_sdkOperationQueue setMaxConcurrentOperationCount:8];
    
    _deviceHashValue = @"";
    
    // 设置网络状态变化时的通知函数
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    
//    allowMissErrorOperationName=@{
//                                  @"HHQ":@"1",
//                                  @"HHQCHART":@"1",
//                                  @"HSTATE":@"1",
//                                  @"HTradeState":@"1",
//                                  @"PHJMSG":@"1",
//                                  @"HRULETYPE":@"1",
//                                  @"WORKDAY":@"1"
//                                  };
//
//    allowMissErrorRetCode=@{@"0": @"1",
//                            @"99999":@"1"};
}

// 调用SDK服务端请求
- (void)executeUrlOperation:(NSOperation*)operation
{
    [_sdkOperationQueue addOperation:operation];
}

// 调用服务端其他次要请求（后台加载请求或图片请求）
- (void)executeImageOperation:(NSOperation*)operation
{
    [_imageOperationQueue addOperation:operation];
}

// 得到设备的HashValue
- (NSString*)getDeviceHashValue
{
    return _deviceHashValue;
}

// 设备网络环境变化回调
- (void)reachabilityChanged:(NSNotification*)note
{
//    [_saveDeviceInfoAdapter removeTarget];
    /*
//    _saveDeviceInfoAdapter = [[WpSaveDeviceInfoAdapter alloc] initWithTarget:self selector:@selector(saveDeviceInfoAdapterCallback:)];
//    [self executeImageOperation:_saveDeviceInfoAdapter];
     */
}

- (void)saveDeviceInfoAdapterCallback:(LRNetResponse*)response
{
    if (QU_SERVICE_BACK_OK == [self serviceCallBackFromApp:response andShowMessage:NO])
    {
//        _deviceHashValue = response.pData;
    }
    
//    _saveDeviceInfoAdapter = nil;
}


// 服务端请求返回状态判断
//
// 方式三：提示，回首页，登录页
// 方式四：提示，回首页，回商户app
- (NSInteger)serviceCallBack:(LRNetResponse*)response andShowMessage:(BOOL)bShow andFollow:(NSInteger)followCode andViewController:(UIViewController*)vControl andTest:(BOOL)bTest
{
    if ([[response.request operationType] isEqualToString:@"getServerTime"])
    {
        // 缓存服务器的时间
//        [WCFGestureTimer sharedTimer].serviceTime = [response.pRetServerTime doubleValue];
    }
    
    // 检验是否需要弹出手势密码验证页面，若弹出，中断执行，return QU_SERVICE_BACK_GESTURESINTERRUPT
    // 当从后端进入活动状态时，根据服务器时间判断是否弹出手势密码，其他情况通过本地计数器做判断
//    // 仍然需要时刻更新服务器时间至本地
//    if ([WpCommonFunction operationWithLeaveUnused:response.pRetServerTime :[response.pAdapter operationType]])
//    {
//        return QU_SERVICE_BACK_GESTURESINTERRUPT;
//    }
//    else if ([[response.pAdapter operationType] isEqualToString:@"getServerTime"])
//    {
//        // 当用户触发home键/电源键/屏幕从底层上滑等操作室，请求getServerTime操作。若此时不用弹出手势密码，则如下赋值 YES
//        if (![WCFGestureTimer sharedTimer].isInvalidateTimerMark)
//        {
//            // 置为YES，要保存当前的服务器时间
//            [WCFGestureTimer sharedTimer].isInvalidateTimerMark = YES;
//        }
//    }
//    
//    // 服务端请求返回状态判断
//    // 会话已过期
//    if ([response.pRetCode isEqualToString:@"1012"] || bTest)
//    {
//        if ([[response.pAdapter operationType] isEqualToString:@"checkAccountTimeOut"])
//        {
//            
//        }
//        else
//        {
//            if (_preServiceCallStatus != QU_SERVICE_BACK_SESSIONEXPIRED) // 防止超时处理重入
//            {
//                // session过期，当前处于分享页，需要移除该页面
//                // [self performSelector:@selector(handleSessionExpired) withObject:nil afterDelay:0.2];
//                
//                [self handleSessionExpired];
//            }
//        }
//        
//        _preServiceCallStatus = QU_SERVICE_BACK_SESSIONEXPIRED;
//        
//        return _preServiceCallStatus;
//    }
//    
    /** 短信验证码超时 */  // 短信验证码错误
//    if([response.pRetCode isEqualToString:@"1103"])
//    {
//        [WpCommonFunction showNotifyHUDAtViewBottom:[[ViewControllerManager sharedManager] currentController1].view withErrorMessage:response.pRetString];
//        
//        _preServiceCallStatus = QU_SERVICE_BACK_MESSAGECODE;
//        return _preServiceCallStatus;
//    }
    
    // 是否属于可忽略的错误，特指后台主动请求的异步查询任务
//    if([self isAllowMissError:response])
//    {
//        _preServiceCallStatus = QU_SERVICE_BACK_FAIL;
//        return _preServiceCallStatus;
//    }
    
    if ([response.retCode isEqualToString:@"10010"]) // 协议未确认
    {
//        _preServiceCallStatus = QU_SERVICE_BACK_FAIL;
    }

    /** 余额不足 */
//    if([response.pRetCode isEqualToString:@"20052"])
//    {
//        [WpCommonFunction messageBoxTwoButtonWithMessage:NSLocalizedString(@"CPBOrderOptionController_alert_buy_msg", nil) andTitle:nil andLeftButton:NSLocalizedString(@"common_alert_btn_cancel", nil) andRightButton:NSLocalizedString(@"CPBOrderOptionController_alert_buy_ok", nil) andTag:ALERT_MONEY_NOT_ENOUGH_20052 andDelegate:self];
//        _preServiceCallStatus = QU_SERVICE_BACK_FAIL;
//        return _preServiceCallStatus;
        
//        _preServiceCallStatus = QU_SERVICE_BACK_OK;
//        return _preServiceCallStatus;
//    }

    
    
    if ([response.retCode isEqualToString:@"100"])
    {
        _preServiceCallStatus = QU_SERVICE_BACK_OK;
        return _preServiceCallStatus;
    }
    else
    {
        if (bShow)
        {
            
            // 防止弹出多个alert
//            [WpCommonFunction showNotifyHUDAtViewBottom:[[ViewControllerManager sharedManager] currentController1].view withErrorMessage:response.pRetString];
        }
        
        _preServiceCallStatus = QU_SERVICE_BACK_FAIL;
        return _preServiceCallStatus;
    }
}

/**
 是否属于可忽略的错误，特指后台主动请求的异步查询任务
*/
// -(BOOL)isAllowMissError:(QUNetResponse*)response{
//    NSString* operation=response.pAdapter.operationType;
//    NSString* retCode=response.pRetString;
//    
//    // 如果在允许忽略的方法范围内
//    if([allowMissErrorOperationName objectForKey:operation])
//    {
//        // 如果在允许忽略的错误代码范围内
//        if([allowMissErrorRetCode objectForKey:retCode])
//            return YES;
//    }
//    
//    return NO;
        
//}

- (NSInteger)serviceCallBackFromApp:(LRNetResponse*)response andShowMessage:(BOOL)bShow
{
    return [self serviceCallBack:response andShowMessage:bShow andFollow:-1 andViewController:nil andTest:NO];
}


// 处理Session超时
- (void)handleSessionExpired
{
    // 防止超时处理重入
    if (_preServiceCallStatus != QU_SERVICE_BACK_SESSIONEXPIRED)
    {
        _preServiceCallStatus = QU_SERVICE_BACK_SESSIONEXPIRED;
    }
    
    // 因为session过期，提示长时间未登录
    // 处理方式为：跳转至登录页或者返回至登录页
    
    // 现在的处理方式无长时间未登录的情况
    
    // 长时间未登录，跳转登录页面
    // 忘记手势密码时，则忽略该操作
    
    // 验证手势密码的过程，安全退出登录时忽略长时间未登录的操作
}

- (void)wpAlertViewDelegateYesButtonClick:(id)sender andPayload:(id)payload{
//    UIAlertView* alertView=(UIAlertView*)sender;
//    if(alertView.tag==ALERT_MONEY_NOT_ENOUGH_20052)
//    {
//        id controler=[[ViewControllerManager sharedManager] currentController1];
//        
//        if([controler isMemberOfClass:[UINavigationController class]])
//        {
//            NSInteger count=[[controler viewControllers] count];
//            UIViewController* currentController=[[controler viewControllers] objectAtIndex:count-1];
//            
//            //跳转到相应的充值页面
//            [[ViewControllerManager sharedManager] launchCaopanbaoRechargeViewController:currentController withJumpController:NSStringFromClass([currentController class])];
//        }
//        
//    }
}

@end
