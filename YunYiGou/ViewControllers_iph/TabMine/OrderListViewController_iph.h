//
//  GoodsListViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicViewController_iph.h"

@interface OrderListViewController_iph : BasicViewController_iph <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, retain) NSMutableArray*       orderDataArray;
@property (nonatomic, retain) NSMutableDictionary*  paginatedDic;
@property (nonatomic, retain) UITableView*          orderTableView;

@end

