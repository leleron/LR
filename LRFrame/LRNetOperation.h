//
//  LRNetOperation.h
//  LRFrame
//
//  Created by leron on 15/5/29.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRMock.h"
@class LRMockParam;
@class LRMock;
@class LRNetResponse;
@class LRNetOperation;
@protocol LRNetOperationDelegate <NSObject>

-(void)LRNetOperation:(LRNetOperation*)operation with:(LRNetResponse*)netResponse;

@end

@interface LRNetOperation : NSObject
@property(strong,nonatomic)id<LRNetOperationDelegate>delegete;
@property(assign,nonatomic)double delayTimeOut;
-(void)request:(LRMockParam*)param;
@end
