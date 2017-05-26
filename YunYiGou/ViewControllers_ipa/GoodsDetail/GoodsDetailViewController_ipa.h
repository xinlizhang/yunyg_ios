//
//  GoodsListViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController_ipa.h"
#import "GalleryScrollView_ipa.h"


@interface GoodsDetailViewController_ipa : BasicViewController_ipa <UIScrollViewDelegate, GalleryScrollViewProtocol_ipa>

@property (nonatomic, retain) NSMutableDictionary*      goodsDetailDic;

@end

