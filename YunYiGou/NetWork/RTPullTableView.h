//
//  RTPullTableView.h
//  PullVIew
//
//  Created by Sharon on 14-8-11.
//  Copyright (c) 2014年 OuyangRenshuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTPullTableView;
@protocol RTPullTableViewDelegate <NSObject>

@optional
- (void)RTPullTableViewDidTriggerRefresh:(RTPullTableView *)RTTableView;
- (void)RTPullTableViewDidTriggerMore:(RTPullTableView *)RTTableView;
@end

@interface RTPullTableView : UITableView

@property (nonatomic,assign) id<RTPullTableViewDelegate>pullDelegate;

- (void)setIsHeader:(BOOL)isHeader andIsFooter:(BOOL)isFooter;
- (void)RTPullTableViewDidFinishLoad;

@end
