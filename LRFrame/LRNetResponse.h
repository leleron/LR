//
//  LRResponse.h
//  LRFrame
//
//  Created by leron on 15/5/29.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRBaseRequset.h"
@interface LRNetResponse : NSObject
@property (nonatomic, strong) LRBaseRequset* request;
@property (nonatomic, strong) NSString* retCode;      //返回code
@property (nonatomic, strong) NSString* retString;    //返回信息
@property (nonatomic, strong) id data;
@property (nonatomic, strong) id errorData;
@property(nonatomic,strong)NSString* jsonBody;         //返回的json
@property(nonatomic,strong)NSString* retServiceTime;   //响应时间
@property(nonatomic,strong)LREntity* myEntity;
+(instancetype)response;
@end
