//
//  CartViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_ipa.h"

@interface OrderAddrMngViewController_ipa : BasicViewController_ipa <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray*           addrDataArray;
@property (nonatomic, retain) UITableView*              addrTableView;

@end