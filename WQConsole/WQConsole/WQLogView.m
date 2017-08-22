//
//  WQLogView.m
//  WQConsole
//
//  Created by iOS on 17/8/21.
//  Copyright © 2017年 shenbao. All rights reserved.
//

#import "WQLogView.h"

@interface WQLogView ()
<
    UITextViewDelegate
>
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, assign) BOOL autoShow;
@end

@implementation WQLogView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        CGFloat fWidth = CGRectGetWidth(frame);
        CGFloat fHeight = CGRectGetHeight(frame);
        _autoShow = YES;
        
        // view layout
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        hideBtn.frame = CGRectMake(5, 0, 30, 20);
        [hideBtn setTitle:@"隐藏"
                 forState:UIControlStateNormal];
        hideBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [hideBtn addTarget:self
                    action:@selector(hideLogClick:)
          forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hideBtn];
        
        UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        recordBtn.frame = CGRectMake(CGRectGetMaxX(hideBtn.frame) + 5, 0, 30, 20);
        [recordBtn setTitle:@"记录"
                   forState:UIControlStateNormal];
        recordBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [recordBtn addTarget:self
                      action:@selector(recordClick:)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:recordBtn];
        
        UIButton *pauseAndResumeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        pauseAndResumeBtn.frame = CGRectMake(CGRectGetMaxX(recordBtn.frame) + 5, 0, 30, 20);
        [pauseAndResumeBtn setTitle:@"暂停"
                           forState:UIControlStateNormal];
        [pauseAndResumeBtn setTitle:@"开始"
                           forState:UIControlStateSelected];
        pauseAndResumeBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [pauseAndResumeBtn addTarget:self
                              action:@selector(pauseAndResumeClick:)
                    forControlEvents:UIControlEventTouchUpInside];
        [pauseAndResumeBtn setBackgroundImage:[UIImage new]
                                     forState:UIControlStateSelected];
        [self addSubview:pauseAndResumeBtn];
        
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearBtn.frame = CGRectMake(fWidth - 5 - 30, 0, 30, 20);
        [clearBtn setTitle:@"清除"
                  forState:UIControlStateNormal];
        clearBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [clearBtn addTarget:self
                     action:@selector(clearClick:)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearBtn];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20,fWidth,fHeight - 20)];
        textView.editable = NO;
        textView.delegate = self;
        int r = 0, g = 0, b = 0;
        if (_consoleColor) {
            const CGFloat *components = CGColorGetComponents(_consoleColor.CGColor);
            r = components[0]*255;
            g = components[1]*255;
            b = components[2]*255;
            if (r + g + b < 387) {
                // 页面偏黑时滚动条为白色
                _textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
            }else {
                // 页面偏白时滚动条为黑色
                _textView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
            }
        }
        [self addSubview:textView];
        _textView = textView;
    }
    return self;
}

- (void)showLog:(NSMutableAttributedString *)logStr {
    // 在主线程执行页面更新操作
    _textView.attributedText = logStr;
    if (_autoShow) {
        [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];
    }
}

- (void)setConsoleColor:(UIColor *)consoleColor {
    _consoleColor = consoleColor;
    _textView.backgroundColor = consoleColor;
    int r = 0, g = 0, b = 0;
    if (consoleColor) {
        const CGFloat *components = CGColorGetComponents(consoleColor.CGColor);
        r = components[0]*255;
        g = components[1]*255;
        b = components[2]*255;
        if (r + g + b < 387) {
            _textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        }else {
            _textView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        }
    }
}

#pragma mark Btn Click
- (void)clearClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(clearClick)]) {
        [_delegate clearClick];
    }
    _autoShow = YES;
}

- (void)hideLogClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(hideLogClick)]) {
        [_delegate hideLogClick];
    }
}

- (void)pauseAndResumeClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(pauseAndResumeClick:)]) {
        [_delegate pauseAndResumeClick:sender.selected];
    }
    _autoShow = sender.selected;
    sender.selected = !sender.selected;
}

- (void)recordClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(recordClick)]) {
        [_delegate recordClick];
    }
}

#pragma mark UITextViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    CGPoint offset = scrollView.contentOffset;
    CGSize size = scrollView.contentSize;
    if (offset.y >= size.height - CGRectGetHeight(_textView.frame)) {
        _autoShow = YES;
    }else {
        _autoShow = NO;
    }
}
@end
