//
//  LRViewController.h
//  LRFrame
//
//  Created by leron on 15/5/27.
//  Copyright (c) 2015年 leron. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LRViewControllerDelegate <NSObject>
@optional
-(void)LRViewControllerOnLeft;
-(void)LRViewControllerOnRight;
@end

typedef enum
{
    kNav_Left_Button_Back = 1,      // 返回按钮
    kNav_Left_Button_Cancel = 2,    // 取消按钮
    KNav_Left_Button_Custom = 3,    //自定义
    kNav_Left_Button_None = 4       // 无
} NavLeftButtonType ;


@interface LRViewController : UIViewController
@property(nonatomic,assign)id<LRViewControllerDelegate> delegate;
@property(nonatomic,assign)NavLeftButtonType leftButtonType;  //左边按钮标识
@property (nonatomic, strong) NSString *navigationBarTitle; //标题
@property(nonatomic,strong)UIImage* leftButtonImage;       //左边按钮图片
@property(nonatomic,strong)UIImage* rightButtonImage;     //右边按钮图片
@property (nonatomic,strong)UIView* navigationTitleView;  //自定义titleview
@property(nonatomic,strong)UIImage* navBGImage;          //背景图片
@property (nonatomic,strong)UITableView* myTableView;   //tableView


- (void) setNavigationTitle;
-(void)setNavigationBarView:(UIView *)navigationBarView;


//-(void)setleftButtonWithImage:(NSString*)image highLightImage:(NSString*)highLightImage;
//-(void)setRightButtonWithImage:(NSString*)image highLightImage:(NSString*)highLightImage;
//-(void)setLeftButtonWithText:(NSString*)text;
//-(void)setRightButtonText:(NSString*)text;

@end
