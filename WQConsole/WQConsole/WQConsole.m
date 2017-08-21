//
//  WQConsole.m
//  WQConsole
//
//  Created by iOS on 17/8/21.
//  Copyright © 2017年 shenbao. All rights reserved.
//

#import "WQConsole.h"
#import "WQLogView.h"

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
@property (nonatomic, copy) NSMutableAttributedString *logStr;
@property (nonatomic, weak) WQLogView *logView;
@property (nonatomic, weak) UIButton *logBtn;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIPanGestureRecognizer *gesture;
@property (nonatomic, assign) BOOL isShowLog;
@property (nonatomic, assign) BOOL isPauseLog;
@end

@implementation WQConsole
static WQConsole *share;
+ (WQConsole *)shareInstance {
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
    UIWindow *window;
    if (!_window) {
        window = [UIWindow new];
    }
    _window = window;
    [_window makeKeyAndVisible];
    _window.frame = CGRectMake(WQMainWidth - WQOrignSize,
                               WQMainHeight/2.0 - WQOrignSize/2.0,
                               WQOrignSize,
                               WQOrignSize);
    _window.windowLevel = UIWindowLevelStatusBar + 1;
    _window.backgroundColor = [UIColor grayColor];
    _window.layer.cornerRadius = WQOrignSize/2.0;
    _window.layer.masksToBounds = YES;
    
    // view layout
    UIButton *logBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logBtn.frame = _window.bounds;
    logBtn.layer.cornerRadius = _window.layer.cornerRadius;
    [logBtn setTitle:@"日志"
            forState:UIControlStateNormal];
    [logBtn setTitleColor:[UIColor whiteColor]
                 forState:UIControlStateNormal];
    [logBtn addTarget:self
               action:@selector(logControl:)
     forControlEvents:UIControlEventTouchUpInside];
    [_window addSubview:logBtn];
    _logBtn = logBtn;
    
    WQLogView *logView = [[WQLogView alloc] initWithFrame:CGRectMake(0, 0, WQMainWidth, WQShowHeight)];
    logView.hidden = YES;
    logView.consoleColor = _consoleColor;
    logView.delegate = self;
    [_window addSubview:logView];
    _logView = logView;
    
    // add gesture
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(panGesture:)];
    [_window addGestureRecognizer:gesture];
    _gesture = gesture;
}

- (void)log:(UIColor *)color
       file:(NSString *)file
       line:(int)line
     thread:(NSThread *)thread
        log:(NSString *)log,... {
    @autoreleasepool {
        if (log) {
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            formater.dateFormat = @"yyy-MM-dd HH:mm:ss.SSS";
            NSString *date = [formater stringFromDate:[NSDate date]];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = ((NSString *)[infoDictionary objectForKey:@"CFBundleDisplayName"]).length != 0 ? [infoDictionary objectForKey:@"CFBundleDisplayName"] : [infoDictionary objectForKey:@"CFBundleName"];
            va_list list;
            NSString *threadName = [[NSThread currentThread] isMainThread] ? @"Main" : ([[NSThread currentThread].name  isEqual: @""] ? @"Child" : [NSThread currentThread].name);
            va_start(list, log);
            NSString *msg = [[NSString alloc] initWithFormat:log
                                                   arguments:list];
            NSLog(@"%@",msg);
            va_end(list);
            NSString *logStr = [NSString stringWithFormat:@"%@ %@ >> >> >> 文件: %@ -- 行号: %d -- 线程: %@ -- 日志: %@ << << <<\n",
                                date,
                                appName,
                                file,
                                line,
                                threadName,
                                msg];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:logStr];
            if (color) {
                [attrStr addAttribute:NSForegroundColorAttributeName
                                value:color
                                range:NSMakeRange(0, logStr.length)];
            }
            @synchronized (_logStr) {
                if (!_logStr) {
                    _logStr = [[NSMutableAttributedString alloc] init];
                }
                [_logStr appendAttributedString:attrStr];
                if (_isShowLog && !_isPauseLog) {
                    [_logView showLog:_logStr];
                }
            }
        }
    }
}

#pragma mark -- WQLogViewDelegate
- (void)hideLogClick {
    // 隐藏日志输出页面
    _isShowLog = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         _window.frame = CGRectMake(WQMainWidth - WQOrignSize,
                                                    WQMainHeight/2.0 - WQOrignSize/2.0,
                                                    WQOrignSize,
                                                    WQOrignSize);
                         _window.backgroundColor = [UIColor grayColor];
                         _window.layer.cornerRadius = WQOrignSize/2.0;
                         _logView.hidden = YES;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _logBtn.hidden = NO;
                         }
                     }];
}

- (void)recordClick {
    // 记录到文件
    @synchronized (_logStr) {
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
        NSData *logData = [((NSMutableAttributedString *)[_logStr copy]).string dataUsingEncoding:NSUTF8StringEncoding];
        [logData writeToFile:path
                  atomically:YES];
        NSLog(@"文件路径: %@",path);
    }
}

- (void)pauseAndResumeClick:(BOOL)resume {
    if (resume) {
        // 开始输出日志
        _isPauseLog = NO;
    }else {
        // 暂停输出日志
        _isPauseLog = YES;
    }
}

- (void)clearClick {
    // 添除日志
    @synchronized (_logStr) {
        _logStr = [[NSMutableAttributedString alloc] init];
        [_logView showLog:_logStr];
    }
}

#pragma mark -- 打开日志页面
- (void)logControl:(UIButton *)sender {
    // show the logView and hide the logBtn and window`s cornerRadius to 0 backgroundColor to white
    [UIView animateWithDuration:0.5
                     animations:^{
                         _window.frame = CGRectMake(0, WQMainHeight - WQShowHeight, WQMainWidth, WQShowHeight);
                         _window.layer.cornerRadius = 0;
                         _window.backgroundColor = [UIColor grayColor];
                         _logBtn.hidden = YES;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _window.backgroundColor = [UIColor clearColor];
                             _logView.hidden = NO;
                             _isShowLog = YES;
                             [_logView showLog:_logStr];
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
                         _window.center = point;
                     }];
}

#pragma mark -- Set 方法
- (void)setConsoleColor:(UIColor *)consoleColor {
    _consoleColor = consoleColor;
    _logView.consoleColor = consoleColor;
}
@end