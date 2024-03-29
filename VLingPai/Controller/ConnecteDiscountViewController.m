//
//  ConnecteDiscountViewController.m
//  VLingPai
//
//  Created by Mac on 14-8-6.
//  Copyright (c) 2014年 zhcpeng. All rights reserved.
//

#import "ConnecteDiscountViewController.h"
#import "MBProgressHUD.h"
#import "ConnecteSuccessViewController.h"
#import "ScanBindAccountInterface.h"


@interface ConnecteDiscountViewController ()<MBProgressHUDDelegate,ScanBindAccountInterfaceDelegate>{
    NSTimer *timer;
}

@property (strong, nonatomic) ScanBindAccountInterface *scanBindAccountInterface;

@end

@implementation ConnecteDiscountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"关联账号";
    self.labSystemName.text = self.systemModel.systemName;
    
    self.scanBindAccountInterface = [[ScanBindAccountInterface alloc]init];
    self.scanBindAccountInterface.delegate = self;
    self.method = @"POST";
    
}

- (IBAction)btnConnectDiscountAction:(UIButton *)sender {
    [sender setTitle:@"等待电脑关联完成" forState:UIControlStateNormal];

    [self.scanBindAccountInterface scanBindAccount:self.scanResult withMethod:self.method];
}


-(void)showSuccessView{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = self;
    HUD.labelText = @"关联成功";
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
    
    [self performSelector:@selector(goSuccessView) withObject:nil afterDelay:2];
}

-(void)goSuccessView{
    ConnecteSuccessViewController *vc = [[ConnecteSuccessViewController alloc]initWithNibName:@"ConnecteSuccessViewController" bundle:nil];
    //TODO:绑定成功后的系统名称、账号信息 需要在vc里显示
//    vc.
//    vc.
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)btnCancelAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - ScanBindAccountInterfaceDelegate <NSObject>
-(void)getFinishedScanBindAccountInterfaceDelegate:(NSString *)status{
    if ([self.method isEqualToString:@"POST"]) {
        if ([status isEqualToString:@"ok"]) {
            //成功
//            [self showSuccessView];
            self.method = @"GET";
            timer = [[NSTimer alloc]initWithFireDate:[NSDate date] interval:1.0 target:self selector:@selector(getBindStatus) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            
        }else if ([status isEqualToString:@"expried"]){
            //二维码已过期
            
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark_wrong.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.delegate = self;
            HUD.labelText = @"登录失败，二维码已过期";
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
        }
    }else{
        if ([status isEqualToString:@"ok"]) {
            //成功
            [self showSuccessView];
            [timer invalidate];
            timer = nil;
        }else if ([status isEqualToString:@"waiting"]){
            //等待
            DebugLog(@"等待中...");
        }else if ([status isEqualToString:@"timeout"]){
            //绑定超时
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark_wrong.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.delegate = self;
            HUD.labelText = @"绑定超时";
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
        }
    }

}
-(void)getFailedScanBindAccountInterfaceDelegate:(NSString *)error{
    DebugLog(@"%@",error);
}

-(void)getBindStatus{
    [self.scanBindAccountInterface scanBindAccount:self.scanResult withMethod:self.method];
}
-(void)dealloc{
    self.systemModel = nil;
    self.scanResult = nil;
    self.scanBindAccountInterface.delegate = nil;
    self.scanBindAccountInterface = nil;
    self.method = nil;
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
