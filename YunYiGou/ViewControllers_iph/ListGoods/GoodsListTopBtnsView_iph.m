//
//  HotGoodsView_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "GoodsListTopBtnsView_iph.h"
#import "UIImageView+OnlineImage.h"


@interface GoodsListTopBtnsView_iph ()
{

}
@end


@implementation GoodsListTopBtnsView_iph

@synthesize goodsListDelegate = _goodsListDelegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _curOrderMode = ENUM_ORDER_DEFAULT;

        [self initUI];
    }
    return self;
}

- (void)initUI
{
    UIView * seprator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
    [seprator setBackgroundColor:[UIColor colorWithRed:230.0f/255 green:230.0f/255 blue:230.0f/255 alpha:1.0f]];
    [self addSubview:seprator];
    [seprator release];
    
    seprator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/4, 8, 0.5f, self.frame.size.height-16)];
    [seprator setBackgroundColor:[UIColor colorWithRed:230.0f/255 green:230.0f/255 blue:230.0f/255 alpha:1.0f]];
    [self addSubview:seprator];
    [seprator release];
    seprator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width*2/4, 8, 0.5f, self.frame.size.height-16)];
    [seprator setBackgroundColor:[UIColor colorWithRed:230.0f/255 green:230.0f/255 blue:230.0f/255 alpha:1.0f]];
    [self addSubview:seprator];
    [seprator release];
    seprator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width*3/4, 8, 0.5f, self.frame.size.height-16)];
    [seprator setBackgroundColor:[UIColor colorWithRed:230.0f/255 green:230.0f/255 blue:230.0f/255 alpha:1.0f]];
    [self addSubview:seprator];
    [seprator release];
    
    // 默认
    _defaultWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, self.frame.size.height)];
    [_defaultWdsLabel setCenter:CGPointMake(self.frame.size.width/8, self.frame.size.height/2)];
    [_defaultWdsLabel setText:NSLocalizedString(@"默认", nil)];
    [_defaultWdsLabel setTextColor:[UIColor redColor]];
    [self addSubview:_defaultWdsLabel];
    [_defaultWdsLabel setFont:[UIFont systemFontOfSize:16]];

    _defaultWdsLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDefaultBtnClicked:)];
    [_defaultWdsLabel addGestureRecognizer:tapGesture];
    [tapGesture release];
    [_defaultWdsLabel release];
    
    // 销量降序
    _salesDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, self.frame.size.height)];
    [_salesDescLabel setCenter:CGPointMake(self.frame.size.width*3/8, self.frame.size.height/2)];
    [_salesDescLabel setText:NSLocalizedString(@"销量", nil)];
    [_salesDescLabel setTextColor:[UIColor grayColor]];
    [self addSubview:_salesDescLabel];
    [_salesDescLabel setFont:[UIFont systemFontOfSize:16]];
    
    _salesDescLabel.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSalesDescBtnClicked:)];
    [_salesDescLabel addGestureRecognizer:tapGesture];
    [tapGesture release];
    [_salesDescLabel release];
    
    // 价格升序
    _priceAscLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, self.frame.size.height)];
    [_priceAscLabel setCenter:CGPointMake(self.frame.size.width*5/8, self.frame.size.height/2)];
    [_priceAscLabel setText:NSLocalizedString(@"最便宜", nil)];
    [_priceAscLabel setTextColor:[UIColor grayColor]];
    [self addSubview:_priceAscLabel];
    [_priceAscLabel setFont:[UIFont systemFontOfSize:16]];
    
    _priceAscLabel.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPriceAscBtnClicked:)];
    [_priceAscLabel addGestureRecognizer:tapGesture];
    [tapGesture release];
    [_priceAscLabel release];
    
    // 价格降序
    _priceDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, self.frame.size.height)];
    [_priceDescLabel setCenter:CGPointMake(self.frame.size.width*7/8, self.frame.size.height/2)];
    [_priceDescLabel setText:NSLocalizedString(@"最贵", nil)];
    [_priceDescLabel setTextColor:[UIColor grayColor]];
    [self addSubview:_priceDescLabel];
    [_priceDescLabel setFont:[UIFont systemFontOfSize:16]];
    
    _priceDescLabel.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPriceDescBtnClicked:)];
    [_priceDescLabel addGestureRecognizer:tapGesture];
    [tapGesture release];
    [_priceDescLabel release];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)onDefaultBtnClicked:(id)sender
{
    if ( _curOrderMode == ENUM_ORDER_DEFAULT )
        return;
    
    _curOrderMode = ENUM_ORDER_DEFAULT;
    
    [_defaultWdsLabel setTextColor:[UIColor redColor]];
    [_salesDescLabel setTextColor:[UIColor grayColor]];
    [_priceAscLabel setTextColor:[UIColor grayColor]];
    [_priceDescLabel setTextColor:[UIColor grayColor]];
    
    if ( _goodsListDelegate )
        [_goodsListDelegate onDefaultClicked];
}

- (void)onSalesDescBtnClicked:(id)sender
{
    if ( _curOrderMode == ENUM_ORDER_SALES_DESC )
        return;
    
    _curOrderMode = ENUM_ORDER_SALES_DESC;
    
    [_defaultWdsLabel setTextColor:[UIColor grayColor]];
    [_salesDescLabel setTextColor:[UIColor redColor]];
    [_priceAscLabel setTextColor:[UIColor grayColor]];
    [_priceDescLabel setTextColor:[UIColor grayColor]];
    
    if ( _goodsListDelegate )
        [_goodsListDelegate onSalesDescClicked];
}

- (void)onPriceAscBtnClicked:(id)sender
{
    if ( _curOrderMode == ENUM_ORDER_PRICE_ASC )
        return;
    
    _curOrderMode = ENUM_ORDER_PRICE_ASC;
    
    [_defaultWdsLabel setTextColor:[UIColor grayColor]];
    [_salesDescLabel setTextColor:[UIColor grayColor]];
    [_priceAscLabel setTextColor:[UIColor redColor]];
    [_priceDescLabel setTextColor:[UIColor grayColor]];
    
    if ( _goodsListDelegate )
        [_goodsListDelegate onPriceAscClicked];
}

- (void)onPriceDescBtnClicked:(id)sender
{
    if ( _curOrderMode == ENUM_ORDER_PRICE_DESC )
        return;
    
    _curOrderMode = ENUM_ORDER_PRICE_DESC;
    
    [_defaultWdsLabel setTextColor:[UIColor grayColor]];
    [_salesDescLabel setTextColor:[UIColor grayColor]];
    [_priceAscLabel setTextColor:[UIColor grayColor]];
    [_priceDescLabel setTextColor:[UIColor redColor]];
    
    if ( _goodsListDelegate )
        [_goodsListDelegate onPriceDescClicked];
}

@end
