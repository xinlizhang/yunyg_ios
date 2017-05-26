//
//  NetworkModel.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "MyNetLoading.h"


@interface MyNetLoading()
{
    UIActivityIndicatorView*    _activityIndicator;
}
@end

@implementation MyNetLoading

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [_activityIndicator setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicator stopAnimating];
        
        [self addSubview:_activityIndicator];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    [_activityIndicator release];
}

-(void)startAnimating
{
    [_activityIndicator startAnimating];
}

-(void)stopAnimating
{
    [_activityIndicator stopAnimating];
}


@end


