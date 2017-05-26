//
//  RecommendView_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecommendViewProtocol_ipa <NSObject>

@required
-(void)onRecommendViewClickedAtIndex:(NSInteger)index;

@end

@interface RecommendView_ipa : UIView
{
@public
    NSMutableArray * _dataArr;
    
    UIScrollView * _scrollView;
    
    UILabel * _titleLabel;
    
    UIButton * _topRightButton;
}

@property (nonatomic, assign) id<RecommendViewProtocol_ipa> recommendDelegate;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;

-(void)OnClickedGoods:(id)sender;

@end
