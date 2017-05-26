//
//  HotGoodsView_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "HotGoodsView_ipa.h"
#import "UIImageView+OnlineImage.h"


@interface HotGoodsView_ipa ()
{

}
@end


@implementation HotGoodsView_ipa

@synthesize hotDelegate = _hotDelegate;

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
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 90, 15)];
    [_titleLabel setText:NSLocalizedString(@"热门商品", nil)];
    [_titleLabel setTextColor:[UIColor redColor]];
    [self addSubview:_titleLabel];
    [_titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_titleLabel release];
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
    
    CGRect r = self.frame;
    NSArray * colorArr = @[ [UIColor redColor],
                            [UIColor blueColor],
                            [UIColor orangeColor],
                            [UIColor greenColor]
                           ];
    
    int offset = r.size.width/4;
    for ( int i = 0; i < [_dataArr count] && i < 4; i++ )
    {
        CGPoint p = CGPointMake(offset/2+offset*i, offset/2 + 35);
        NSDictionary * dic = _dataArr[i];
        
        UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, offset-15, offset-15)];
        [iv setOnlineImage:dic[@"img"][@"thumb"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [iv setCenter:p];
        [iv setTag:[dic[@"goods_id"] intValue]];
        [self addSubview:iv];
        
        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnClickedGoods:)];
        [iv addGestureRecognizer:singleTap1];
        [singleTap1 release];
        [iv release];
        
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, iv.frame.size.height-20, iv.frame.size.width, 50)];
        [lbl setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [lbl setText:dic[@"name"]];
        [lbl setTextColor:[UIColor whiteColor]];//colorArr[i%4]];
        [lbl setNumberOfLines:2];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setFont:[UIFont systemFontOfSize:15]];
        [iv addSubview:lbl];
        [lbl release];
    }

}

-(void)OnClickedGoods:(id)sender;
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSInteger iID = tap.view.tag;
    [_hotDelegate onHotGoodsViewClickedAtIndex:iID];
}

@end
