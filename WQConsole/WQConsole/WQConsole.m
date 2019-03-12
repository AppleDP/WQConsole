//
//  WQConsole.m
//  WQConsole
//
//  Created by iOS on 17/8/21.
//  Copyright © 2017年 shenbao. All rights reserved.
//

#import "WQConsole.h"

#ifndef WQMainWidth
#define WQMainWidth CGRectGetWidth([[UIScreen mainScreen] bounds])
#endif
#ifndef WQMainHeight
#define WQMainHeight CGRectGetHeight([[UIScreen mainScreen] bounds])
#endif
#ifndef WQOrignSize
#define WQOrignSize 50
#endif
#ifndef WQShowHeight
#define WQShowHeight WQMainHeight/3
#endif

@interface WQConsole ()
<
    WQLogViewDelegate
>
@property (nonatomic, strong) NSMutableAttributedString *logStr;
@property (nonatomic, weak) WQLogView *logView;
@property (nonatomic, weak) UIButton *logBtn;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) BOOL isShowLog;
@property (nonatomic, assign) BOOL isPauseLog;
@end

@implementation WQConsole
static WQConsole *share;
+ (instancetype)shareInstance {
    @synchronized (share) {
        if (share == nil) {
            share = [[WQConsole alloc] init];
        }
    }
    return share;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized (share) {
        if (share == nil) {
            share = [super allocWithZone:zone];
        }
    }
    return share;
}

- (void)openViewLog {
    WQExcuteOnMainQueue(^{
        UIWindow *window;
        if (!self.window) {
            window = [UIWindow new];
        }
        self.window = window;
        [self.window makeKeyAndVisible];
        self.window.frame = CGRectMake(WQMainWidth - WQOrignSize,
                                       WQMainHeight/2.0 - WQOrignSize/2.0,
                                       WQOrignSize,
                                       WQOrignSize);
        self.window.windowLevel = UIWindowLevelStatusBar + 1;
        self.window.backgroundColor = [UIColor grayColor];
        self.window.layer.cornerRadius = WQOrignSize/2.0;
        self.window.layer.masksToBounds = YES;
        
        // view layout
        UIButton *logBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        logBtn.frame = self.window.bounds;
        logBtn.layer.cornerRadius = self.window.layer.cornerRadius;
        [logBtn setTitle:@"日志"
                forState:UIControlStateNormal];
        [logBtn setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        [logBtn addTarget:self
                   action:@selector(logControl:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.window addSubview:logBtn];
        self.logBtn = logBtn;
        
        WQLogView *logView = [[WQLogView alloc] initWithFrame:CGRectMake(0, 0, WQMainWidth, WQShowHeight)];
        logView.hidden = YES;
        logView.consoleColor = self.consoleColor;
        logView.delegate = self;
        [self.window addSubview:logView];
        self.logView = logView;
        
        // add gesture
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(panGesture:)];
        [self.window addGestureRecognizer:gesture];
        
        // 崩溃信息监听
        [self listenCrashMessage];
    });
}

- (void)listenCrashMessage {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

void uncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *crashStr = [NSString stringWithFormat:@"*** Terminating app due to uncaught exception `%@`, reason: `%@` \n*** First throw call stack:\n%@",
                          name,reason,arr];
    @synchronized (share.logStr) {
        [share.logStr appendAttributedString:[[NSAttributedString alloc] initWithString:crashStr]];
    }
    [share recordClick];
}

- (void)logWithColor:(UIColor *)color
               level:(WQLogLevel)level
                file:(NSString *)file
                line:(int)line
              thread:(NSThread *)thread
             message:(NSString *)log,... {
    @autoreleasepool {
        if (log) {
            va_list list;
            va_start(list, log);
            NSString *msg = [[NSString alloc] initWithFormat:log
                                                   arguments:list];
            va_end(list);
            NSString *levelStr = @"";
            NSString *headerStr = @"";
            NSString *footerStr = @"";
            switch (level) {
                    case kWQLogDef:
                    levelStr = @"WQDef";
                    headerStr = @">> >> >>";
                    footerStr = @"<< << <<";
                    break;
                    case kWQLogInf:
                    levelStr = @"WQInf";
                    headerStr = @">> >> >>";
                    footerStr = @"<< << <<";
                    break;
                    case kWQLogErr:
                    levelStr = @"WQErr";
                    headerStr = @">> ## >>";
                    footerStr = @"<< ## <<";
                    break;
                    case kWQLogWar:
                    levelStr = @"WQWar";
                    headerStr = @">> !! >>";
                    footerStr = @"<< !! <<";
                    break;
                    case kWQLogMes:
                    levelStr = @"WQMes";
                    headerStr = @">> ** >>";
                    footerStr = @"<< ** <<";
                    break;
                    case kWQLogOth:
                    levelStr = @"WQOth";
                    headerStr = @">> $$ >>";
                    footerStr = @"<< $$ <<";
                    break;
                    
                default:
                    levelStr = @"Unknow";
                    headerStr = @">> ?? >>";
                    footerStr = @"<< ?? <<";
                    break;
            }
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            formater.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            NSString *date = [formater stringFromDate:[NSDate date]];
            NSString *queueName = [NSString stringWithUTF8String:dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
            NSString *threadName = [[NSThread currentThread] isMainThread] ? @"Main" : ([NSThread currentThread].name.length == 0 ? (queueName.length != 0 ? queueName : @"Child") : [NSThread currentThread].name);
            NSString *logStr = [NSString stringWithFormat:@"%@ 文件: %@ --- 线程: %@ --- 类型: %@[%d]: %@ %@",
                                headerStr,
                                file,
                                threadName,
                                levelStr,
                                line,
                                msg,
                                footerStr];
#ifndef NSLog
            NSLog(@"%@",logStr);
            logStr = [date stringByAppendingFormat:@" %@",logStr];
            logStr = [logStr stringByAppendingString:@"\n"];
#else
            logStr = [date stringByAppendingFormat:@" %@",logStr];
            logStr = [logStr stringByAppendingString:@"\n"];
            printf("%s",logStr.UTF8String);
#endif
            if (!color) {
                // 没有为字体设置颜色，如果控制台前背景色小于 387 则日志字体色为白色
                int r = 0, g = 0, b = 0;
                if (self.consoleColor) {
                    const CGFloat *components = CGColorGetComponents(self.consoleColor.CGColor);
                    r = components[0]*255;
                    g = components[1]*255;
                    b = components[2]*255;
                    if (r + g + b < 387) {
                        color = [UIColor whiteColor];
                    }else {
                        color = [UIColor blackColor];
                    }
                }else {
                    // 没有设置控制台背景色时，默认为黑色
                    color = [UIColor blackColor];
                }
            }
            if (!self.logStr) {
                self.logStr = [[NSMutableAttributedString alloc] init];
            }
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:logStr];
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:color
                            range:NSMakeRange(0, logStr.length)];
            NSShadow *fontShadow = [[NSShadow alloc] init];
            fontShadow.shadowColor = color;
            [attrStr addAttribute:NSShadowAttributeName
                            value:fontShadow
                            range:NSMakeRange(0, logStr.length)];
            @synchronized (self.logStr) {
                [attrStr addAttribute:NSFontAttributeName
                                value:self.font
                                range:NSMakeRange(0, logStr.length)];
                [self.logStr appendAttributedString:attrStr];
                if (self.isShowLog && !self.isPauseLog) {
                    [self.logView showLog:self.logStr];
                }
            }
        }
    }
}

#pragma mark -- WQLogViewDelegate
- (void)hideLogClick {
    // 隐藏日志输出页面
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.window.frame = CGRectMake(WQMainWidth - WQOrignSize,
                                                    WQMainHeight/2.0 - WQOrignSize/2.0,
                                                    WQOrignSize,
                                                    WQOrignSize);
                         self.window.backgroundColor = [UIColor grayColor];
                         self.window.layer.cornerRadius = WQOrignSize/2.0;
                         self.logView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.logView.alpha = 1.0;
                             self.logView.hidden = YES;
                             self.logBtn.hidden = NO;
                             self.isShowLog = NO;
                         }
                     }];
}

- (void)recordClick {
    // 记录到文件
    @synchronized (self.logStr) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask,
                                                              YES) firstObject];
        path = [path stringByAppendingPathComponent:@"WQConsole"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createDirectoryAtPath:path
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
            if (error) {
                WQLogErr(@"文件夹创建错误: %@",error);
            }
        }
        path = [path stringByAppendingPathComponent:@"WQConsoleLog.log"];
        if ([fileManager fileExistsAtPath:path]) {
            // 删除原文件
            NSError *err;
            [fileManager removeItemAtPath:path error:&err];
            if (err) {
                WQLogErr(@"文件删除错误: %@",err);
            }
        }
        NSData *logData = [self.logStr.string dataUsingEncoding:NSUTF8StringEncoding];
        if ([logData writeToFile:path atomically:YES]) {
            WQLogMes(@"日志保存到文件: %@",path);
        }
    }
}

- (void)pauseAndResumeClick:(BOOL)resume {
    if (resume) {
        // 开始输出日志
        self.isPauseLog = NO;
        @synchronized (self.logStr) {
            [self.logView showLog:self.logStr];
        }
    }else {
        // 暂停输出日志
        self.isPauseLog = YES;
    }
}

- (void)clearClick {
    // 添除日志
    @synchronized (self.logStr) {
        @synchronized (self.logStr) {
            self.logStr = [[NSMutableAttributedString alloc] init];
            [self.logView showLog:self.logStr];
        }
    }
}

#pragma mark -- 打开日志页面
- (void)logControl:(UIButton *)sender {
    // show the logView and hide the logBtn and window`s cornerRadius to 0 backgroundColor to white
    self.logView.hidden = NO;
    self.logView.alpha = 0.0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.window.frame = CGRectMake(0, WQMainHeight - WQShowHeight, WQMainWidth, WQShowHeight);
                         self.window.layer.cornerRadius = 0;
                         self.window.backgroundColor = [UIColor whiteColor];
                         self.logBtn.hidden = YES;
                         self.logView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.isShowLog = YES;
                             @synchronized (self.logStr) {
                                 if (!self.isPauseLog) {
                                     [self.logView showLog:self.logStr];
                                 }
                             }
                         }
                     }];
}

#pragma mark -- 移动手势
- (void)panGesture:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:[[UIApplication sharedApplication] delegate].window];
    CGFloat wWidth = CGRectGetWidth(_window.frame);
    CGFloat wHeight = CGRectGetHeight(_window.frame);
    if (point.x + wWidth/2.0 >= WQMainWidth) {
        point.x = WQMainWidth - wWidth/2.0;
    }
    if (point.x - wWidth/2.0 <= 0) {
        point.x = wWidth/2.0;
    }
    if (point.y + wHeight/2.0 >= WQMainHeight) {
        point.y = WQMainHeight - wHeight/2.0;
    }
    if (point.y - wHeight/2.0 <= 0) {
        point.y = wHeight/2.0;
    }
    switch (sender.state) {
        case UIGestureRecognizerStateEnded:{
            if (WQMainWidth - point.x > point.x) {
                // 靠左
                point.x = wWidth/2.0;
            }else {
                // 靠右
                point.x = WQMainWidth - wWidth/2.0;
            }
        }break;
        default:{
        }break;
    }
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.window.center = point;
                     }];
}

#pragma mark -- Set 方法
- (void)setConsoleColor:(UIColor *)consoleColor {
    _consoleColor = consoleColor;
    WQExcuteOnMainQueue(^{
        self.logView.consoleColor = consoleColor;
    });
}

- (UIFont *)font {
    if (_font == nil) {
        _font = [UIFont systemFontOfSize:12];
    }
    return _font;
}
@end
