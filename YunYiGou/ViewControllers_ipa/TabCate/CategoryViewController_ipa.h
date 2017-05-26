//
//  CategoryViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_ipa.h"

@interface CateViewController_ipa : BasicViewController_ipa <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray*   categoryDataArray;
@property (nonatomic, retain) UITableView*      cate1stTableView;
@property (nonatomic, retain) UIScrollView*     cate2ndScrollView;

@end
