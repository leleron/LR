//
//  LRBaseRequset.h
//  LRFrame
//
//  Created by leron on 15/5/29.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRBaseRequset : NSOperation
@property(assign,nonatomic)double timeOutRequest;
@property(strong,nonatomic)NSDictionary* param;
@property(strong,nonatomic)NSString* operationType;
@property(strong,nonatomic)NSString* sendMethod;


-(id)initWithTaget:(id)target selector:(SEL)selector;
@end
