//
//  WpGlobalOption.h
//  WeiboPaySdkLib
//
//  Created by Mark on 13-5-29.
//  Copyright (c) 2013年 WeiboPay. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RETCODE_NONE_DEAL_TIME @"20104"   // 非行情查询时间

#define ALERT_MONEY_NOT_ENOUGH_20052 201  // 余额不足

//@class WpResponse;
@class LRNetResponse;

typedef enum QUServiceState {
    QU_SERVICE_BACK_OK,
    QU_SERVICE_BACK_FAIL,
    QU_SERVICE_BACK_SESSIONEXPIRED,
    QU_SERVICE_BACK_MESSAGECODE, //短信超时提示
    QU_SERVICE_BACK_GESTURESINTERRUPT,    // 验证手势中断
    QU_SERVICE_CONFIRM_RISK_ALERT,    // 弹出alert对话框
    QU_SERVICE_CONFIRM_RISK_WEB,       // 弹出web对话框
    QU_SERVICE_RULE_SELECTED_ERROR    // 方案选择错误
} QUServiceState;

@interface WpGlobalOption : NSObject

// 获得全局的GlobalOption
+ (WpGlobalOption*)sharedOption;

// 调用服务端主要请求
- (void)executeUrlOperation:(NSOperation*)operation;
// 调用服务端其他次要请求（后台加载请求或图片请求）
- (void)executeImageOperation:(NSOperation*)operation;

// 得到设备的HashValue
- (NSString*)getDeviceHashValue;

// 服务端请求返回状态判断
//- (NSInteger)serviceCallBackFromApp:(QUNetResponse*)response andShowMessage:(BOOL)bShow;
//- (WpServiceState)serviceCallBack:(WpResponse*)response;

@end
