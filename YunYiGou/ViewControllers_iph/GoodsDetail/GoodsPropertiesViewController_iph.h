//
//  MineViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_iph.h"

@interface GoodsPropertiesViewController_iph : BasicViewController_iph <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView*      goodsPropertiesTableView;

- (void)updateUI:(NSArray*)propertiesArray;

@end
