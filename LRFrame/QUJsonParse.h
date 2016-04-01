//
//  WCFJsonParse.h
//  CaoPanBao
//
//  Created by 陈宏伟 on 14-6-12.
//  Copyright (c) 2014年 weihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRMock.h"

@interface QUJsonParse : NSObject
@property(nonatomic,assign)BOOL isNullObj;//对象是否为空
@property(nonatomic,assign)id oldClass;//记录类名
@property(nonatomic,strong)NSMutableString *returnJson;//用于拼装Json字符串
@property(nonatomic,strong)id inputClass;
@property(nonatomic,assign)NSInteger nilCount;
@property(nonatomic,strong)NSString *pMethod;

-(id)objFromString:(NSString*) jsonString withClass:(id) cls;//通过json字符串来填充相应的类与其相关子类
-(id)objFromString:(NSString*) jsonString withClass:(id) cls withMetmod:(NSString*)method;
-(NSString *)stringFromObjc:(id )obj;//将类与其相关子类的数据生成json字符串
-(NSString *)stringFromObjc:(id )obj withMetmod:(NSString*)method;
-(NSDictionary *)dictionaryFromObjc:(id )obj;//将类与其相关子类的数据生成字典,并去除字典中为空的key-value键值对
@end
