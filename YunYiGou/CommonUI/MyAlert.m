//
//  NetworkModel.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyAlert.h"
#import "Utils.h"

@implementation MyAlert

+(void)showMessage:(NSString *)message timer:(float)timer
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 0.7f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    [showview release];
    
    UILabel *label = [[UILabel alloc]init];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    [label release];

    CGFloat msgWdsW = MIN([Utils widthForString:message fontSize:15], window.frame.size.width);
    showview.frame = CGRectMake((window.frame.size.width - msgWdsW - 20)/2, window.frame.size.height - 100, msgWdsW+20, 20+10);
    label.frame = CGRectMake(0, 0, showview.frame.size.width, showview.frame.size.height);
    
    [UIView animateWithDuration:timer animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}

@end


