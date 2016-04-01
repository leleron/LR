//
//  WCFJsonParse.m
//  WeiCaiFu
//
//  Created by 陈宏伟 on 14-6-12.
//  Copyright (c) 2014年 weihui. All rights reserved.
//

#import "QUJsonParse.h"
#import <objc/runtime.h>
#import "JSONKit.h"
#import "WHStringHelper.h"
#define PROJECTNAME @"CPB"
#define NEEDTRANSFORM_INT_FLOAT TRUE

@implementation QUJsonParse
@synthesize oldClass;
@synthesize returnJson;
@synthesize isNullObj;
@synthesize inputClass;
@synthesize nilCount;
@synthesize pMethod;

-(NSDictionary*)dictionaryFromObjc:(id)obj{
    NSString *json = [self stringFromObjc:obj];
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]initWithDictionary:[json objectFromJSONString]];
    return [NSDictionary dictionaryWithDictionary:
            [self deleteNullKeyAndValueFromDictionary:jsonDic]];
}

-(id)init{
    self = [super init];
    if (self) {
        returnJson = [[NSMutableString alloc]initWithString:@"{"];
        isNullObj = NO;
    }
    return self;
}

#pragma mark - 通过json字符串来填充相应的类与其相关子类
-(id)objFromString:(NSString*) jsonString withClass:(id) myClass{
    id returnClass = [[myClass alloc]init];
    
    nilCount = 0;
    returnClass = [self objFromString:jsonString withObjc:returnClass withSuperObjc:nil];
    
    while (class_getSuperclass(myClass) != [LREntity class]) {
        Class superCls = class_getSuperclass(myClass);
        
        nilCount = 0;
        returnClass = [self objFromString:jsonString withObjc:returnClass withSuperObjc:superCls];
        
        myClass = superCls;
    }
    
    return returnClass;
}

-(id)objFromString:(NSString*) jsonString withClass:(id) myClass withMetmod:(NSString*)method{
    id returnClass = [[myClass alloc]init];
    pMethod = method;
    
    nilCount = 0;
    returnClass = [self objFromString:jsonString withObjc:returnClass withSuperObjc:nil];
    
    while (class_getSuperclass(myClass) != [LREntity class]) {
        Class superCls = class_getSuperclass(myClass);
        
        nilCount = 0;
        returnClass = [self objFromString:jsonString withObjc:returnClass withSuperObjc:superCls];
        
        myClass = superCls;
    }
    return returnClass;
    
}


-(id)objFromString:(NSString*) jsonString withObjc:(id) myClass withSuperObjc:(id) superClass{
    //将字符串转换成json格式
    id jsonValue = [jsonString objectFromJSONString];
    //当json解析失败时直接返回nil
    if (jsonValue == nil) {
        return nil;
    }
    //判断jsonVale是否为数组类型并且oldClass有值
    if ([jsonValue isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        int index = 0;
        id tempOldClass = oldClass;
        for (id objcet in jsonValue) {
            nilCount = 0;
            id nClass = [self objFromString:[objcet JSONString]  withObjc:[[tempOldClass alloc]init] withSuperObjc:nil];
            [array insertObject:nClass atIndex:index];
            index++;
        }
        oldClass = nil;
        return array;
    }
    
    //通过runtime机制获取myClass下的所有属性的名称
    NSString *className = NSStringFromClass([superClass?superClass:myClass class]);
    const char *cClassName = [className UTF8String];
    id theClass = objc_getClass(cClassName);
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //通过枚举获得属性名称，即propertyNameString
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //使propertyNameString的第一个字母为大写
        NSString *upPropertyNameString = [self makeFirstCharUppercase:propertyNameString];
        //以类名方式拼接大写后的字符串
        NSString *newPropertyNameString = pMethod ? [NSString stringWithFormat:@"%@%@%@Entity",PROJECTNAME,pMethod,upPropertyNameString]:[NSString stringWithFormat:@"%@%@Entity",PROJECTNAME,upPropertyNameString];
        //判断名为newPropertyNameString的类是否存在
        Class pkClass=NSClassFromString(newPropertyNameString);
        //set方法
        SEL selString = NSSelectorFromString([NSString stringWithFormat:@"set%@:",upPropertyNameString]);
        //当newPropertyNameString的实体存在于工程中
        if (pkClass) {
            id subJson = [jsonValue objectForKey:propertyNameString];
            if ([subJson isEqual:[NSNull null]]) {
                continue;
            }
            //当subjson是空时直接赋值为nil
            if (subJson == nil) {
                nilCount++;
                continue;
            }
            oldClass = pkClass;
            //调用自身方法对propertyNameString的value值subJson进行json字符串填充
            
            NSInteger tempNilCount = nilCount;
            nilCount = 0;
            id class = [self objFromString:[subJson JSONString] withObjc:[[pkClass alloc]init] withSuperObjc:nil];
            nilCount = tempNilCount;
            
            //填充后调用set方式进行赋值
            [myClass performSelector:selString withObject:class];
        }
        //当newPropertyNameString的实体不存在于工程中
        else{
            id subJson =  [jsonValue objectForKey:propertyNameString];
            
            if ([subJson isEqual:[NSNull null]]) {
                continue;
            }
            //当subjson是空时直接赋值为nil
            if (subJson == nil) {
                nilCount++;
                continue;
            }
            //当subjson是字典类型时，遍历该字典检查是否有内容是nsnull如果有则移除
            if ([subJson isKindOfClass:[NSDictionary class]]) {
                NSArray *allkeys = [subJson allKeys];
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:subJson];
                for (NSString *key in allkeys) {
                    id value = [subJson objectForKey:key];
                    if (value == [NSNull null] || value == NULL) {
                        [tempDict removeObjectForKey:key];
                    }
                }
                subJson = tempDict;
            }
            //如果需要做将Int和Float强转为NSString的处理
            if (NEEDTRANSFORM_INT_FLOAT) {
                if (![subJson isKindOfClass:[NSDictionary class]] && ![subJson isKindOfClass:[NSArray class]]) {
                    [myClass performSelector:selString withObject:[WHStringHelper getStrByValue:subJson]];
                }
                
                else{
                    //直接调用set方法进行赋值
                    [myClass performSelector:selString withObject:subJson];
                }
            }
            
            else{
                
                [myClass performSelector:selString withObject:subJson];
            }
        }
        
    }
    //当所有对象都会空时则返回Nil
    if (nilCount == outCount && !superClass) {
        return nil;
    }
    return myClass;
}

#pragma mark - 将类与其相关子类的数据生成json字符串
-(NSString *)stringFromObjc:(id )obj{
    returnJson = [NSMutableString stringWithString:[self stringFromObjcs:obj withSuperObjc:nil]];
    
    Class cls = [obj class];
    
    while (class_getSuperclass(cls) != [LREntity class] && class_getSuperclass(cls) != [LRMockParam class] && cls != [LRMockParam class]  ) {
        Class superCls = class_getSuperclass(cls);
        
        if ([returnJson hasSuffix:@"}"]) {
            [returnJson replaceCharactersInRange:NSMakeRange(returnJson.length - 1, 1) withString:@","];
        }
        
        returnJson = [NSMutableString stringWithString:[self stringFromObjcs:obj withSuperObjc:superCls]];
        
        if ([returnJson hasSuffix:@","]) {
            [returnJson replaceCharactersInRange:NSMakeRange(returnJson.length - 1, 1) withString:@"}"];
        }
        
        cls = superCls;
    }
    
    if ([returnJson isEqualToString:@"{"]){
        returnJson = [NSMutableString stringWithString:@"{}"];
    }
    
    return returnJson;
}

-(NSString *)stringFromObjc:(id )obj withMetmod:(NSString*)method{
    pMethod = method;
    
    returnJson = [NSMutableString stringWithString:[self stringFromObjcs:obj withSuperObjc:nil]];
    
    Class cls = [obj class];
    
    while (class_getSuperclass(cls) != [LREntity class] && class_getSuperclass(cls) != [LRMockParam class] && cls != [LRMockParam class]  ) {
        Class superCls = class_getSuperclass(cls);
        
        if ([returnJson hasSuffix:@"}"]) {
            [returnJson replaceCharactersInRange:NSMakeRange(returnJson.length - 1, 1) withString:@","];
        }
        
        returnJson = [NSMutableString stringWithString:[self stringFromObjcs:obj withSuperObjc:superCls]];
        
        if ([returnJson hasSuffix:@","]) {
            [returnJson replaceCharactersInRange:NSMakeRange(returnJson.length - 1, 1) withString:@"}"];
        }
        
        cls = superCls;
    }
    
    if ([returnJson isEqualToString:@"{"]){
        returnJson = [NSMutableString stringWithString:@"{}"];
    }
    
    return returnJson;
}

-(NSString *)stringFromObjcs:(id )obj withSuperObjc:(id) superClass{
    if (obj == nil) {
        isNullObj = YES;
    }
    //通过runtime机制获取obj下的所有属性的名称
    NSString *className = NSStringFromClass([superClass?superClass:obj class]);
    const char *cClassName = [className UTF8String];
    id theClass = objc_getClass(cClassName);
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //通过枚举获得属性名称，即newPropertyNameString
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //使propertyNameString的第一个字母为大写
        NSString *upPropertyNameString = [self makeFirstCharUppercase:propertyNameString];
        //以类名方式拼接大写后的字符串
        NSString *newPropertyNameString = pMethod ? [NSString stringWithFormat:@"%@%@%@Entity",PROJECTNAME,pMethod,upPropertyNameString]:[NSString stringWithFormat:@"%@%@Entity",PROJECTNAME,upPropertyNameString];
        //get方法
        SEL selString = NSSelectorFromString(propertyNameString);
        //获取对象的数据
        id object = [obj performSelector:selString withObject:nil];

        //判断当前的对象名是否有对应的类存在
        Class pkClass=NSClassFromString(newPropertyNameString);
        //每个propertyNameString相当于一个Key值,使其拼接到returnJson
        [returnJson appendString:[NSString stringWithFormat:@"\"%@\":",propertyNameString]];
        //当newPropertyNameString的实体存在于工程中
        if (pkClass) {
            //判断object是否为数组类型
            if ([object isKindOfClass:[NSArray class]]) {
                int tempCount = 1;
                for (id temp in object) {
                    //当数组长度为1时
                    if (((NSArray*)object).count == 1) {
                        [returnJson appendString:@"[{"];
                        [self stringFromObjcs:temp withSuperObjc:nil];
                        [returnJson replaceCharactersInRange:NSMakeRange(returnJson.length-1, 1) withString: i == outCount - 1 ? @"}]}" : @"}],"];
                    }
                    else{
                        if (tempCount == 1) {
                            [returnJson appendString:@"[{"];
                            [self stringFromObjcs:temp withSuperObjc:nil];
                            [returnJson appendString:@","];
                        }
                        else if(tempCount ==((NSArray*)object).count){
                            [returnJson appendString:@"{"];
                            [self stringFromObjcs:temp withSuperObjc:nil];
                            //判断是否为json字符串拼接的最后一部分参数
                            [returnJson replaceCharactersInRange:NSMakeRange(returnJson.length-1, 1) withString: i == outCount - 1 ? @"}]}" : @"}],"];
                        }
                        else if(tempCount > 1 && tempCount < ((NSArray*)object).count){
                            [returnJson appendString:@"{"];
                            [self stringFromObjcs:temp withSuperObjc:nil];
                            //判断是否为json字符串拼接的最后一部分参数
                            [returnJson appendString:@","];
                        }
                        tempCount++;
                    }
                }
            }
            //非数组情况
            else{
                if (!object) {
                    [returnJson appendString: i == outCount - 1 ? @"null}" : @"null,"];
                }
                
                else{
                    [returnJson appendString:@"{"];
                    [self stringFromObjcs:object withSuperObjc:nil];
                    //如果vaule是空，则赋予null
                    if (isNullObj == YES) {
                        [returnJson replaceCharactersInRange:NSMakeRange(returnJson.length-1, 1) withString: i == outCount - 1 ? @"null}" : @"null,"];
                        isNullObj = NO;
                    }
                    else{
                        //判断是否为json字符串拼接的最后一部分参数
                        [returnJson appendString: i == outCount - 1 ? @"}" : @","];
                    }
                }
            }
        }
        //当newPropertyNameString的实体不存在于工程中
        else{
            //判断object是否为字典类型
            if ([object isKindOfClass:[NSDictionary class]]) {
                [returnJson appendString:@"{"];
                NSArray *allkeys = [object allKeys];
                int tempCount = 1;
                for (id key in allkeys) {
                    if (tempCount == [allkeys count]) {
                        //判断是否为json字符串拼接的最后一部分参数
                        [returnJson appendString: i == outCount - 1 ?
                         [NSString stringWithFormat:@"\"%@\":\"%@\"}}",key,[object objectForKey:key]] :
                         [NSString stringWithFormat:@"\"%@\":\"%@\"},",key,[object objectForKey:key]]];
                    }
                    else{
                        [returnJson appendString:[NSString stringWithFormat:@"\"%@\":\"%@\",",key,[object objectForKey:key]]];
                    }
                    tempCount++;
                }
            }
            //判断object是否为数组类型
            else  if ([object isKindOfClass:[NSArray class]]) {
                int tempCount = 1;
                for (id temp in object) {
                    if (((NSArray*)object).count == 1) {
                        [returnJson appendString: i == outCount - 1 ?
                         [NSString stringWithFormat:@"[\"%@\"]}",temp] :
                         [NSString stringWithFormat:@"[\"%@\"],",temp]];
                    }
                    else{
                        if (tempCount == 1) {
                            [returnJson appendString:[NSString stringWithFormat:@"[\"%@\",",temp]];
                        }
                        else if(tempCount ==((NSArray*)object).count){
                            //判断是否为json字符串拼接的最后一部分参数
                            [returnJson appendString: i == outCount - 1 ?
                             [NSString stringWithFormat:@"\"%@\"]}",temp] :
                             [NSString stringWithFormat:@"\"%@\"],",temp]];
                        }
                        else if(tempCount > 1 && tempCount < ((NSArray*)object).count){
                            [returnJson appendString:[NSString stringWithFormat:@"\"%@\",",temp]];
                        }
                        tempCount++;
                    }
                }
            }
            //其他类型
            else{
                if (object == nil) {
                    [returnJson appendString: i == outCount - 1 ?
                     [NSString stringWithFormat:@"null}"] :
                     [NSString stringWithFormat:@"null,"]];
                }
                else{
                    //判断是否为json字符串拼接的最后一部分参数
                    [returnJson appendString: i == outCount - 1 ?
                     [NSString stringWithFormat:@"\"%@\"}",object] :
                     [NSString stringWithFormat:@"\"%@\",",object]];
                }
            }
            //            NSLog(@"%@  =  %@",propertyNameString,str);
        }
    }
    return returnJson;
}




#pragma mark - 将类与其相关子类的数据生成字典


#pragma mark - 去除字典中为空的key-value键值对
-(NSMutableDictionary *)deleteNullKeyAndValueFromDictionary:(NSMutableDictionary *)jsonStr{
    //遍历字典中的key
    for (id mainKey in [jsonStr allKeys]) {
        //得到当前key所对应的value
        id mainValue = [jsonStr objectForKey:mainKey];
        //将可能存在的JKDictionary类型转成NSMutableDictionary
        if([mainValue isKindOfClass:[NSMutableDictionary class]]){
            mainValue=[NSMutableDictionary dictionaryWithDictionary:mainValue];
        }
        //如果当前的mainValue是数组类型
        if ([mainValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *countArray = [[NSMutableArray alloc]init];
            int tempCount = 0;
            //从当前的value中遍历数组成员
            for (id tempValue in mainValue) {
                //如果如果这个数组对象是字典类型
                if ([tempValue isKindOfClass:[NSMutableDictionary class]]) {
                    //将可能存在的JKDictionary类型转成NSMutableDictionary
                    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]initWithDictionary:tempValue];
                    //递归方法获取处理后的返回字典
                    NSMutableDictionary *returnDic =
                    [self deleteNullKeyAndValueFromDictionary:jsonDic];
                    //将返回的内容从新插入到一个新的数组中
                    [countArray insertObject:returnDic atIndex:tempCount];
                    tempCount ++;
                }
                //非字典类型则直接插入到新的数组
                else{
                    [countArray insertObject:tempValue atIndex:tempCount];
                }
            }
            
            NSMutableArray *newCountArray  =  [NSMutableArray arrayWithArray:countArray];
            //遍历当前的新组数countArray对其中为空的项进行删除
            for (id temp2 in countArray) {
                if ([temp2 isKindOfClass:[NSMutableDictionary class]]) {
                    if ([temp2 allKeys].count < 1) {
                        [newCountArray removeObject:temp2];
                    }
                }
            }
            //将最后形成的数组去替换掉原先的
            [jsonStr setObject:newCountArray forKey:mainKey];
        }
        //如果当前的mainValue是字典类型
        else if ([mainValue isKindOfClass:[NSMutableDictionary class]]) {
            NSArray *allkeys = [mainValue allKeys];
            int tempCount = 0;
            //遍历字典中的key
            for (id tempkey in allkeys) {
                //当前的key所对应的value
                id tempValue = [mainValue objectForKey:tempkey];
                //如果value是字典类型
                if ([tempValue isKindOfClass:[NSMutableDictionary class]]) {
                    //将可能存在的JKDictionary类型转成NSMutableDictionary
                    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]initWithDictionary:tempValue];
                    //递归方法获取处理后的返回字典
                    NSMutableDictionary *returnDic = [self deleteNullKeyAndValueFromDictionary:jsonDic];
                    //当返回字典的内容不存在时
                    if (returnDic.count < 1) {
                        //删掉其key-value键值对
                        [mainValue removeObjectForKey:tempkey];
                        //如果该键值对的上一层内容不存在
                        if ([mainValue allKeys].count < 1) {
                            //删掉其上层的key-value键值对
                            [jsonStr removeObjectForKey:mainKey];
                        }
                        //当该键值对的上一层内容存在时，则重新对JsonStr进行赋值
                        else{
                            [jsonStr setObject:mainValue forKey:mainKey];
                        }
                    }
                    //当字典内容存在时则进行重新赋值
                    else{
                        [mainValue setObject:returnDic forKey:tempkey];
                        [jsonStr setObject:mainValue forKey:mainKey];
                    }
                }
                //如果mainValue不存在时
                else  if (tempValue == NULL || [tempValue isEqual:[NSNull null]]) {
                    tempCount++;
                    //删除键值对
                    [mainValue removeObjectForKey:tempkey];
                    //当所在key下所有的value都不存在时
                    if (tempCount == allkeys.count) {
                        //则删除其上一层的key-value键值对
                        [jsonStr removeObjectForKey:mainKey];
                    }
                }
                
            }
        }
        //如果当前的mainValue不存在时
        else if (mainValue == NULL || [mainValue isEqual:[NSNull null]]) {
            //删除键值对
            [jsonStr removeObjectForKey:mainKey];
        }
    }
    
    return jsonStr;
    
}

#pragma mark - 使字符串首字母变成大写
-(NSString*)makeFirstCharUppercase:(NSString*)str{
    if (str.length > 0) {
        NSString *firstChar = [str substringWithRange:NSMakeRange(0, 1)];
        [firstChar uppercaseString];
        return  [NSString stringWithFormat:@"%@%@",[firstChar uppercaseString],[str substringWithRange:NSMakeRange(1, str.length - 1)]] ;
    }
    return str;
}

static const char *getPropertyType(objc_property_t property) {
    
    const char *attributes = property_getAttributes(property);
    
    char buffer[1 + strlen(attributes)];
    
    strcpy(buffer, attributes);
    
    char *state = buffer, *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL) {
        
        if (attribute[0] == 'T') {
            
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
            
        }
        
    }
    
    return "@";
    
}
@end
