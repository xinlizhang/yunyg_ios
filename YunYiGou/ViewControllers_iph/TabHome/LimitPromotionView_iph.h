//
//  LimitPromotionView_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LimitPromotionViewProtocol_iph <NSObject>

@required
-(void)onLimitPromotionViewClickedAtIndex:(NSInteger)index;

@end


@interface LimitPromotionView_iph : UIView
{
    
@public
    UILabel * _hourLabel;
    
    UILabel * _minuteLabel;
    
    UILabel * _secondLabel;
    
    NSMutableArray * _dataArr;
    
    UIScrollView * _scrollView;
    
    UILabel * _titleLabel;
    
    UIButton * _topRightButton;
}

@property (nonatomic, assign) id<LimitPromotionViewProtocol_iph> promoteDelegate;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;

-(void)OnClickedGoods:(id)sender;

@end
