//
//  RTPullTableView.m
//  PullVIew
//
//  Created by Sharon on 14-8-11.
//  Copyright (c) 2014年 OuyangRenshuang. All rights reserved.
//

#import "RTPullTableView.h"
#import "MessageInterceptor.h"
#import "RTPullHeaderView.h"
#import "RTPullFooterView.h"

@interface RTPullTableView() <UIScrollViewDelegate,RTPullHeaderViewDelegate,RTPullFooterViewDelegate>
{
    MessageInterceptor *_delegateIntercepter;
    RTPullHeaderView *_headerView;
    RTPullFooterView *_footerView;
    BOOL _isHeader;
    BOOL _isFooter;
    
}

@property (nonatomic,strong) NSDate *lastRefreshDate;
@property (nonatomic,assign) BOOL isRefreshing;
@property (nonatomic,assign) BOOL isLoadingMore;

- (void)config;

@end

@implementation RTPullTableView
@synthesize pullDelegate = _pullDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setIsHeader:(BOOL)isHeader andIsFooter:(BOOL)isFooter
{
    _isHeader = isHeader;
    _isFooter = isFooter;
    [self config];
}

- (void)config
{
    if (_headerView || _footerView) {
        if (_headerView) {
            [_headerView setHidden:!_isHeader];
        }
        if (_footerView) {
            [_footerView setHidden:!_isFooter];
        }
        return;
    }
    
    _delegateIntercepter = [[MessageInterceptor alloc] init];
    _delegateIntercepter.middleMan = self;
    _delegateIntercepter.receiver = self.delegate;
    super.delegate = (id)_delegateIntercepter;
    
    self.isRefreshing = NO;
    self.isLoadingMore = NO;
    
    CGRect r = self.bounds;
    r = self.frame;
    

    _headerView = [[RTPullHeaderView alloc]initWithFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _headerView.delegate = self;
    if (_isHeader){
        [self addSubview:_headerView];
    }



    _footerView = [[RTPullFooterView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _footerView.delegate = self;
    if (_isFooter){
        [self addSubview:_footerView];
    }


    
}
- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    
    if(_delegateIntercepter) {
        super.delegate = nil;
        _delegateIntercepter.receiver = delegate;
        super.delegate = (id)_delegateIntercepter;
    } else {
        super.delegate = delegate;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    CGRect loadMoreFrame = _footerView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    _footerView.frame = loadMoreFrame;
    
}

- (void)reloadData
{
    [super reloadData];
    [_footerView egoRefreshScrollViewDidScroll:self];
}


#pragma mark--
#pragma PullView-State

- (void)setIsRefreshing:(BOOL)isRefreshing
{
    if(!_isRefreshing && isRefreshing) {

        [_headerView startAnimatingWithScrollView:self];
        _isRefreshing = YES;
    } else if(_isRefreshing && !isRefreshing) {
        [_headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        _isRefreshing = NO;
    }
    
}
- (void)setIsLoadingMore:(BOOL)isLoadingMore
{
    if(!_isLoadingMore && isLoadingMore) {
        [_footerView startAnimatingWithScrollView:self];
        _isLoadingMore = YES;
    } else if(_isLoadingMore && !isLoadingMore) {
        [_footerView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        _isLoadingMore = NO;
    }
}

- (void)setLastRefreshDate:(NSDate *)lastRefreshDate{
    if (lastRefreshDate!= self.lastRefreshDate){
        self.lastRefreshDate = [lastRefreshDate copy];
        lastRefreshDate = nil;
        [_headerView refreshLastUpdatedDate];
    }
}

#pragma mark--
#pragma ScrollView-Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    if (_isHeader){
        [_headerView egoRefreshScrollViewDidScroll:scrollView];
    }
    if (_isFooter){
        [_footerView egoRefreshScrollViewDidScroll:scrollView];

    }

    
    if ([_delegateIntercepter.receiver respondsToSelector:@selector(scrollViewDidScroll:)]){
        [_delegateIntercepter.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isHeader){
        [_headerView egoRefreshScrollViewWillBeginDragging:scrollView];
    }
    if ([_delegateIntercepter.receiver respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [_delegateIntercepter.receiver scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    
    if (_isHeader){
        [_headerView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if (_isFooter){
        [_footerView egoRefreshScrollViewDidEndDragging:scrollView];

    }

    if ([_delegateIntercepter.receiver respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        [_delegateIntercepter.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }

}


#pragma mark - EGORefreshTableHeaderDelegate

- (void)pullHeaderViewDidTriggerRefresh:(RTPullHeaderView *)headerView
{
    
    self.isRefreshing = YES;
    if ([_pullDelegate respondsToSelector:@selector(RTPullTableViewDidTriggerRefresh:)]){
        [_pullDelegate RTPullTableViewDidTriggerRefresh:self];
    }
    
}

- (void)pullFooterViewDidTriggerLoadMore:(RTPullFooterView *)footView
{
    self.isLoadingMore = YES;
    if ([_pullDelegate respondsToSelector:@selector(RTPullTableViewDidTriggerMore:)]){
        [_pullDelegate RTPullTableViewDidTriggerMore:self];
    }
    
}

- (NSDate *)pullHeaderViewLastUpdated:(RTPullHeaderView *)headerView
{
    return self.lastRefreshDate;
}

- (void)RTPullTableViewDidFinishLoad
{
    [self setIsLoadingMore:NO];
    [self setIsRefreshing:NO];
}

@end
