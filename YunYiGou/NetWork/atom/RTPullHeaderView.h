//
//  RTPullHeaderView.h
//  PullVIew
//
//  Created by Sharon on 14-8-11.
//  Copyright (c) 2014年 OuyangRenshuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTPullHeaderView;

@protocol RTPullHeaderViewDelegate <NSObject>

- (void)pullHeaderViewDidTriggerRefresh:(RTPullHeaderView *)headerView;

@optional
- (NSDate *)pullHeaderViewLastUpdated:(RTPullHeaderView *)headerView;

@end


@interface RTPullHeaderView : UIView

@property (nonatomic,assign) id<RTPullHeaderViewDelegate>delegate;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView;
- (void)setBackgroundColor:(UIColor *)backgroundColor
                 textColor:(UIColor *) textColor
                arrowImage:(UIImage *) arrowImage;


@end
