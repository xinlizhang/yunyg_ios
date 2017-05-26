//
//  NewArrivalView_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NewArrivalViewProtocal_iph <NSObject>

@required
-(void)onNewArrivalViewClickedAtIndex:(NSInteger)index;

@end


@interface NewArrivalView_iph : UIView
{
@public
    NSMutableArray * _dataArr;
    
    UILabel * _titleLabel;
}

@property (nonatomic, assign) id<NewArrivalViewProtocal_iph> arrivalDelegate;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;

-(void)drawSeperator;

-(void)OnClickedGoods:(id)sender;

@end

