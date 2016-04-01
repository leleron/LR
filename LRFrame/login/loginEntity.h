//
//  loginEntity.h
//  Empty
//
//  Created by leron on 15/6/9.
//  Copyright (c) 2015年 李荣. All rights reserved.
//

#import "LREntity.h"

@interface loginEntity : LREntity
@property(strong,nonatomic)NSString* status;
@property(strong,nonatomic)NSString* message;
@property(strong,nonatomic)NSString* tokenId;
@property(strong,nonatomic)NSString* userid;
@property(strong,nonatomic)NSString* userName;
@end
