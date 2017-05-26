//
//  TopOfHomeScrollView_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "TopOfHomeScrollView_ipa.h"
#import "UIImageView+OnlineImage.h"

@interface TopOfHomeScrollView_ipa ()
{

}
@end

@implementation TopOfHomeScrollView_ipa

@synthesize customDelegate = _customDelegate;
@synthesize pageControl = _pageControl;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        
        [self setPagingEnabled:YES];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setBounces:NO];
        
        [self setDelegate:self];
        
        _dataArr = [[NSMutableArray alloc] init];
        _turnTimer = nil;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    [_dataArr release];
}

-(void)updateWithDataArray:(NSMutableArray*)dataArray
{
    //[_dataArr release];
    _dataArr = [[NSMutableArray alloc] init];
    for ( UIView* subView in self.subviews )
    {
        [subView removeFromSuperview];
    }
    
    [_dataArr addObjectsFromArray:dataArray];
    
    CGRect r = self.frame;
    
    // 页计数器
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0,0,100,18)];
    [_pageControl setCenter:CGPointMake(r.size.width/2, r.size.height-18)];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor redColor]];
    [_pageControl setPageIndicatorTintColor:[UIColor whiteColor]];
    _pageControl.numberOfPages = [_dataArr count];
    _pageControl.currentPage = 0;
    //[_pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged];
    [self.superview addSubview:_pageControl];
    [_pageControl release];
    
    // 取数组最后一张图片 放在第0页
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
    NSString* imageURL = _dataArr[[_dataArr count]-1][@"photo"][@"url"];
    [imageView setOnlineImage:imageURL placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
    [self addSubview:imageView];
    [imageURL release];
    imageView.tag = [_dataArr count]-1;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *countMngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImgViewClicked:)];
    [imageView addGestureRecognizer:countMngTap];
    [countMngTap release];
    [imageView release];
    
    // 正常加载中间页
    for (int i = 0; i < [_dataArr count]; i ++)
    {
        NSDictionary * dic = _dataArr[i];
        UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(r.size.width * (i+1), 0, r.size.width, r.size.height)];
        [iv setOnlineImage:dic[@"photo"][@"url"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [self addSubview:iv];
        iv.tag = i;
        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *countMngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImgViewClicked:)];
        [iv addGestureRecognizer:countMngTap];
        [countMngTap release];
        [iv release];
    }
    
    // 取数组第一张图片 放在最后1页
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(r.size.width*([_dataArr count]+1), 0, r.size.width, r.size.height)];
    imageURL = _dataArr[0][@"photo"][@"url"];
    [imageView setOnlineImage:imageURL placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
    [self addSubview:imageView];
    [imageURL release];
    imageView.tag = 0;
    imageView.userInteractionEnabled = YES;
    countMngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImgViewClicked:)];
    [imageView addGestureRecognizer:countMngTap];
    [countMngTap release];
    [imageView release];
    
    
    [self setContentSize:CGSizeMake(r.size.width * ([_dataArr count] + 2), r.size.height)]; //  +上第1页和第4页  原理：4-[1-2-3-4]-1
    [self setContentOffset:CGPointMake(0, 0)];
    [self scrollRectToVisible:CGRectMake(r.size.width, 0, r.size.width, r.size.height) animated:NO]; // 默认从序号1位置放第1页 ，序号0位置位置放第4页
 
    // 定时器 循环
    if ( _turnTimer == nil )
        _turnTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
}

#pragma mark - page control
- (void)turnPage
{
    NSInteger page = _pageControl.currentPage;
    [self scrollRectToVisible:CGRectMake(self.frame.size.width*(page+1),0,self.frame.size.width,self.frame.size.width) animated:YES];
}

#pragma mark - auto change page
- (void)runTimePage
{
    NSInteger page = _pageControl.currentPage;
    if ( page == 0 )
        [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
    
    page++;
    if ( page > ([_dataArr count]-1) )
    {
        _pageControl.currentPage = 0;
        //[self setContentOffset:CGPointMake(self.frame.size.width, 0)];
        [self scrollRectToVisible:CGRectMake(self.frame.size.width*(page+1),0,self.frame.size.width,self.frame.size.width) animated:YES];
    }
    else
    {
        _pageControl.currentPage = page;
        [self scrollRectToVisible:CGRectMake(self.frame.size.width*(page+1),0,self.frame.size.width,self.frame.size.width) animated:YES];
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pagewidth = self.frame.size.width;
    CGFloat pageHeight = self.frame.size.height;
    int currentPage = floor((self.contentOffset.x-pagewidth/([_dataArr count]+2) ) / pagewidth) + 1;
    if (currentPage==0)
    {
        _pageControl.currentPage = ([_dataArr count]-1);
        [self scrollRectToVisible:CGRectMake(pagewidth * [_dataArr count],0,pagewidth,pageHeight) animated:NO]; // 序号0 最后1页
    }
    else if (currentPage==([_dataArr count]+1))
    {
        _pageControl.currentPage = 0;
        [self scrollRectToVisible:CGRectMake(pagewidth,0,pagewidth,pageHeight) animated:NO]; // 最后+1,循环第1页
    }
    else
    {
        _pageControl.currentPage = --currentPage;
    }
}

#pragma mark - on clicked events
- (void)onImgViewClicked:(UITapGestureRecognizer*)sender
{
    NSInteger tag = sender.view.tag;
    
    if ( tag < 0 || ([_dataArr count]-1) < tag )
        return;
    
    NSDictionary * dic = _dataArr[tag];
    
    [_customDelegate onTopOfHomeScrollViewClickAtURL:dic[@"url"]];
}

@end
