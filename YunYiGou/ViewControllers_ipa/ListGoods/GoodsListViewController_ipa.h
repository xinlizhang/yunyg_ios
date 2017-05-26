//
//  GoodsListViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicViewController_ipa.h"

@interface GoodsListViewController_ipa : BasicViewController_ipa <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, retain) NSMutableArray*       goodsDataArray;
@property (nonatomic, retain) NSMutableDictionary*  paginatedDic;
@property (nonatomic, retain) UITableView*          goodsTableView;
@property (nonatomic, retain) NSString*             sortBy;             // 排序方式 default:默认 sales_desc:销量降序 price_asc:价格升序 price_desc:价格降序

@end

