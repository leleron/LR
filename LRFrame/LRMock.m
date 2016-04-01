//
//  LRMock.m
//  LRFrame
//
//  Created by leron on 15/5/29.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import "LRMock.h"
#import "LRNetOperation.h"
#import "LRNetResponse.h"

@implementation LRMockParam
+(instancetype)param{
    return [[self alloc]init];
}

@end


@implementation LRMock


+(instancetype)mock{
    return [[self alloc]init];
}

-(void)run:(LRMockParam*)param{
    [self run:param with:nil];
}

-(void)run:(LRMockParam *)param with:(UIView *)waitView{
    [self run:param with:waitView withPoint:CGPointZero];
}

-(void)run:(LRMockParam *)param with:(UIView *)waitView withPoint:(CGPoint)point{

    param.operationType=[self getOperatorType];
    
    LRNetOperation* operation=[[LRNetOperation alloc]init];
    
    operation.delegete=self;
    
    operation.delayTimeOut=[self delayRequestTimeOut];
    
    [operation request:param];

}

-(NSString*)getAliasName{
    return nil;
}

-(double)delayRequestTimeOut{
    return 9.0f;
}
#pragma mark LRNetOperationDelegate
-(void)LRNetOperation:(LRNetOperation *)operation with:(LRNetResponse *)response{
//    if ([response.retCode isEqualToString:@"100"]) {
        [self.delegate LRNetMock:self withEntity:response.myEntity];
//    }
}

@end
