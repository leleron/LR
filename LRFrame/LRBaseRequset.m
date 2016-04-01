//
//  LRBaseRequset.m
//  LRFrame
//
//  Created by leron on 15/5/29.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import "LRBaseRequset.h"
#import "LRNetResponse.h"
#import "AFNetworking.h"
#import "JSONKit.h"
@interface LRBaseRequset()
{
    id myTaget;
    SEL mySelector;
    LRNetResponse* myResponse;
}
@end
@implementation LRBaseRequset

-(id)initWithTaget:(id)target selector:(SEL)selector{
    self = [super init];
    if (self) {
        myTaget = target;
        mySelector = selector;
        myResponse = [[LRNetResponse alloc]init];
        myResponse.request = self;
    }
    return self;
}
-(void)main{
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc]init];
    NSMutableString* url = [[NSMutableString alloc]initWithString:BASE_URL];
    [url appendString:self.operationType];
    NSLog(@"%@",url);
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];

    if ([self.sendMethod isEqualToString:@"get"]) {
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject){
//            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (operation.response.statusCode == 200) {
                NSDictionary *rootDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
                
                myResponse.retCode = [rootDic objectForKey:@"code"];
                myResponse.retString = [rootDic objectForKey:@"message"];
                myResponse.jsonBody = [rootDic JSONString];
                if ([myResponse.retCode isEqualToString:@"100"]) {
                    [self toCallback];
                }else{
                    myResponse.retString = NSLocalizedString(@"服务请求异常，请稍后重试", @"");
                }
            }
        }failure:^(AFHTTPRequestOperation *operation,NSError *error){
            
            NSLog(@"error:%@",error);
            if ([error code] == 2) {
                myResponse.retCode = @"99999";
                myResponse.retString = NSLocalizedString(@"服务器访问超时，网络连接异常", @"");
            }
        }];
    }
    
    if ([self.sendMethod isEqualToString:@"post"]) {

        [manager POST:url parameters:self.param success:^(AFHTTPRequestOperation* operation,id responseObject){
            NSDictionary *rootDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            if (rootDic) {
//                NSDictionary *headDic = [rootDic objectForKey:@"head"];
//                NSDictionary* body = [rootDic objectForKey:@"body"];
                
                myResponse.retCode = [rootDic objectForKey:@"code"];
                myResponse.retString = [rootDic objectForKey:@"message"];
//                myResponse.jsonBody = [rootDic JSONString];
                NSError *parseError = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rootDic options:NSJSONWritingPrettyPrinted error:&parseError];
                myResponse.jsonBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                
                if ([myResponse.retCode isEqualToString:@"100"]) {
                    [self toCallback];
                }else{
                    myResponse.retString = NSLocalizedString(@"服务请求异常，请稍后重试", @"");
                }
            }
        }failure:^(AFHTTPRequestOperation* operation,NSError *error){
            NSLog(@"error:%@",error);
            if ([error code] == 2) {
                myResponse.retCode = @"99999";
                myResponse.retString = NSLocalizedString(@"服务器访问超时，网络连接异常", @"");
            }
        }];
    }
    
    
}


-(void)toCallback{
    if ([myTaget respondsToSelector:mySelector]) {
        [myTaget performSelectorOnMainThread:mySelector withObject:myResponse waitUntilDone:YES];
    }
}
@end
