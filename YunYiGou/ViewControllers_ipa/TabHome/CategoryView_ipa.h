//
//  CategoryView_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CategoryViewProtocal_ipa <NSObject>

@required
-(void)onCategoryViewViewClickedAtIndex:(NSInteger)index;

@end


@interface CategoryView_ipa : UIView
{
    NSMutableArray * _dataArr;
}

@property (nonatomic, assign) id<CategoryViewProtocal_ipa> cateDelegate;

-(void)updateWithDataArray:(NSMutableArray*)dvataArray;                 // 刷新数据

-(void)OnClickedGoods:(id)sender;                                       // 点击处理

@end
