//
//  CartViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_ipa.h"

@interface CartViewController_ipa : BasicViewController_ipa <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray*           cartDataArray;
@property (nonatomic, retain) NSMutableDictionary*      totalDataDic;
@property (nonatomic, retain) UITableView*              cartTableView;

@end