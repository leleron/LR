//
//  LRViewController.m
//  LRFrame
//
//  Created by leron on 15/5/27.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import "LRViewController.h"
#define kNavRightButonOffsetIOS7 16 // 导航条右边按钮向右偏移值
#define kNavRightButonTextOffsetIOS7 8 // 导航条右边文字按钮向右偏移值
#define kNavLeftButonTextOffsetIOS7 10 // 导航条左边文字按钮向左偏移值
#define kNavLeftLabelTextOffsetIOS7 8 // 导航条左边文字按钮向左偏移值

#define kNavRightButonOffset IOS7_OR_LATER?kNavRightButonOffsetIOS7:0
#define kNavRightButonTextOffset IOS7_OR_LATER?kNavRightButonTextOffsetIOS7:0

#define kNavLeftButonTextOffset IOS7_OR_LATER?kNavLeftButonTextOffsetIOS7:0 // 导航条左边文字按钮向左偏移值
#define kNavLeftLabelTextOffset IOS7_OR_LATER?kNavLeftLabelTextOffsetIOS7:kNavLeftLabelTextOffsetIOS7+12 // 导航条左边文字按钮向左偏移值

#define kNavigationBarHighLightColor [UIColor colorWithRed:136.f/255.f green:136.f/255.f blue:136.f/255.f alpha:1.f]


@interface LRViewController ()

@end

@implementation LRViewController

- (void) loadView
{
    [super loadView];
    self.leftButtonType = kNav_Left_Button_Back;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationBar];
    
    if (self.leftButtonType == kNav_Left_Button_None) {
        self.navigationItem.hidesBackButton = YES;
    }else
      [self showBackButton];
    [self showRightButton];
    // Do any additional setup after loading the view.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    return self;
}
-(void)initNavigationBar{
    if (self.navBGImage) {
        [self.navigationController.navigationBar setBackgroundImage:self.navBGImage forBarMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationController.navigationBar setBackgroundColor:NAV_COLOR_BACKGROUND];
    }
    [self setNavigationTitle];

}
-(void)setNavigationTitle{
    UIColor *titleColor = [UIColor whiteColor];
    
    UIFont  *titleFont = [UIFont boldSystemFontOfSize:18];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:titleColor,NSForegroundColorAttributeName,titleFont, NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    if (self.navigationBarTitle) self.navigationItem.title = self.navigationBarTitle;
    if (self.navigationTitleView) {
        self.navigationItem.titleView = self.navigationTitleView;
    }
    
}

-(void)setNavigationBarView:(UIView *)navigationBarView{
    self.navigationItem.titleView = self.navigationTitleView;
}

-(void)showBackButton{
    
    if (self.leftButtonImage) {
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.leftButtonImage.size.width, self.leftButtonImage.size.height)];
        [btn setImage:self.leftButtonImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:btn]];
        
    }else{
//        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:nil target:self action:@selector(goBack)]];
    }
}

-(void)showRightButton{
    if (self.rightButtonImage) {
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.rightButtonImage.size.width, self.rightButtonImage.size.height)];
        [btn setImage:self.rightButtonImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goRight) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:btn]];
    }
}

-(void)goBack{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(LRViewControllerOnLeft)]) {
            [self.delegate LRViewControllerOnLeft];
        }else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)goRight{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(LRViewControllerOnRight)]) {
            [self.delegate LRViewControllerOnRight];
        }
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
