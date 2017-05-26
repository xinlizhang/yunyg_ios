//
//  HotGoodsView_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HotGoodsViewProtocol_iph <NSObject>

@required
-(void)onHotGoodsViewClickedAtIndex:(NSInteger)index;

@end


@interface HotGoodsView_iph : UIView
{
@public
    NSMutableArray * _dataArr;
    
    UILabel * _titleLabel;
    
    id<HotGoodsViewProtocol_iph> hotDelegate;
}

@property (nonatomic, retain) id<HotGoodsViewProtocol_iph> hotDelegate;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;

-(void)drawSeperator;

-(void)OnClickedGoods:(id)sender;


@end
