//
//  CategoryViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_iph.h"

@interface CateViewController_iph : BasicViewController_iph <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray*   categoryDataArray;
@property (nonatomic, retain) UITableView*      cate1stTableView;
@property (nonatomic, retain) UIScrollView*     cate2ndScrollView;

@end
