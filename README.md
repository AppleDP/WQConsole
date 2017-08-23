# WQConsole
在App运行页面打印控制台日志<br/>

<p align="center">
  <img src="https://github.com/AppleDP/WQConsole/blob/master/EffectGif/Console3x.gif" title="Effect" alt="Effect">  
</p>

# Usage
在 `-application:didFinishLaunchingWithOptions` 函数延时调用
```objective-c
    WQShareConsole.consoleColor = [UIColor blackColor];
    [WQShareConsole performSelector:@selector(openViewLog)
                         withObject:nil
                         afterDelay:0.5];
```
在 `WQConsole.h` 中可以打开 `NSLog` 函数的日志在App运行页面输出
```objective-c
    #if 1
        // 打开 NSLog 监听
        #define NSLog(FORMAT,...) [WQShareConsole log:nil \
                                                 file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
                                                 line:__LINE__ \
                                               thread:[NSThread currentThread] \
                                                  log:(FORMAT), ## __VA_ARGS__]
    #endif
```
