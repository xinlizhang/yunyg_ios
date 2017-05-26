//
//  LimitPromotionView_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "LimitPromotionView_iph.h"
#import "UIImageView+OnlineImage.h"
#import "MZTimerLabel.h"

@interface LimitPromotionView_iph ()
{
    MZTimerLabel*   _timerLabel;
}
@end

@implementation LimitPromotionView_iph

@synthesize promoteDelegate = _promoteDelegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _dataArr = [[NSMutableArray alloc] init];
        
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    CGRect r = self.frame;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
    [self addSubview: _scrollView];
    [_scrollView release];
    
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setBounces:NO];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 70, 16)];
    [_titleLabel setText:NSLocalizedString(@"限时打折", nil)];
    [_titleLabel setTextColor:[UIColor redColor]];
    [self addSubview:_titleLabel];
    [_titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_titleLabel release];
    
    _timerLabel = [[MZTimerLabel alloc] initWithTimerType:MZTimerLabelTypeTimer];
    _timerLabel.frame = CGRectMake(15+70, 15, 100, 16);
    _timerLabel.timeLabel.font = [UIFont systemFontOfSize:15];
    _timerLabel.timeLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_timerLabel];
    [_timerLabel pause];
    
    _topRightButton = [[UIButton alloc] initWithFrame:CGRectMake(r.size.width - 20 - 140, 15, 140, 15)];
    [_topRightButton addTarget:self action:@selector(onTopRightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_topRightButton setTitle:NSLocalizedString(@"每日新鲜天天秒", nil) forState:UIControlStateNormal];
    [self addSubview:_topRightButton];
    [_topRightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_topRightButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_topRightButton.titleLabel setTextColor:[UIColor darkGrayColor]];
    [_topRightButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_topRightButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [_topRightButton release];
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(r.size.width - 20, 18, 10, 10)];
    [btn setImage:[UIImage imageNamed:@"home_btn_godetail"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onTopRightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    [btn release];
}

- (void)dealloc
{
    [super dealloc];
    
    [_dataArr release];
}

-(void)updateWithDataArray:(NSMutableArray*)dataArray
{
    [_dataArr removeAllObjects];
    for ( UIView* subView in self.subviews )
    {
        [subView removeFromSuperview];
    }
    
    [_dataArr addObjectsFromArray:dataArray];
    
    [self initUI];
    
    NSDictionary* firstGoodsDic = _dataArr[0];
    int iMinPromoteEndTime = [[firstGoodsDic valueForKey:@"promote_end_date"] intValue];
    
    CGRect r = self.frame;
    int offset = 90;
    for (int i = 0; i < [_dataArr count]; i ++) {
        NSDictionary * dic = _dataArr[i];
        
        if ( [[dic valueForKey:@"promote_end_date"] intValue] < iMinPromoteEndTime )
            iMinPromoteEndTime = [[dic valueForKey:@"promote_end_date"] intValue];
        
        CGPoint p = CGPointMake(45 + offset * i, 85);
        UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, offset - 15, offset - 15)];
        [iv setOnlineImage:dic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [iv setCenter:p];
        [iv setTag:[dic[@"id"] intValue]];
        [_scrollView addSubview:iv];

        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnClickedGoods:)];
        [iv addGestureRecognizer:singleTap1];
        [singleTap1 release];
        [iv release];
        
        p.y += 50;
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, offset, 15)];
        [lbl setText:[NSString stringWithFormat:@"￥%@",dic[@"promote_price"]]];
        [lbl setCenter:p];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setFont:[UIFont systemFontOfSize:12]];
        [lbl setTextColor:[UIColor blackColor]];
        [_scrollView addSubview:lbl];
        [lbl release];
        
        //竖分割线
        if (i) {
            p.x = offset * i;
            p.y = 85;
            UIView * seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, offset-15)];
            [seperator setBackgroundColor:[UIColor lightGrayColor]];
            [seperator setCenter:p];
            [_scrollView addSubview:seperator];
            [seperator release];
        }

    }
    
    [_scrollView setContentSize:CGSizeMake(offset * [_dataArr count], r.size.height)];
    
    int now = [[NSDate date] timeIntervalSince1970];
    [_timerLabel setCountDownTime:(iMinPromoteEndTime - now)];
    [_timerLabel setShouldCountBeyondHHLimit:YES];
    [_timerLabel start];
}

-(void)OnClickedGoods:(id)sender;
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSInteger iID = tap.view.tag;
    [_promoteDelegate onLimitPromotionViewClickedAtIndex:iID];
}

-(void)onTopRightButtonClicked:(id)sender
{
    
}

@end
