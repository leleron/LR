//
//  StringHelper.h
//  CaoPanBao
//
//  Created by zhuojian on 14-5-8.
//  Copyright (c) 2014年 Mark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHStringHelper : NSObject

/** 
 日期增加前缀0
 2014-9-1 => 2014-09-01
 1-9 转为 01,02,03..09 */
+(NSString*)prefixDate:(NSInteger)value;

/**返回19:30:59*/
+(NSString*)timeDate:(NSDateComponents*)date;

/** 时间戳转nsdate */
+(NSDate*)dateByTimeStamp:(double)timestamp;

/** 返回05-21 19:30 */
+(NSString*)shortDate:(NSDateComponents*)date;

/** 返回2014-05-21 19:30 */
+(NSString*)longDateTime:(NSDateComponents*)date;

/** 返回2014-05-21 19:30:59 */
+(NSString*)longDateTime2:(NSDateComponents*)date;

/** 返回05-21 19:30 */
+(NSString*)shortDateByTimeStamp:(double)timestamp;

/** 根据时间戳返回 NSDateComponents ，从而获得年月日时分秒*/
+(NSDateComponents*)dateComponentByTimeStamp:(double)timestamp;

/** 
 获取字符串（如果目标为数字则强制转为字符串）
 */
+(NSString*)getStrByValue:(id)value;

/** 获取数组中的字符串 */
+(NSString*)getStrByArray:(id)array index:(int)index;

/** 获取数字（如果目标为字符串则强制转为数字） */
+(NSNumber*)getNumByValue:(id)value;

/** 获取字典键值数据 */
+(NSString*)key:(NSString*)key dict:(NSDictionary *)dict;

/** 获取数据根据键值 */
+(NSArray*)arrayKey:(NSString*)key dict:(NSDictionary*)dict;

/** 获取短日期
 @param key 键名
 @param dict 字典
 */
+(NSString*)shortDateByTimeStampKey:(NSString*)key dict:(NSDictionary*)dict;

/** 判断是否有效的数据变量 */
+(BOOL)isNilByValue:(id)value;

/** 转换目标对象为布尔值
 （如果目标对象为1 返回 TRUE,YES 返回 TRUE, 0 返回 FALSE,NO 返回 FALSE ）
 */
+(BOOL)getBOOLByValue:(id)value;


//+(NSString*)removeLastString:(NSString*)lastString orginString:(NSString*)orginString;

@end
