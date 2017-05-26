//
//  RTPullFooterView.h
//  PullVIew
//
//  Created by Sharon on 14-8-11.
//  Copyright (c) 2014年 OuyangRenshuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTPullFooterView;

@protocol RTPullFooterViewDelegate <NSObject>

- (void)pullFooterViewDidTriggerLoadMore:(RTPullFooterView*)footView;

@end


@interface RTPullFooterView : UIView

@property (nonatomic,assign) id<RTPullFooterViewDelegate>delegate;

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)startAnimatingWithScrollView:(UIScrollView *)scrollView;
- (void)setBackgroundColor:(UIColor *)backgroundColor
                 textColor:(UIColor *)textColor
                arrowImage:(UIImage *)arrowImage;

@end
