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
    __block int index = 0;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          WQLogWar(@"第%d次",index ++);
                                      }];
}
@end
