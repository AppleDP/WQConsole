//
//  WQLogView.h
//  WQConsole
//
//  Created by iOS on 17/8/21.
//  Copyright © 2017年 shenbao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WQExcuteOnMainQueue(block) [[NSThread currentThread] isMainThread] ? block() : dispatch_async(dispatch_get_main_queue(), block)

@protocol WQLogViewDelegate <NSObject>
- (void)clearClick;
- (void)hideLogClick;
- (void)recordClick;
- (void)pauseAndResumeClick:(BOOL)resume;
@end

@interface WQLogView : UIView
@property (nonatomic, weak) id<WQLogViewDelegate> delegate;
@property (nonatomic, strong) UIColor *consoleColor;
- (void)showLog:(NSMutableAttributedString *)logStr;
@end
