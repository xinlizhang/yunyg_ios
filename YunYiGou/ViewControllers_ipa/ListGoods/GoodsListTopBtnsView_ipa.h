//
//  HotGoodsView_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ENUM_ORDER_DEFAULT,
    ENUM_ORDER_SALES_DESC,
    ENUM_ORDER_PRICE_ASC,
    ENUM_ORDER_PRICE_DESC,
}
ENUM_ORDER_STYLE;

@protocol GoodsListTopBtnsViewProtocol <NSObject>

@required
- (void)onDefaultClicked;
- (void)onSalesDescClicked;
- (void)onPriceAscClicked;
- (void)onPriceDescClicked;
@end


@interface GoodsListTopBtnsView_ipa : UIView
{
@public

    UILabel*    _defaultWdsLabel;
    UILabel*    _salesDescLabel;
    UILabel*    _priceAscLabel;
    UILabel*    _priceDescLabel;
    
    id<GoodsListTopBtnsViewProtocol> goodsListDelegate;
    
    ENUM_ORDER_STYLE    _curOrderMode;
}

@property (nonatomic, retain) id<GoodsListTopBtnsViewProtocol> goodsListDelegate;

- (void)onDefaultBtnClicked:(id)sender;
- (void)onSalesDescBtnClicked:(id)sender;
- (void)onPriceAscBtnClicked:(id)sender;
- (void)onPriceDescBtnClicked:(id)sender;


@end
