//
//  CartViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_iph.h"

@interface CartViewController_iph : BasicViewController_iph <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray*           cartDataArray;
@property (nonatomic, retain) NSMutableDictionary*      totalDataDic;
@property (nonatomic, retain) UITableView*              cartTableView;

@end