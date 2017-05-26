//
//  GoodsListViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController_iph.h"
#import "GalleryScrollView_iph.h"


@interface GoodsDetailViewController_iph : BasicViewController_iph <UIScrollViewDelegate, GalleryScrollViewProtocol_iph>

@property (nonatomic, retain) NSMutableDictionary*      goodsDetailDic;

@end

