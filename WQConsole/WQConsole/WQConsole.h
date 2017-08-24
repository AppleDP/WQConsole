//
//  WQConsole.h
//  WQConsole
//
//  Created by iOS on 17/8/21.
//  Copyright © 2017年 shenbao. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef WQShareConsole
#define WQShareConsole [WQConsole shareInstance]
#endif
#ifndef WQExcuteOnMainQueue
#define WQExcuteOnMainQueue(block) !block ? : [[NSThread currentThread] isMainThread] ? block() : dispatch_async(dispatch_get_main_queue(), block)
#endif

#if DEBUG
    // DEBUG
    #define WQColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
    #define WQLogDef(FORMAT,...) [WQShareConsole log:nil \
                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                line:__LINE__ \
                                              thread:[NSThread currentThread] \
                                                 log:(FORMAT), ## __VA_ARGS__]
    #define WQLogErr(FORMAT,...) [WQShareConsole log:WQColor(255,0,0) \
                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                line:__LINE__ \
                                              thread:[NSThread currentThread] \
                                                 log:(FORMAT), ## __VA_ARGS__]
    #define WQLogWar(FORMAT,...) [WQShareConsole log:WQColor(213,184,109) \
                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                line:__LINE__ \
                                              thread:[NSThread currentThread] \
                                                 log:(FORMAT), ## __VA_ARGS__]
    #define WQLogInf(FORMAT,...) [WQShareConsole log:WQColor(32,102,235) \
                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                line:__LINE__ \
                                              thread:[NSThread currentThread] \
                                                 log:(FORMAT), ## __VA_ARGS__]
    #define WQLogMes(FORMAT,...) [WQShareConsole log:WQColor(127,255,0) \
                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                line:__LINE__ \
                                              thread:[NSThread currentThread] \
                                                 log:(FORMAT), ## __VA_ARGS__]
    #define WQLogOth(FORMAT,...) [WQShareConsole log:WQColor(186,0,255) \
                                                file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                line:__LINE__ \
                                              thread:[NSThread currentThread] \
                                                 log:(FORMAT), ## __VA_ARGS__]
    #if 0
        // 打开 NSLog 监听
        #define NSLog(FORMAT,...) [WQShareConsole log:nil \
                                                 file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                 line:__LINE__ \
                                               thread:[NSThread currentThread] \
                                                  log:(FORMAT), ## __VA_ARGS__]
    #endif
#else
    // Release
    #define WQLogDef(FORMAT,...) {}
    #define WQLogErr(FORMAT,...) {}
    #define WQLogWar(FORMAT,...) {}
    #define WQLogInf(FORMAT,...) {}
    #define WQLogMes(FORMAT,...) {}
    #define WQLogOth(FORMAT,...) {}
#endif

@interface WQConsole : NSObject
/** 控制台颜色 */
@property (nonatomic, strong) UIColor *consoleColor;
/** 日志字号 */
@property (nonatomic, assign) CGFloat fontSize;
+ (WQConsole *)shareInstance;
- (void)openViewLog;


/**
 内部日志获取函数，不用理会
 */
- (void)log:(UIColor *)color
       file:(NSString *)file
       line:(int)line
     thread:(NSThread *)thread
        log:(NSString *)log,...;
@end
