//
//  StringHelper.m
//  CaoPanBao
//
//  Created by zhuojian on 14-5-8.
//  Copyright (c) 2014年 Mark. All rights reserved.
//

#import "WHStringHelper.h"

@implementation WHStringHelper
#pragma mark - date util
+(NSString*)prefixDate:(NSInteger)value{
    return  value<10?[NSString stringWithFormat:@"0%ld",(long)value]:[NSString stringWithFormat:@"%ld",(long)value];
}

+(NSString*)timeDate:(NSDateComponents*)date{
    NSString* hours=[self prefixDate:date.hour];
    NSString* mins=[self prefixDate:date.minute];
    NSString* sec=[self prefixDate:date.second];
    
    NSString* dd=[NSString stringWithFormat:@"%@:%@:%@",hours,mins,sec];
    return dd;
}

+(NSString*)shortDate:(NSDateComponents*)date{
    NSString* month=[self prefixDate:date.month];
    NSString* day=[self prefixDate:date.day];
    NSString* hours=[self prefixDate:date.hour];
    NSString* mins=[self prefixDate:date.minute];
    NSString* sec=[self prefixDate:date.second];
    
    NSString* dd=[NSString stringWithFormat:@"%@-%@ %@:%@:%@",month,day,hours,mins,sec];
    return dd;
}

+(NSString*)longDateTime:(NSDateComponents*)date{
    NSString* year=[self prefixDate:date.year];
    NSString* month=[self prefixDate:date.month];
    NSString* day=[self prefixDate:date.day];
    NSString* hours=[self prefixDate:date.hour];
    NSString* mins=[self prefixDate:date.minute];
//    NSString* sec=[self prefixDate:date.second];
    
    NSString* dd=[NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hours,mins];
    return dd;
}

+(NSString*)longDateTime2:(NSDateComponents*)date{
    NSString* year=[self prefixDate:date.year];
    NSString* month=[self prefixDate:date.month];
    NSString* day=[self prefixDate:date.day];
    NSString* hours=[self prefixDate:date.hour];
    NSString* mins=[self prefixDate:date.minute];
    NSString* sec=[self prefixDate:date.second];
    
    NSString* dd=[NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",year,month,day,hours,mins,sec];
    return dd;
}

+(NSDateComponents*)dateComponentByTimeStamp:(double)timestamp{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:confromTimesp];
    return components;
}

+(NSString*)shortDateByTimeStamp:(double)timestamp{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:confromTimesp];
    return [self shortDate:components];
}

+(NSDate*)dateByTimeStamp:(double)timestamp{
   return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

#pragma string helper

+(NSString*)getStrByNum:(NSNumber*)val{
    if(val)
        return [val stringValue];
    else
        return nil;
}

+(NSString*)getStrByStr:(NSString*)str{
    if(str)
        return str;
    else
        return nil;
}

+(NSString*)getStrByValue:(id)value{
    if(!value)
        return nil;
    
    if([value isKindOfClass:[NSString class]])
    {
        return [self getStrByStr:value];
    }
    else if([value isKindOfClass:[NSNumber class]])
    {
        return [self getStrByNum:value];
    }
    
    return nil;
}

+(NSString*)getStrByArray:(id)array index:(int)index{
     id obj= [array objectAtIndex:index];
    return [WHStringHelper getStrByValue:obj];
}

+(NSNumber*)getNumByValue:(id)value{
    NSNumber* result=nil;
    
    if(!value)
        return nil;
    
    if([value isKindOfClass:[NSString class]])
    {
        result=[NSNumber numberWithInt:[value intValue]];
    }
    
    if([value isKindOfClass:[NSNumber class]])
    {
        result=value;
    }
    
    return result;
}

+(NSString*)key:(NSString*)key dict:(NSDictionary *)dict{
    if([dict isKindOfClass:[NSNull class]])
        return nil;
    
    if(!dict)
        return nil;
        
    id result=[dict objectForKey:key];
    if([result isKindOfClass:[NSNumber class]])
    {
        result=[result stringValue];
    }
    return result;
}

+(NSArray*)arrayKey:(NSString*)key dict:(NSDictionary*)dict{
    id result=[dict objectForKey:key];
    return result;
}

+(NSString*)shortDateByTimeStampKey:(NSString*)key dict:(NSDictionary*)dict
{
    NSString* result=nil;
    result=[dict objectForKey:key];
    
    if(result)
    {
        result=[WHStringHelper shortDateByTimeStamp:[result doubleValue]];
    }
    
    return result;
}

+(BOOL)isNilByValue:(id)value{
    BOOL isNil=NO;
    
    if(value==nil)
        return YES;
    
    if([value isKindOfClass:[NSNull class]])
        return YES;
    
    Class clsJKArray= NSClassFromString(@"JKArray");
    
    if([value isKindOfClass:clsJKArray])
    {
        if([value count]==0)
            isNil= YES;
    }
    
    Class clsJKDictionary=NSClassFromString(@"JKDictionary");
    if([value isKindOfClass:clsJKDictionary])
    {
        if([[value allKeys] count]==0)
            isNil= YES;
    }
    
    if([value isKindOfClass:[NSDictionary class]])
    {
        if([[value allKeys] count]==0)
            isNil= YES;
    }
    
    if([value isKindOfClass:[NSArray class]])
    {
        if([value count]==0)
            isNil= YES;
    }
    
    
    return isNil;
}

+(BOOL)getBOOLByValue:(id)value{
    NSString* str=[WHStringHelper getStrByValue:value];
    if(!str)
        return NO;
    
    
    if([str isEqualToString:@"1"])
        return YES;
    
    else if([str isEqualToString:@"0"])
        return NO;
    
    else if([str isEqualToString:@"YES"])
        return YES;
    
    else if ([str isEqualToString:@"NO"])
        return NO;
    
    return NO;
}

//+(NSString*)removeLastString:(NSString *)lastString orginString:(NSMutableString *)orginString{
//    if(orginString.length>0)
//    {
//        NSString* str= [orginString substringFromIndex:[orginString length]-1];
//        
//        if([str isEqualToString:@","])
//        {
//            NSRange range;
//            range.length=1;
//            range.location=[orginString length]-1;
//            [orginString deleteCharactersInRange:range];
//        }
//    }
//    
//    return orginString;
//}
@end
