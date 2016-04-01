//
//  ViewController.m
//  LRFrame
//
//  Created by leron on 15/5/27.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import "ViewController.h"
#import "loginMock.h"
#import "SecondViewController.h"
@import WebKit;
@interface ViewController ()<LRMockDelegate>
@property(strong,nonatomic)loginMock* myLoginMock;
@property(strong,nonatomic)loginParam* myLoginParam;
@property (nonatomic,strong)WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMock];
//    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SecondViewController* controller = [mainStoryBoard instantiateViewControllerWithIdentifier:@"secondViewController"];
//    
//    UITabBarController* tabBarController = [[UITabBarController alloc]init];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)initMock{
    self.myLoginMock = [loginMock mock];
    self.myLoginMock.delegate = self;
    self.myLoginParam = [loginParam param];
    self.myLoginParam.sendType = @"post";
    self.myLoginParam.LOGINID = @"15021631445";
    self.myLoginParam.PASSWORD = @"123456";
    self.myLoginParam.LAST_PHONE_SYSTEM = @"ios";
    [self.myLoginMock run:self.myLoginParam];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)LRNetMock:(LRMock *)mock withEntity:(LREntity *)entity{
    LREntity* e = (LREntity*)entity;
    
}
@end
