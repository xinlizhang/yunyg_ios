//
//  TopOfHomeScrollView_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopOfHomeScrollViewProtocol_iph <NSObject>

@required
    -(void)onTopOfHomeScrollViewClickAtIndex:(NSInteger)index;
    -(void)onTopOfHomeScrollViewClickAtURL:(NSString*)URL;

@end


@interface TopOfHomeScrollView_iph : UIScrollView<UIScrollViewDelegate>
{
    NSMutableArray*     _dataArr;
    NSTimer*            _turnTimer;
}

@property (nonatomic, assign) id<TopOfHomeScrollViewProtocol_iph> customDelegate;

@property (strong,nonatomic)UIPageControl* pageControl;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;



@end
