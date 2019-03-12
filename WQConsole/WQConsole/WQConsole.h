//
//  WQConsole.h
//  WQConsole
//
//  Created by iOS on 17/8/21.
//  Copyright © 2017年 shenbao. All rights reserved.
//

#import "WQLogView.h"

#ifndef WQConsoleCtrl
#define WQConsoleCtrl [WQConsole shareInstance]
#endif

#if DEBUG
    // DEBUG
    #define WQColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
    #define WQLogDef(FORMAT,...) [WQConsoleCtrl logWithColor:nil \
                                                       level:kWQLogDef \
                                                        file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        line:__LINE__ \
                                                      thread:[NSThread currentThread] \
                                                     message:(FORMAT), ## __VA_ARGS__]
    #define WQLogErr(FORMAT,...) [WQConsoleCtrl logWithColor:WQColor(255,0,0) \
                                                       level:kWQLogErr \
                                                        file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        line:__LINE__ \
                                                      thread:[NSThread currentThread] \
                                                     message:(FORMAT), ## __VA_ARGS__]
    #define WQLogWar(FORMAT,...) [WQConsoleCtrl logWithColor:WQColor(213,184,109) \
                                                       level:kWQLogWar \
                                                        file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        line:__LINE__ \
                                                      thread:[NSThread currentThread] \
                                                     message:(FORMAT), ## __VA_ARGS__]
    #define WQLogInf(FORMAT,...) [WQConsoleCtrl logWithColor:WQColor(32,102,235) \
                                                       level:kWQLogInf \
                                                        file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        line:__LINE__ \
                                                      thread:[NSThread currentThread] \
                                                     message:(FORMAT), ## __VA_ARGS__]
    #define WQLogMes(FORMAT,...) [WQConsoleCtrl logWithColor:WQColor(127,255,0) \
                                                       level:kWQLogMes \
                                                        file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        line:__LINE__ \
                                                      thread:[NSThread currentThread] \
                                                     message:(FORMAT), ## __VA_ARGS__]
    #define WQLogOth(FORMAT,...) [WQConsoleCtrl logWithColor:WQColor(186,0,255) \
                                                       level:kWQLogOth \
                                                        file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                        line:__LINE__ \
                                                      thread:[NSThread currentThread] \
                                                     message:(FORMAT), ## __VA_ARGS__]
#else
    // Release
    #define WQLogDef(FORMAT,...) {}
    #define WQLogErr(FORMAT,...) {}
    #define WQLogWar(FORMAT,...) {}
    #define WQLogInf(FORMAT,...) {}
    #define WQLogMes(FORMAT,...) {}
    #define WQLogOth(FORMAT,...) {}
#endif

typedef enum {
    /** 默认日志，输出到控制台与文件 */
    kWQLogDef,
    /** 信息日志，输出到控制台与文件 */
    kWQLogInf,
    /** 错误日志，输出到控制台与文件 */
    kWQLogErr,
    /** 警告日志，输出到控制台与文件 */
    kWQLogWar,
    /** 信息日志2，输出到控制台与文件 */
    kWQLogMes,
    /** 自定义日志，发布时不输出到控制台，只输出到日志文件 */
    kWQLogOth,
}WQLogLevel;

NS_ASSUME_NONNULL_BEGIN
@interface WQConsole : NSObject
/** 控制台颜色 */
@property (nonatomic, strong, nullable) UIColor *consoleColor;
/** 日志字体 */
@property (nonatomic, assign) UIFont *font;
+ (instancetype)shareInstance;
- (void)openViewLog;


/**
 内部日志获取函数，不用理会
 */
- (void)logWithColor:(nullable UIColor *)color
               level:(WQLogLevel)level
                file:(NSString *)file
                line:(int)line
              thread:(NSThread *)thread
             message:(NSString *)log,...;
@end
NS_ASSUME_NONNULL_END
