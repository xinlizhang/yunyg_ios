//
//  MineViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_ipa.h"

@interface GoodsPropertiesViewController_ipa : BasicViewController_ipa <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView*      goodsPropertiesTableView;

- (void)updateUI:(NSArray*)propertiesArray;

@end
