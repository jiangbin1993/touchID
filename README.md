在开始代码之前，先认识一下LAPolicy。

LAPolicy是一个枚举，有两个值

```
LAPolicyDeviceOwnerAuthenticationWithBiometrics // 用手指指纹去验证,iOS8.0以上可用
LAPolicyDeviceOwnerAuthentication // 使用TouchID或者密码验证,默认是错误三次指纹或者锁定后,弹出输入密码界面iOS 9.0以上可用
```

第一个枚举值，用户验证失败3次，会返回错误码LAErrorAuthenticationFailed，如果验证失败5次会返回错误码LAErrorTouchIDLockout并且指纹验证功能被锁。如果在系统密码验证的时候取消，下次再打开指纹验证功能会发现没有指纹验证功能。

第二个枚举值，用户验证失败3次会自动弹出系统密码验证，如果系统密码验证通过也算成功。如果在系统密码验证的时候取消，下次再打开指纹验证功能依然会验证系统密码，而不是验证指纹。


### 因为LAPolicy有两种不同类型，下面就以两种方式分别来实现指纹验证。

首先导入框架#import <LocalAuthentication/LocalAuthentication.h>

声明LAContext属性
```
//本地认证上下文联系对象
@property(nonatomic,strong) LAContext * context;
```


## 代码：

### 方式一

初始化对象，并验证是否有指纹验证功能

```
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
```

开始指纹验证

```
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
```

##### 参数解释：


**localizedFallbackTitle属性设置的是指纹验证错误后第二个按钮的文字。**

localizedFallbackTitle属性不设置或者设置为nil，第二个按钮默认标题为输入密码。


![默认标题.png](http://upload-images.jianshu.io/upload_images/2541004-fcf19aafef9a791b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



如果想自定义第二个按钮的标题，就为localizedFallbackTitle属性设置值。``_context.localizedFallbackTitle = @"芝麻开门";``


![自定义标题.png](http://upload-images.jianshu.io/upload_images/2541004-37b6baac8475549b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


如果不想有第二个按钮的话，可以把localizedFallbackTitle设置为空字符串。``_context.localizedFallbackTitle = @"";``

![没有第二个按钮.png](http://upload-images.jianshu.io/upload_images/2541004-a67b4ad9b71a484b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


 
#### 调用指纹验证功能核心代码：
```
- (void)evaluatePolicy:(LAPolicy)policy
       localizedReason:(NSString *)localizedReason
                 reply:(void(^)(BOOL success, NSError * __nullable error))reply;
```

**第一个参数policy是枚举，有两个值，详细解释看文章开头部分：**
```
LAPolicyDeviceOwnerAuthenticationWithBiometrics // 用手指指纹去验证,iOS8.0以上可用
LAPolicyDeviceOwnerAuthentication // 使用TouchID或者密码验证,默认是错误三次指纹或者锁定后,弹出输入密码界面iOS 9.0以上可用
```

**第二个参数localizedReason（验证理由）是指弹出验证框的第二个标题，可根据项目需求自定义。第一个标题不可更改。**

![验证原因.png](http://upload-images.jianshu.io/upload_images/2541004-924088b786b4bbfb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**第三个参数reply是回调处理。内含两个回调参数success和error。**
success是BOOL值，YES表示验证成功，NO表示验证失败。
error是一个枚举，总共十个错误的类型，在验证失败后返回。

```
typedef NS_ENUM(NSInteger, LAError)
{
    LAErrorAuthenticationFailed,   // -1验证信息出错，就是说你指纹不对
    LAErrorUserCancel              // -2用户取消了验证
    LAErrorUserFallback            // -3用户点击了手动输入密码的按钮，所以被取消了
    LAErrorSystemCancel            // -4被系统取消，就是说你现在进入别的应用了，不在刚刚那个页面，所以没法验证
    LAErrorPasscodeNotSet          // -5用户没有设置TouchID
    LAErrorTouchIDNotAvailable     // -6用户设备不支持TouchID
    LAErrorTouchIDNotEnrolled      // -7用户没有设置手指指纹
    LAErrorTouchIDLockout          // -8用户错误次数太多，现在被锁住了
    LAErrorAppCancel               // -9在验证中被其他app中断
    LAErrorInvalidContext          // -10请求验证出错
} NS_ENUM_AVAILABLE(10_10, 8_0);
```



>----------------------------------------我是分割线--------------------------------

## 方式二

初始化对象，并验证是否有指纹验证功能
```
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
```

开始指纹验证

```
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
```

指纹验证被锁处理

```
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
```

>-----------------------------------我是分割线---------------------------------

##### 两种方式的比较

1.方式一少了三个错误码，LAErrorUserFallback（用户选择输入密码），LAErrorAuthenticationFailed(连续三次指纹识别错误)和LAErrorTouchIDLockout（连续五次指纹识别错误，TouchID功能被锁定）。
what?没有LAErrorUserFallback（用户选择输入密码），如果用户点击了输入密码按钮会怎么办呢？不要急，这时候会自动调起输入系统密码功能的。
没有LAErrorAuthenticationFailed(连续三次指纹识别错误)和LAErrorTouchIDLockout（连续五次指纹识别错误，TouchID功能被锁定）错误码是因为在方式一中指纹验证连续错误3次就自动调起系统密码验证功能。


2.方式二在指纹验证连续错误3次的情况下会先返回错误码LAErrorAuthenticationFailed。如果有业务需求，可以在这里做一些提示或其他功能。连续错误5次会返回错误码LAErrorTouchIDLockout，此时指纹验证功能会被锁死，如果在这里不做操作，再次使用指纹验证功能就会显示无指纹验证功能。只有当手机锁屏后，再次开屏，输入系统密码才能解锁。在上面代码例子里，我在这里做了调起系统密码验证功能的操作。

3.很显然方式一比方式二更简单方便。如果没有特殊的业务需求，推荐用方式一来实现指纹识别功能。

##### 小知识：

1.指纹验证功能被锁是通用的，也就是说在一个地方指纹验证功能被锁了，在其他地方的指纹验证都会被锁起来。

2.连续5次输入系统密码错误后 会被锁一分钟

![系统密码5次错误被锁.png](http://upload-images.jianshu.io/upload_images/2541004-0c3a5693497078c5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


如果有用的话记得给我star哦！



