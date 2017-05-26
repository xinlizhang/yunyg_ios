//
//  CartViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_iph.h"

@interface OrderAddrMngViewController_iph : BasicViewController_iph <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray*           addrDataArray;
@property (nonatomic, retain) UITableView*              addrTableView;

@end