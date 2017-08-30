//
//  ViewController.m
//  WQConsole
//
//  Created by iOS on 17/8/21.
//  Copyright © 2017年 shenbao. All rights reserved.
//

#import "ViewController.h"
#import "WQConsole.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 50, 50);
    btn.center = self.view.center;
    [btn setTitle:@"Log"
         forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(startLog:)
  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)startLog:(UIButton *)sender {
    NSAssert(0, @"崩溃信息");
    sender.enabled = NO;
    [sender setTintColor:[UIColor grayColor]];
    __block int index = 0;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          WQLogMes(@"第%d次",index ++);
                                      }];
}
@end
