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
    
    WQLogDef(@"log def");
    WQLogErr(@"log err");
    WQLogInf(@"log inf");
    WQLogMes(@"log mes");
    WQLogWar(@"log war");
    WQLogOth(@"log oth");
}

- (void)startLog:(UIButton *)sender {
    static int index = 0;
    static int count = 0;
    NSString *queueLabel = [NSString stringWithFormat:@"WQConsole Queue %d",index ++];
    dispatch_queue_t queue = dispatch_queue_create(queueLabel.UTF8String, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        WQLogDef(@"第 %d 次",count ++);
        WQLogErr(@"第 %d 次",count ++);
        WQLogInf(@"第 %d 次",count ++);
        WQLogMes(@"第 %d 次",count ++);
        WQLogWar(@"第 %d 次",count ++);
        WQLogOth(@"第 %d 次",count ++);
    });
}
@end
