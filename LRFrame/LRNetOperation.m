//
//  LRNetOperation.m
//  LRFrame
//
//  Created by leron on 15/5/29.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import "LRNetOperation.h"
#import "QUJsonParse.h"
#import "LRBaseRequset.h"
#import "LRNetResponse.h"
#import "WpGlobalOption.h"
@interface LRNetOperation()
{
}
@end

static NSOperationQueue* operationQueue;

@implementation LRNetOperation

-(void)request:(LRMockParam *)param{
    
    
    static dispatch_once_t dispathOnce ;
    dispatch_once(&dispathOnce, ^{
        operationQueue = [[NSOperationQueue alloc]init];
        [operationQueue setMaxConcurrentOperationCount:8];
    });
    LRBaseRequset* baseRequset = [[LRBaseRequset alloc]initWithTaget:self selector:@selector(callBack:)];
    baseRequset.timeOutRequest = self.delayTimeOut;
    QUJsonParse* parse = [[QUJsonParse alloc]init];
    baseRequset.param =[parse dictionaryFromObjc:param];
    baseRequset.operationType = param.operationType;
    baseRequset.sendMethod = param.sendType;
    [operationQueue addOperation:baseRequset];
    
}

#pragma mark --netOperationDelegate
-(void)callBack:(LRNetResponse*)response{
    LRMock* mock=(LRMock*)self.delegete;
    
    response.request.operationType=[mock getOperatorType];
    Class cls=[mock getEntityClass];
    
    if(cls)
    {
        if(response.retString==QU_SERVICE_BACK_OK)
        {
            response.myEntity=[[[QUJsonParse alloc] init] objFromString:response.jsonBody withClass:cls withMetmod:[mock getAliasName]];
        }
    }

    [self.delegete LRNetOperation:self with:response];
}

    

@end
