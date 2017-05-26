//
//  GoodsListViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicViewController_ipa.h"

@interface OrderListViewController_ipa : BasicViewController_ipa <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, retain) NSMutableArray*       orderDataArray;
@property (nonatomic, retain) NSMutableDictionary*  paginatedDic;
@property (nonatomic, retain) UITableView*          orderTableView;

@end

