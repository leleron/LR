//
//  LRMock.h
//  LRFrame
//
//  Created by leron on 15/5/29.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRNetOperation.h"
@protocol LRMockDelegate<NSObject>
@optional
-(void)LRNetMock:(LRMock*)mock withEntity:(LREntity*)entity;
@end

@interface LRMockParam : NSObject
@property(strong,nonatomic)NSString* operationType;     //request name
@property(strong,nonatomic)NSString* sendType;         //post get
+(instancetype)param;
@end

@interface LRMock : NSObject<LRNetOperationDelegate>
@property(strong,nonatomic)LRMockParam* param;
@property(strong,nonatomic)id<LRMockDelegate>delegate;
+(instancetype)mock;
-(void)run:(LRMockParam*)param;
-(void)run:(LRMockParam *)param with:(UIView*)waitView;
-(void)run:(LRMockParam *)param with:(UIView *)waitView withPoint:(CGPoint)point;
-(NSString*)getOperatorType;
-(Class)getEntityClass;
-(double)delayRequestTimeOut;
-(NSString*)getAliasName;

@end
