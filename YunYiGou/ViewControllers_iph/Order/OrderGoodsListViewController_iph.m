//
//  GoodsListViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "OrderGoodsListViewController_iph.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"


@interface OrderGoodsListViewController_iph ()
{
    UITableView*        _goodsTableView;
    
    int                 _tableViewCellH;                    // 列表每列高度
}
@end

@implementation OrderGoodsListViewController_iph

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initData];
        [self initUI];
    }
    return self;
}

-(void)initData
{
    _tableViewCellH = 110;
}

-(void)initUI
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending)
    {
        // OS version >= 7.0
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGRect r = self.view.frame;

    _goodsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height-64) style:UITableViewStylePlain] autorelease];
    _goodsTableView.dataSource = self;
    _goodsTableView.delegate = self;
    _goodsTableView.separatorStyle = NO;
    [self.view addSubview:_goodsTableView];
    //[_goodsTableView release];

}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frameR = self.view.frame;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsListCell"];
    if ( cell == nil )
    {
        [cell setFrame:CGRectMake(0, 0, frameR.size.width, 90)];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GoodsListCell"]autorelease];
    }
    else
    {
        for ( UIView* subView in cell.subviews )
        {
            [subView removeFromSuperview];
        }
    }
    
    NSArray* goodsListArray = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"goods_list"];
    NSDictionary * dic = [goodsListArray objectAtIndex:indexPath.row];
    
    // 商品图片
    CGPoint relationP = CGPointMake(15, 7);
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, _tableViewCellH - 15, _tableViewCellH - 15)];
    [iv setOnlineImage:dic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
    [cell addSubview:iv];
    
    // 商品名称
    relationP.x += _tableViewCellH;
    relationP.y += 6;
    int height = 30;
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width - _tableViewCellH - 15, height)];
    [nameLabel setText:dic[@"goods_name"]];
    [nameLabel setNumberOfLines:2];
    [nameLabel setTextColor:[UIColor colorWithRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]];
    [nameLabel setTextAlignment:NSTextAlignmentLeft];
    [nameLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:nameLabel];
    [nameLabel release];
    
    // 商品价格
    relationP.y += height + 10;
    height = 15;
    NSString* goodsPriceNum = dic[@"goods_price"];
    UIColor* priceColor = [UIColor redColor];
    UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width - _tableViewCellH - 15, height)];
    [priceLabel setText:goodsPriceNum];
    [priceLabel setNumberOfLines:1];
    [priceLabel setTextColor:priceColor];
    [priceLabel setTextAlignment:NSTextAlignmentLeft];
    [priceLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:priceLabel];
    [priceLabel release];
    
    // 商品数量
    relationP.y += height + 10;
    height = 20;
    UILabel* goodsNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, 50, height)];
    [goodsNumLabel setText:[NSString stringWithFormat:@"×%@",dic[@"goods_number"]]];
    [goodsNumLabel setNumberOfLines:1];
    [goodsNumLabel setTextColor:[UIColor grayColor]];
    [goodsNumLabel setTextAlignment:NSTextAlignmentLeft];
    [goodsNumLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:goodsNumLabel];
    [goodsNumLabel release];
    
    // 横向分割线
    relationP.x = frameR.size.width / 2;
    relationP.y = _tableViewCellH;
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width-30, 0.5)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [seperatorlINE setCenter:relationP];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"goods_list"] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableViewCellH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"商品清单";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

@end

