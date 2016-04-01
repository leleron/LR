//
//  SYQRCodeViewController.m
//  SYQRCodeDemo
//
//  Created by leron on 15-1-9.
//  Copyright (c) 2015年 李荣. All rights reserved.
//

#import "SYQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZBarReaderController.h"
#import "ConfigNetViewController.h"
#import "checkBindedMock.h"
#import "deviceCardMock.h"
#import "FKDeviceCardViewController.h"
#import "FKGetDeviceCardMock.h"
#import "getDeivceIdMock.h"
#import "RegardingDeviceMock.h"
#import "CamObj.h"
#import "VideoController.h"
#import "AirCleanerViewController.h"
#import "Reachability.h"

//设备宽/高/坐标
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
#define KDeviceFrame [UIScreen mainScreen].bounds

float kLineMinY = 121;
float kLineMaxY = 321;
static const float kReaderViewWidth = 200;
static const float kReaderViewHeight = 200;

@interface SYQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate,ZBarReaderDelegate,UIImagePickerControllerDelegate>
{
}
@property (nonatomic, strong) AVCaptureSession *qrSession;//回话
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;//读取
@property (nonatomic, strong) UIImageView *line;//交互线
@property (nonatomic, strong) NSTimer *lineTimer;//交互线控制
@property (nonatomic, strong) checkBindedMock* myCheckMock;
@property (nonatomic, strong)NSString* stringCode;
//@property (nonatomic, strong) deviceCardMock* myDeviceCardMock;
@property (nonatomic, strong)UIButton* flashlight;   //闪光灯
@property (nonatomic, strong)UIButton* Library;     //相册
@property (nonatomic,getter=isOpenFlash)BOOL isOpenFlash;   //是否打开闪光灯
@property (nonatomic,strong)UIImageView* imgFlash;
@property(strong,nonatomic)NSString* deviceId;
@property(strong,nonatomic)RegardingDeviceMock* myRegardMock;    //获取设备信息
@end

@implementation SYQRCodeViewController

- (void)viewDidLoad
{
    self.navigationItem.title = @"扫一扫";

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
    [self setOverlayPickerView];
    [self startSYQRCodeReading];
    [self addFunc];
    self.isOpenFlash = false;
//    [self initTitleView];
//    [self createBackBtn];
}

-(void)viewWillAppear:(BOOL)animated{
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        UIAlertController *noNetwork = [UIAlertController alertControllerWithTitle:@"没有网络" message:@"请检查网络连接" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=AIRPLANE_MODE"]];
            [noNetwork dismissViewControllerAnimated:YES completion:nil];
        }];
        [noNetwork addAction:cancelAction];
        [self presentViewController:noNetwork animated:YES completion:^{
        }];
        NSLog(@"no wifi");
    }
    [self checkCamera];
    [self.qrSession startRunning];
    [self startSYQRCodeReading];


}

-(void)checkCamera{
    //摄像头判断
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
   NSError* error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"打开相机错误" message:@"无法打开摄像头，请在系统设置确认摄像头权限是否已经打开" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
            
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                
            }
            
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            
        }];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.isOpenFlash) {
        [self turnTorchOn:false];
    }
}

//- (void)navigationToMainView {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

- (void)dealloc
{
    if (_qrSession) {
        [_qrSession stopRunning];
        _qrSession = nil;
    }
    
    if (_qrVideoPreviewLayer) {
        _qrVideoPreviewLayer = nil;
    }
    
    if (_line) {
        _line = nil;
    }
    
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
}


-(void)addFunc{
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 124, SCREEN_WIDTH, 60)];
    view.tintColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.600];
    [view setBackgroundColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.600]];

    [self.view addSubview:view];
    self.flashlight = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 10, 60, 50)];
    [self.flashlight setTitle:@"闪光灯" forState:UIControlStateNormal];
    self.Library = [[UIButton alloc]initWithFrame:CGRectMake(45, 10, 60, 50)];
    [self.Library setTitle:@"相册" forState:UIControlStateNormal];
    [view addSubview:self.flashlight];
    [view addSubview:self.Library];
    UIImage* photo = [UIImage imageNamed:@"icon_photo"];
    UIImageView* viewPhoto = [[UIImageView alloc]initWithFrame:CGRectMake(10, 22, 35, 25)];
    viewPhoto.image = photo;
    [view addSubview:viewPhoto];
    UIImageView* viewFlash = [[UIImageView alloc]initWithFrame:CGRectMake(self.flashlight.frame.origin.x - 30, 22, 20, 30)];
    self.imgFlash = viewFlash;
    viewFlash.image = [UIImage imageNamed:@"flash"];
    [view addSubview:viewFlash];
    [self.Library addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];

    [self.flashlight addTarget:self action:@selector(Flashlight) forControlEvents:UIControlEventTouchUpInside];
}


- (void)initUI
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
   NSError* error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"打开相机错误" message:@"无法打开摄像头，请在系统设置确认摄像头权限是否已经打开" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
            
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                
            }
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
        }];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }

    
    
    
    
    //设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出的代理
    //使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    //拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // 读取质量，质量越高，可读取小尺寸的二维码
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else
    {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    
    //设置输出的格式
    //一定要先设置会话的输出为output之后，再指定输出的元数据类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置预览图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //设置preview图层的属性
    //preview.borderColor = [UIColor redColor].CGColor;
    //preview.borderWidth = 1.5;
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置preview图层的大小
    preview.frame = self.view.layer.bounds;
    //[preview setFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight)];
    
    //将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    //[self.view.layer addSublayer:preview];
    self.qrVideoPreviewLayer = preview;
    self.qrSession = session;
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    return CGRectMake(kLineMinY / KDeviceHeight, ((kDeviceWidth - asize.width) / 2.0) / kDeviceWidth, asize.height / KDeviceHeight, asize.width / kDeviceWidth);
}

- (void)setOverlayPickerView
{
    //画中间的基准线
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((kDeviceWidth - 300) / 2.0, kLineMinY, 300, 12 * 300 / 320.0)];
    [_line setImage:[UIImage imageNamed:@"ff_QRCodeScanLine"]];
    [self.view addSubview:_line];
    
    //最上部view
    if (iPhone4) {
        kLineMinY = 80;
        kLineMaxY = 280;
    }
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kLineMinY)];//80
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMinY, (kDeviceWidth - kReaderViewWidth) / 2.0, kReaderViewHeight)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(kDeviceWidth - CGRectGetMaxX(leftView.frame), kLineMinY, CGRectGetMaxX(leftView.frame), kReaderViewHeight)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    CGFloat space_h = KDeviceHeight - kLineMaxY;
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMaxY, kDeviceWidth, space_h)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    
    //四个边角
    UIImage *cornerImage = [UIImage imageNamed:@"ScanQR1"];
    
    //左侧的view
    UIImageView *leftView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    leftView_image.image = cornerImage;
    [self.view addSubview:leftView_image];
    
    cornerImage = [UIImage imageNamed:@"ScanQR2"];
    
    //右侧的view
    UIImageView *rightView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    rightView_image.image = cornerImage;
    [self.view addSubview:rightView_image];
    
    cornerImage = [UIImage imageNamed:@"SCanQR3"];
    
    //底部view
    UIImageView *downView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downView_image.image = cornerImage;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView_image];
    
    cornerImage = [UIImage imageNamed:@"ScanQR4"];
    
    UIImageView *downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downViewRight_image.image = cornerImage;
    //downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downViewRight_image];
    
    //说明label
    UILabel *labIntroudction = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame = CGRectMake(CGRectGetMaxX(leftView.frame) - 10, CGRectGetMinY(downView.frame) + 25, kReaderViewWidth + 20, 20);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont boldSystemFontOfSize:13.0];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"将产品二维码置于框内,即可自动扫描";
    [self.view addSubview:labIntroudction];
    
//    UIButton* btnChoosePhoto = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 -90 , labIntroudction.frame.origin.y+60, 180, 30)];
//    [btnChoosePhoto addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
//    btnChoosePhoto.titleLabel.text = @"选择相册里的二维码";
//    [btnChoosePhoto setTitle:@"选择相册里的二维码" forState:UIControlStateNormal];
//    [btnChoosePhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btnChoosePhoto.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:btnChoosePhoto];

    
    
    
    UIView *scanCropView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - 1,kLineMinY,self.view.frame.size.width - 2 * CGRectGetMaxX(leftView.frame) + 2, kReaderViewHeight + 2)];
    scanCropView.layer.borderColor = [UIColor greenColor].CGColor;
    scanCropView.layer.borderWidth = 2.0;
    [self.view addSubview:scanCropView];
}

-(void)Flashlight{
    if (self.isOpenFlash) {
        [self turnTorchOn:false];
        self.isOpenFlash = false;
        self.imgFlash.image = [UIImage imageNamed:@"flash"];
        [self.flashlight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [self turnTorchOn:true];
        self.isOpenFlash = true;
        [self.flashlight setTitleColor:Color_Bg_Line forState:UIControlStateNormal];
        self.imgFlash.image = [UIImage imageNamed:@"flash_hover"];

    }
}

#pragma mark 摄像头
- (void) turnTorchOn: (bool) on {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
//                torchIsOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
//                torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}
//-(void)closeFlashlight
//{
//    [self.AVSession stopRunning];
//}






-(void)choosePhoto{
    ZBarReaderController* controller = [[ZBarReaderController alloc]init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
    
}


- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
    self.stringCode = symbol.data;
    [self checkBinded:self.stringCode];
    [info objectForKey: UIImagePickerControllerOriginalImage];
    
    [reader dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark zBarReaderControllerDelegate
- (void)readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark 输出代理方法

//此方法是在识别到QRCode，并且完成转换
//如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描结果
    if (metadataObjects.count > 0)
    {
        [self stopSYQRCodeReading];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0)
        {
            self.stringCode = obj.stringValue;
            //检验二维码是否已经被绑定
            [self checkBinded:obj.stringValue];
            
            
            
            
        }
        else
        {
            if (self.SYQRCodeFailBlock) {
                self.SYQRCodeFailBlock(self);
            }
        }
    }
    else
    {
        if (self.SYQRCodeFailBlock) {
            self.SYQRCodeFailBlock(self);
        }
    }
}


-(void)checkBinded:(NSString*)code{
    if (!self.myCheckMock) {
        self.myCheckMock = [checkBindedMock mock];
        self.myCheckMock.delegate = self;
    }
    checkBindedParam* param = [checkBindedParam param];
    param.sendMethod = @"GET";
    UserInfo* myUserInfo = [UserInfo restore];
//    code = [code substringWithRange:NSMakeRange(8, 12)];
    self.stringCode = code;
    self.myCheckMock.operationType = [NSString stringWithFormat:@"/devices/checkIfBinded?tokenId=%@&barCode=%@",myUserInfo.tokenID,code];
    [self.myCheckMock run:param];
}

#pragma mark QUMockDelegate
-(void)QUMock:(QUMock *)mock entity:(QUEntity *)entity{
    if ([mock isKindOfClass:[checkBindedMock class]]) {
        checkBindedEntity* e = (checkBindedEntity*)entity;
        [[ViewControllerManager sharedManager]showText:e.message controller:self delay:0.5];
        if ([e.status isEqualToString:RESULT_SUCCESS]) {    //二维码未被绑定 去配网
            
            snCodeEntity* se = [snCodeEntity entity];
            se.spare = [e.DATA objectForKey:@"spare"];
            se.type = [e.DATA objectForKey:@"type"];
            se.vendor = [e.DATA objectForKey:@"vendor"];
            se.model = [e.DATA objectForKey:@"model"];
            se.idCode = [e.DATA objectForKey:@"idCode"];
            
            ConfigNetViewController* controller = [[ConfigNetViewController alloc]initWithNibName:@"ConfigNetViewController" bundle:nil];
            controller.sn= self.stringCode;
            controller.snInfoEntity = se;
            controller.macId = se.idCode;
            NSLog(@"leleron:%@",controller.sn);
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if ([e.status isEqualToString:@"EXIST"]) {
//            [self getDeviceCard];
//            [self getDeviceId];    //先获取设备id，再获取设备名片
            
            UserInfo* myUserInfo = [UserInfo restore];
            self.myRegardMock = [RegardingDeviceMock mock];
            self.myRegardMock.delegate = self;
            RegardingDeviceParam* param = [RegardingDeviceParam param];
            self.myRegardMock.operationType = [NSString stringWithFormat:@"/devices/%@/regardingDevice?tokenId=%@",e.deviceId,myUserInfo.tokenID];
                param.sendMethod = @"GET";
            [self.myRegardMock run:param];
            
//            FKDeviceCardViewController* controller = [[FKDeviceCardViewController alloc]initWithNibName:@"FKDeviceCardViewController" bundle:nil];
//            controller.deviceId = e.deviceId;
//            [self.navigationController pushViewController:controller animated:YES];
//                        //前往设备名片页
            }
        if ([e.status isEqualToString:@"NONE"]) {
            [WpCommonFunction showNotifyHUDAtViewBottom:self.view withErrorMessage:@"未查找到该设备"];
        }
        if ([e.code isEqualToString:@"116"] || [e.code isEqualToString:@"113"]) {
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"二维码无效" message:@"此二维码无效" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
                [alertController dismissViewControllerAnimated:YES completion:nil];
                [self.qrSession startRunning];
//                [self startSYQRCodeReading];
            }];
            [alertController addAction:action1];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }
    if ([mock isKindOfClass:[RegardingDeviceMock class]]) {
        RegardingDeviceEntity* e = (RegardingDeviceEntity*)entity;
        NSString* userType = [e.DeviceInfo objectForKey:@"userType"];
        if ([userType isEqualToString:@"visitor"]) {   //未绑定去名片页
            FKDeviceCardViewController* controller = [[FKDeviceCardViewController alloc]initWithNibName:@"FKDeviceCardViewController" bundle:nil];
            controller.deviceId = [e.DeviceInfo objectForKey:@"deviceId"];;
            [self.navigationController pushViewController:controller animated:YES];
        }else{     //绑定去控制页
            NSArray* dataSource = [[WHGlobalHelper shareGlobalHelper]get:USER_DEVICE_DATA];
           NSString* deviceId = [e.DeviceInfo objectForKey:@"deviceId"];
            for (NSObject* item in dataSource) {
                if ([item isKindOfClass:[CamObj class]]) {
                    CamObj* obj = (CamObj*)item;
                    if ([obj.nsDeviceId isEqual:deviceId]) {
                        VideoController* controller = [[VideoController alloc]initWithNibName:@"VideoController" bundle:nil];
                        controller.cam = obj;
                        controller.hidesBottomBarWhenPushed = YES;
                        [WpCommonFunction hideTabBar];
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                    
                }
                if ([item isKindOfClass:[AirCleanerEntity class]]) {
                    AirCleanerEntity* e = (AirCleanerEntity*)item;
                    if ([e.deviceId isEqualToString:deviceId]) {
                        AirCleanerViewController* controller = [[AirCleanerViewController alloc] initWithNibName:@"AirCleanerViewController" bundle:nil airCleaner:e];
                        controller.isReal = YES;
                        //                controller.cleaner = e;
                        controller.hidesBottomBarWhenPushed = YES;
                        [WpCommonFunction hideTabBar];
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                    
                }
            }

        }
    }
}

#pragma mark -
#pragma mark 交互事件

- (void)startSYQRCodeReading
{
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    
    [self.qrSession startRunning];
    
    NSLog(@"start reading");
}

- (void)stopSYQRCodeReading
{
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    
    [self.qrSession stopRunning];
    
    NSLog(@"stop reading");
}

//取消扫描
- (void)cancleSYQRCodeReading
{
    [self stopSYQRCodeReading];
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    if (self.SYQRCodeCancleBlock)
//    {
//        self.SYQRCodeCancleBlock(self);
//    }
    NSLog(@"cancle reading");
}


#pragma mark -
#pragma mark 上下滚动交互线

- (void)animationLine
{
    __block CGRect frame = _line.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = kLineMinY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 5;
            _line.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (_line.frame.origin.y >= kLineMinY)
        {
            if (_line.frame.origin.y >= kLineMaxY - 12)
            {
                frame.origin.y = kLineMinY;
                _line.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    
                    frame.origin.y += 5;
                    _line.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
    
    //NSLog(@"_line.frame.origin.y==%f",_line.frame.origin.y);
}




@end
