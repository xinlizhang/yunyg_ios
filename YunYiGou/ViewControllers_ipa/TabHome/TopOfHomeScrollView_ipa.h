//
//  TopOfHomeScrollView_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopOfHomeScrollViewProtocol_ipa <NSObject>

@required
    -(void)onTopOfHomeScrollViewClickAtIndex:(NSInteger)index;
    -(void)onTopOfHomeScrollViewClickAtURL:(NSString*)URL;

@end


@interface TopOfHomeScrollView_ipa : UIScrollView<UIScrollViewDelegate>
{
    NSMutableArray*     _dataArr;
    NSTimer*            _turnTimer;
}

@property (nonatomic, assign) id<TopOfHomeScrollViewProtocol_ipa> customDelegate;

@property (strong,nonatomic)UIPageControl* pageControl;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;



@end
