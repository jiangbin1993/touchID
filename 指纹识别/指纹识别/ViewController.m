//
//  ViewController.m
//  指纹识别
//
//  Created by 斌 on 2017/7/13.
//  Copyright © 2017年 斌. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()
//本地认证上下文联系对象
@property(nonatomic,strong) LAContext * context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark 方式一
- (IBAction)login1:(id)sender {
    //本地认证上下文联系对象，每次使用指纹识别验证功能都要重新初始化，否则会一直显示验证成功。
    self.context = [[LAContext alloc] init];
    NSError * error = nil;
    //验证是否具有指纹认证功能
    BOOL canEvaluatePolicy = [_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    if (canEvaluatePolicy) {
        NSLog(@"有指纹认证功能");
        
        // 指纹认证错误后的第二个按钮文字（不写默认为“输入密码”）
        _context.localizedFallbackTitle = @"芝麻开门";
        
        // 调用指纹验证
        [self beginTouchId1];
        
    } else {
        NSLog(@"无指纹认证功能");
    }
}


// 开始指纹验证
- (void)beginTouchId1{
    [_context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"验证指纹以确认您的身份" reply:^(BOOL success, NSError *error) {
        
        // 切换到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                NSLog(@"指纹验证成功");
            } else {
                NSLog(@"指纹认证失败，%@",error.description);
                NSLog(@"%ld", (long)error.code);
                // 错误码 error.code
                switch (error.code) {
                        
                    case LAErrorUserCancel: { NSLog(@"用户取消验证Touch ID");// -2 在TouchID对话框中点击了取消按钮或者按了home键
                    }
                        break;
                        
                    case LAErrorUserFallback: {
                        
                        NSLog(@"用户选择输入密码"); // -3 在TouchID对话框中点击了输入密码按钮
                    }
                        break;
                        
                    case LAErrorSystemCancel: { NSLog(@"取消授权，如其他应用切入，用户自主"); // -4 TouchID对话框被系统取消，例如按下电源键
                    }
                        break;
                        
                    case LAErrorPasscodeNotSet: {
                        NSLog(@"设备系统未设置密码"); // -5
                    }
                        break;
                        
                    case LAErrorTouchIDNotAvailable: {
                        
                        NSLog(@"设备未设置Touch ID"); // -6
                    }
                        break;
                        
                    case LAErrorTouchIDNotEnrolled:  {
                        
                        NSLog(@"用户未录入指纹"); // -7
                    }
                        break;
                        
                    case LAErrorAppCancel: {
                        NSLog(@"用户不能控制情况下APP被挂起"); // -9
                    }
                        break;
                        
                    case LAErrorInvalidContext: {
                        
                        NSLog(@"LAContext传递给这个调用之前已经失效"); // -10
                    }
                        break;
                        
                    default: {
                        NSLog(@"其他情况");
                    }
                        break;
                }
            }
        });
    }];
}

#pragma mark 方式二
- (IBAction)login2:(id)sender {
    //本地认证上下文联系对象，每次使用指纹识别验证功能都要重新初始化，否则会一直显示验证成功。
    self.context = [[LAContext alloc] init];
    NSError * error = nil;
    //验证是否具有指纹认证功能
    BOOL canEvaluatePolicy = [_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    
    if (canEvaluatePolicy) {
        NSLog(@"有指纹认证功能");
        
        // 指纹认证错误后的第二个按钮文字（不写默认为“输入密码”）
        _context.localizedFallbackTitle = @"芝麻开门";
        
        // 调用指纹验证
        [self beginTouchId];
        
    } else {
        NSLog(@"无指纹认证功能");
        // 没有指纹认证功能有可能是输入错误次数达到5次，认证功能被锁导致。
        BOOL isLock = (BOOL)[[NSUserDefaults standardUserDefaults] objectForKey:@"touchIdIsLocked"];
        if (isLock) {
            // 认证被锁处理
            [self touchIdIsLocked];
        }
    }
}



// 开始指纹验证
- (void)beginTouchId{
    [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"验证指纹以确认您的身份" reply:^(BOOL success, NSError *error) {
        
        // 切换到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                NSLog(@"指纹验证成功");
            } else {
                NSLog(@"指纹认证失败，%@",error.description);
                NSLog(@"%ld", (long)error.code);
                // 错误码 error.code
                switch (error.code) {
                    case LAErrorAuthenticationFailed:{
                        NSLog(@"授权失败"); // -1 连续三次指纹识别错误
                    }
                        break;
                        
                    case LAErrorUserCancel: { NSLog(@"--用户取消验证Touch ID");// -2 在TouchID对话框中点击了取消按钮或者按了home键
                    }
                        break;
                        
                    case LAErrorUserFallback: {
                        
                        NSLog(@"用户选择输入密码"); // -3 在TouchID对话框中点击了输入密码按钮,在这里可以做一些自定义的操作。
                    }
                        break;
                        
                    case LAErrorSystemCancel: { NSLog(@"取消授权，如其他应用切入，用户自主"); // -4 TouchID对话框被系统取消，例如按下电源键
                    }
                        break;
                        
                    case LAErrorPasscodeNotSet: {
                        NSLog(@"设备系统未设置密码"); // -5
                    }
                        break;
                        
                    case LAErrorTouchIDNotAvailable: {
                        
                        NSLog(@"设备未设置Touch ID"); // -6
                    }
                        break;
                        
                    case LAErrorTouchIDNotEnrolled:  {
                        
                        NSLog(@"用户未录入指纹"); // -7
                    }
                        break;
                        
                    case LAErrorTouchIDLockout: {
                        // -8 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
                        NSLog(@"Touch ID被锁，需要用户输入系统密码解锁");
                        // 往本地用户偏好设置里把touchIdIsLocked标识设置为yes，表示指纹识别被锁
                        [[NSUserDefaults standardUserDefaults] setObject:@(YES)forKey:@"touchIdIsLocked"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self touchIdIsLocked];
                    }
                        break;
                        
                    case LAErrorAppCancel: {
                        NSLog(@"用户不能控制情况下APP被挂起"); // -9
                    }
                        break;
                        
                    case LAErrorInvalidContext: {
                        
                        NSLog(@"LAContext传递给这个调用之前已经失效"); // -10
                    }
                        break;
                        
                    default: {
                        NSLog(@"其他情况");
                    }
                        break;
                }
            }
        });
    }];
}


// 指纹验证被锁后调用输入密码解锁
- (void)touchIdIsLocked{
    [_context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"验证密码" reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"验证成功");
            // 把本地标识改为NO，表示指纹解锁解除锁定
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"touchIdIsLocked"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            NSLog(@"验证失败");
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
