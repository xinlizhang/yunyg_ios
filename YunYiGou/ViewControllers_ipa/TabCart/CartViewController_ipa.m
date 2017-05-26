//
//  CartViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "CartViewController_ipa.h"
#import "UIImageView+OnlineImage.h"
#import "GoodsDetailViewController_ipa.h"
#import "OrderCheckViewController_ipa.h"
#import "EGORefreshTableHeaderView.h"
#import "MyAlert.h"

@interface CartViewController_ipa () <EGORefreshTableDelegate>
{
    int     _iTopBarH;
    int     _iTVCellH;
    int     _iTVCellTotalH;
    
    UIImageView*    _cartEmptyView;
    UILabel*        _emptyWdsLabel;
    
    UIImageView*    _cartListTopBG;
    
    MyNetLoading*   _netLoading;
    
    //EGO
    EGORefreshTableHeaderView*  _refreshHeaderView;
    BOOL                        _reloading;                //  Reloading var should really be your tableviews datasource
}
@end

@implementation CartViewController_ipa

@synthesize cartDataArray = _cartDataArray;
@synthesize totalDataDic = _totalDataDic;
@synthesize cartTableView = _cartTableView;


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initData];
        [self initUI];
        
        // 增加修改购物车商品个数的通知监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCartCount:) name:@"ShowCartCount" object:nil];
    }
    return self;
}

-(void)initData
{
    _iTopBarH = 60;
    _iTVCellH = 100;
    _iTVCellTotalH = 60;
    
    _cartDataArray = [[NSMutableArray alloc] init];
    _totalDataDic = [[NSMutableDictionary alloc] init];
}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    // 顶边栏文字
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frameR.size.width, _iTopBarH-20)];
    [nameLabel setText:@"购物车"];
    [nameLabel setNumberOfLines:1];
    [nameLabel setTextColor:[UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1]];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [nameLabel setFont:[UIFont systemFontOfSize:15]];
    //[self.view addSubview:nameLabel];
    [nameLabel release];
    
    // 购物车为空图标
    _cartEmptyView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_null_notice_bg@2x"]];
    [_cartEmptyView setCenter:CGPointMake(frameR.size.width/2, frameR.size.height/3)];
    [self.view addSubview:_cartEmptyView];
    [_cartEmptyView release];
    
    _emptyWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 20)];
    [_emptyWdsLabel setCenter:CGPointMake(frameR.size.width/2, frameR.size.height/3+80)];
    [_emptyWdsLabel setText:@"购物车肚子空空"];
    [_emptyWdsLabel setNumberOfLines:1];
    [_emptyWdsLabel setTextColor:[UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1]];
    [_emptyWdsLabel setTextAlignment:NSTextAlignmentCenter];
    [_emptyWdsLabel setFont:[UIFont systemFontOfSize:18]];
    [self.view addSubview:_emptyWdsLabel];
    [_emptyWdsLabel release];
    
    // 顶部卷纸效果的收口
    _cartListTopBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_list_top_bg"]];
    [_cartListTopBG setFrame:CGRectMake(0, 0, frameR.size.width-50, 30)];
    [_cartListTopBG setCenter:CGPointMake(frameR.size.width/2, _iTopBarH)];
    _cartListTopBG.hidden = YES;
    
    // 购物车商品列表
    int tableviewW = _cartListTopBG.frame.size.width;
    _cartTableView = [[[UITableView alloc] initWithFrame:CGRectMake((frameR.size.width-tableviewW)/2, _iTopBarH+15, tableviewW, frameR.size.height-_iTopBarH-50) style:UITableViewStylePlain] autorelease];
    //[_cartTableView setCenter:CGPointMake(frameR.size.width/2, _cartTableView.center.y)];
    [_cartTableView setBackgroundColor:[UIColor whiteColor]];
    _cartTableView.dataSource = self;
    _cartTableView.delegate = self;
    _cartTableView.separatorStyle = NO;
    _cartTableView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_cartTableView];
    //[_cartTableView release];
    
    [self.view addSubview:_cartListTopBG];
    [_cartListTopBG release];
    
    // create the headerView
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(18.0f, 0.0f - _cartTableView.bounds.size.height, _cartTableView.frame.size.width-36, _cartTableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [_cartTableView addSubview:_refreshHeaderView];
    [_refreshHeaderView release];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //if ( [DataCenter sharedDataCenter].isLogin )
        [self requestData];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowCartCount" object:nil];
}

#pragma mark - notification

- (void)changeCartCount:(id)sender
{
    NSString* cartNum = [[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"cart_num"];
    
    RDVTabBarItem *item = [self rdv_tabBarItem];
    [item setBadgeValue:cartNum];
    item.badgeTextColor = [UIColor redColor];
    item.badgeBackgroundColor = [UIColor whiteColor];
    item.badgePositionAdjustment = UIOffsetMake(-8, 0);
    
    if ( [cartNum compare:@""]==NSOrderedSame || [cartNum compare:@"0"]==NSOrderedSame )
    {
        item.badgeTextColor = [UIColor clearColor];
        item.badgeBackgroundColor = [UIColor clearColor];
    }
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frameR = self.view.frame;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsListCell"];
    CGRect cellR = CGRectMake(0, 0, tableView.frame.size.width, _iTVCellH);
    if ( cell == nil )
    {
        [cell setFrame:cellR];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GoodsListCell"]autorelease];
        cell.backgroundColor = [UIColor clearColor];
    }
    else
    {
        for ( UIView* subView in cell.subviews )
        {
            [subView removeFromSuperview];
        }
    }
    
    //[cell setTag:indexPath.row];
    
    if ( [_cartDataArray count] == indexPath.row )
    {
        cellR.size.height -= 20;
        [cell setFrame:cellR];
        
        // 最后一条数据显示总额及去结算
        UIImageView* cellBG = [[UIImageView alloc] initWithFrame:cellR];
        [cellBG setImage:[UIImage imageNamed:@"cart_list_total_bg"]];
        [cell addSubview:cellBG];
        [cellBG release];
     
        CGPoint relationP = CGPointMake(60, 10);
        // 总计文字
        UILabel* totalWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, cellR.size.width, 19)];
        [totalWdsLabel setText:@"总计："];
        [totalWdsLabel setNumberOfLines:1];
        [totalWdsLabel setBackgroundColor:[UIColor clearColor]];
        [totalWdsLabel setTextColor:[UIColor grayColor]];
        [totalWdsLabel setTextAlignment:NSTextAlignmentLeft];
        [totalWdsLabel setFont:[UIFont systemFontOfSize:18]];
        [cell addSubview:totalWdsLabel];
        [totalWdsLabel release];
        
        // 总价
        relationP.y += 28;
        UILabel* totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x-6, relationP.y, cellR.size.width, 19)];
        [totalPriceLabel setText:[_totalDataDic objectForKey:@"goods_price"]];
        [totalPriceLabel setNumberOfLines:1];
        [totalPriceLabel setBackgroundColor:[UIColor clearColor]];
        [totalPriceLabel setTextColor:[UIColor redColor]];
        [totalPriceLabel setTextAlignment:NSTextAlignmentLeft];
        [totalPriceLabel setFont:[UIFont systemFontOfSize:18]];
        [totalPriceLabel setTag:([_cartDataArray count]+1)];
        [cell addSubview:totalPriceLabel];
        [totalPriceLabel release];
        relationP.y -= 25;
        
        // 去结算
        relationP.x += cellR.size.width - 110 - 110;
        UIView* settleBG = [[UIView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, 110, 40)];
        [settleBG.layer setBackgroundColor:[UIColor colorWithRed:255.0/255 green:60.0/255 blue:60.0/255 alpha:0.8].CGColor];
        [settleBG.layer setCornerRadius:6];
        [cell addSubview:settleBG];

        settleBG.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGotoPayClicked)];
        [settleBG addGestureRecognizer:tapGesture];
        [tapGesture release];
        [settleBG release];
        
        
        int totalCount = [[_totalDataDic objectForKey:@"real_goods_count"] intValue] + [[_totalDataDic objectForKey:@"virtual_goods_count"] intValue];
        NSString* settleWds = [NSString stringWithFormat:@"去结算(%d)",totalCount];
        UILabel* settleWdsLabel = [[UILabel alloc] initWithFrame:settleBG.frame];
        [settleWdsLabel setText:settleWds];
        [settleWdsLabel setNumberOfLines:1];
        [settleWdsLabel setTextColor:[UIColor whiteColor]];
        [settleWdsLabel setCenter:settleBG.center];
        [settleWdsLabel setTextAlignment:NSTextAlignmentCenter];
        [settleWdsLabel setFont:[UIFont systemFontOfSize:18]];
        [settleWdsLabel setTag:([_cartDataArray count]+2)];
        [cell addSubview:settleWdsLabel];
        [settleWdsLabel release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    NSDictionary * dic = [_cartDataArray objectAtIndex:indexPath.row];
    
    UIImageView* cellBG = [[UIImageView alloc] initWithFrame:cellR];
    [cellBG setImage:[UIImage imageNamed:@"cart_list_bg"]];
    [cell addSubview:cellBG];
    [cellBG release];

    // 商品图片
    CGPoint relationP = CGPointMake(35, 8);
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, _iTVCellH - 15, _iTVCellH - 15)];
    [iv setOnlineImage:dic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
    [cell addSubview:iv];
    
    // 商品名称
    relationP.x += _iTVCellH;
    //relationP.y += 6;
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x-5, relationP.y, cellR.size.width - _iTVCellH - 20, 30)];
    [nameLabel setText:dic[@"goods_name"]];
    [nameLabel setNumberOfLines:2];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:[UIColor colorWithRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]];
    [nameLabel setTextAlignment:NSTextAlignmentLeft];
    [nameLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:nameLabel];
    [nameLabel release];
    
    // 商品属性
    relationP.y += 35;
    NSString* strAttri = @"";
    NSArray* goodsAttrArray = dic[@"goods_attr"];
    if ( goodsAttrArray != nil && [[goodsAttrArray class] isSubclassOfClass:[NSArray class]] )
    {
        for ( int i = 0; i < [goodsAttrArray count]; i++ )
        {
            NSDictionary* valueDic = [goodsAttrArray objectAtIndex:i];
            NSString* strValue = [valueDic valueForKey:@"value"];
            strAttri = [strAttri stringByAppendingString:[NSString stringWithFormat:@"%@  ", strValue]];
        }
        UILabel* attriLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x-5, relationP.y, cellR.size.width - _iTVCellH - 20, 18)];
        [attriLabel setText:strAttri];
        [attriLabel setNumberOfLines:1];
        [attriLabel setBackgroundColor:[UIColor clearColor]];
        [attriLabel setTextColor:[UIColor colorWithRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]];
        [attriLabel setTextAlignment:NSTextAlignmentLeft];
        [attriLabel setFont:[UIFont systemFontOfSize:12]];
        [cell addSubview:attriLabel];
        [attriLabel release];
    }
    // 商品价格
    relationP.y += 25;
    UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width - _iTVCellH - 15, 15)];
    [priceLabel setText:dic[@"goods_price"]];
    [priceLabel setNumberOfLines:1];
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    [priceLabel setTextColor:[UIColor redColor]];
    [priceLabel setTextAlignment:NSTextAlignmentLeft];
    [priceLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:priceLabel];
    [priceLabel release];
    
    // 加减选择
    relationP.x = cellR.size.width - 85 - 60;
    UIButton* reduceBtn = [[UIButton alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, 25, 25)];
    [reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_nor"] forState:UIControlStateNormal];
    [reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_sel"] forState:UIControlStateSelected];
    [reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_dis"] forState:UIControlStateDisabled];
    [reduceBtn addTarget:self action:@selector(onReduBuyCountClicked:) forControlEvents:UIControlEventTouchUpInside];
    [reduceBtn setTag:(indexPath.row+1)];
    [cell addSubview:reduceBtn];
    [reduceBtn release];
    int goodsCount = 0;
    goodsCount = [dic[@"goods_number"] intValue];
    if ( goodsCount <= 1 )
    {
        [reduceBtn setImage:[UIImage imageNamed:@"goods_del_btn_nor"] forState:UIControlStateNormal];
        [reduceBtn setImage:[UIImage imageNamed:@"goods_del_btn_sel"] forState:UIControlStateSelected];
        [reduceBtn setImage:[UIImage imageNamed:@"goods_del_btn_sel"] forState:UIControlStateDisabled];
    }
    
    UIImageView* goodsCountBG = [[UIImageView alloc] initWithFrame:CGRectMake(reduceBtn.frame.origin.x+reduceBtn.frame.size.width, relationP.y, 25+10, 25)];
    [goodsCountBG setImage:[UIImage imageNamed:@"goods_count_bg"]];
    [cell addSubview:goodsCountBG];
    [goodsCountBG release];
    
    UILabel* goodsCountLable= [[UILabel alloc] initWithFrame:goodsCountBG.frame];
    [goodsCountLable setText:[NSString stringWithFormat:@"%d",goodsCount]];
    [goodsCountLable setNumberOfLines:1];
    [goodsCountLable setBackgroundColor:[UIColor clearColor]];
    [goodsCountLable setTextColor:[UIColor blackColor]];
    [goodsCountLable setCenter:goodsCountBG.center];
    [goodsCountLable setTextAlignment:NSTextAlignmentCenter];
    [goodsCountLable setFont:[UIFont systemFontOfSize:14]];
    [goodsCountLable setTag:(indexPath.row+2)];
    [cell addSubview:goodsCountLable];
    [goodsCountLable release];
    
    UIButton* addBtn = [[UIButton alloc] initWithFrame:CGRectMake(goodsCountLable.frame.origin.x+goodsCountLable.frame.size.width, relationP.y, 25, 25)];
    [addBtn setImage:[UIImage imageNamed:@"goods_add_btn_nor"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"goods_add_btn_sel"] forState:UIControlStateSelected];
    [addBtn setImage:[UIImage imageNamed:@"goods_add_btn_dis"] forState:UIControlStateDisabled];
    [addBtn addTarget:self action:@selector(onAddBuyCountClicked:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setTag:(indexPath.row+3)];
    [cell addSubview:addBtn];
    [addBtn release];

    // 横向分割线
    UIImageView* seperatorlINE = [[UIImageView alloc] initWithFrame:CGRectMake(25, _iTVCellH, cellR.size.width-50, 1)];
    [seperatorlINE setBackgroundColor:[UIColor clearColor]];
    [seperatorlINE setImage:[UIImage imageNamed:@"common_separate_line_xu"]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];

        
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // +1 是为了显示总计cell
    return [_cartDataArray count]+1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _iTVCellH+1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ( [_cartDataArray count] <= indexPath.row )
        return;
    
    BasicViewController_ipa *viewControllerList = [[GoodsDetailViewController_ipa alloc] init];
    NSMutableDictionary * dic = [_cartDataArray objectAtIndex:indexPath.row];
    viewControllerList.iGoodsIDClicked = [dic[@"goods_id"] intValue];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)finishReloadingData
{
    
    //  model should call this when its done loading
    _reloading = NO;
    
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_cartTableView];
    }
}

//刷新调用的方法
-(void)refreshView
{
    NSLog(@"刷新完成");
    
    [self requestData];
    
    [self finishReloadingData];
    
}

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader)
    {
        // pull down to refresh data
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:0.2];
    }
    
    // overide, the actual loading data operation is done in the subclass
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
    
    [self beginToReloadData:aRefreshPos];
    
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - 各种点击事件
-(void)onGotoPayClicked
{
    NSLog(@"GoToPay!");
    BasicViewController_ipa *viewControllerList = [[OrderCheckViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

-(void)onReduBuyCountClicked:(UIButton*)sender
{
    // 通过tag获得数据在array中的索引
    NSInteger index = sender.tag - 1;
    // 修改呢商品数量
    if ( [_cartDataArray count] <= index )
        return;
    NSMutableDictionary * dic = [_cartDataArray objectAtIndex:index];
    int goodsCount = 0;
    goodsCount = [dic[@"goods_number"] intValue];
    goodsCount -= 1;
    if ( goodsCount < 1 )
    {
        // 删除提示框
        NSString *title = NSLocalizedString(@"提示", nil);
        NSString *message = NSLocalizedString(@"确定从购物车中删除该商品？", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
        }];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self requestDelGoods:[[dic objectForKey:@"rec_id"] intValue]];
        }];
        
        // Add the actions.
        [alertController addAction:cancelAction];
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }

    [dic setValue:[NSString stringWithFormat:@"%d",goodsCount] forKey:@"goods_number"];
    [self updateCellByCartID:[[dic objectForKey:@"rec_id"] intValue]];

    // net
    [self requestUpdate:index cartID:[[dic objectForKey:@"rec_id"] intValue] number:goodsCount mode:1];
}

-(void)onAddBuyCountClicked:(UIButton*)sender
{
    // 通过tag获得数据在array中的索引
    NSInteger index = sender.tag - 3;
    // 修改呢商品数量
    if ( [_cartDataArray count] <= index )
        return;
    NSMutableDictionary * dic = [_cartDataArray objectAtIndex:index];
    int goodsCount = 0;
    goodsCount = [dic[@"goods_number"] intValue];
    goodsCount += 1;
    [dic setValue:[NSString stringWithFormat:@"%d",goodsCount] forKey:@"goods_number"];
    [self updateCellByCartID:[[dic objectForKey:@"rec_id"] intValue]];
    
    // net
    [self requestUpdate:index cartID:[[dic objectForKey:@"rec_id"] intValue] number:goodsCount mode:2];
}

#pragma mark - update UI

-(void)updateUI
{
    if ( [_cartDataArray count] <= 0 )
    {
        [_cartEmptyView setHidden:NO];
        [_emptyWdsLabel setHidden:NO];
        
        [_cartListTopBG setHidden:YES];
        [_cartTableView setHidden:YES];
    }
    else
    {
        [_cartEmptyView setHidden:YES];
        [_emptyWdsLabel setHidden:YES];
        
        [_cartListTopBG setHidden:NO];
        [_cartTableView setHidden:NO];
        
        [_cartTableView reloadData];
    }
}

- (void)updateCellByCartID:(int)cartID
{
    if ( cartID == 0 )
        return;
    
    int goodsIndex = -1;
    for ( int i = 0; i < [_cartDataArray count]; i++ )
    {
        NSDictionary* dic = [_cartDataArray objectAtIndex:i];
        if ( [[dic objectForKey:@"rec_id"] intValue] == cartID )
            goodsIndex = i;
    }
    if ( goodsIndex == -1 )
        return;
    
    UITableViewCell* cell = [_cartTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:goodsIndex inSection:0]];
    if ( cell )
    {
        NSDictionary* dic = [_cartDataArray objectAtIndex:goodsIndex];
        // 显示商品数量
        UILabel* goodsCountLabel = (UILabel*)[cell viewWithTag:(goodsIndex+2)];
        if ( goodsCountLabel )
            [goodsCountLabel setText:[NSString stringWithFormat:@"%d",[dic[@"goods_number"] intValue]]];
        // 判断数量大于1时 不显示 “红叉” 删除按钮
        UIButton* reduceBtn = (UIButton*)[cell viewWithTag:(goodsIndex+1)];
        if ( reduceBtn )
        {
            if ( 1 < [dic[@"goods_number"] intValue] )
            {
                [reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_nor"] forState:UIControlStateNormal];
                [reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_sel"] forState:UIControlStateSelected];
                [reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_dis"] forState:UIControlStateDisabled];
            }
            else
            {
                [reduceBtn setImage:[UIImage imageNamed:@"goods_del_btn_nor"] forState:UIControlStateNormal];
                [reduceBtn setImage:[UIImage imageNamed:@"goods_del_btn_sel"] forState:UIControlStateSelected];
                [reduceBtn setImage:[UIImage imageNamed:@"goods_del_btn_dis"] forState:UIControlStateDisabled];
            }
        }
        
    }
}

- (void)updateTotalCell
{
    NSUInteger indexTotal = [_cartDataArray count];
    UITableViewCell* cellTotal = [_cartTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexTotal inSection:0]];
    if ( cellTotal )
    {
        UILabel* totalMoneyLabel = (UILabel*)[cellTotal viewWithTag:(indexTotal+1)];
        if ( totalMoneyLabel )
        {
            [totalMoneyLabel setText:[_totalDataDic objectForKey:@"goods_price"]];
        }
        
        UILabel* gotoPayWdsLable = (UILabel*)[cellTotal viewWithTag:(indexTotal+2)];
        if ( gotoPayWdsLable )
        {
            int totalCount = [[_totalDataDic objectForKey:@"real_goods_count"] intValue] + [[_totalDataDic objectForKey:@"virtual_goods_count"] intValue];
            NSString* settleWds = [NSString stringWithFormat:@"去结算(%d)",totalCount];
            [gotoPayWdsLable setText:settleWds];
        }
    }
}


#pragma mark - network

-(void)requestData
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_Cart_List_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        
        [_cartDataArray removeAllObjects];
        [_totalDataDic removeAllObjects];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            NSArray* jsonArray = success[@"data"][@"goods_list"];
            for ( int i = 0; i < [jsonArray count]; i++ )
            {
                NSDictionary* jsonDic = [jsonArray objectAtIndex:i];
                NSMutableDictionary* cartDic = [[NSMutableDictionary alloc] initWithDictionary:jsonDic];
                [_cartDataArray addObject:cartDic];
            }
            
            [_totalDataDic setValuesForKeysWithDictionary:success[@"data"][@"total"]];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_code"] intValue] == 100 )
        {
            [MyAlert showMessage:@"您的账号已过期，请尝试重新登陆！" timer:4.0f];
            [[DataCenter sharedDataCenter] removeLoginData];
        }
        else
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[success[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
            [alter release];
        }
        
        // 更新购物车商品数量显示
        [[DataCenter sharedDataCenter] editLoginInfo:[NSString stringWithFormat:@"%ld",[_cartDataArray count]] forKey:@"cart_num"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowCartCount" object:nil];
        
        [self updateUI];
        
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    }];
}

// mode: 1- 2+
- (void)requestUpdate:(NSUInteger)index cartID:(int)cartID number:(int)newNum mode:(int)mode
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_UpdateCart_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_totalDataDic removeAllObjects];
            [_totalDataDic setValuesForKeysWithDictionary:success[@"data"]];
                
            [self updateTotalCell];
        }
        else
        {
            NSMutableDictionary * dic = [_cartDataArray objectAtIndex:index];
            int goodsCount = 0;
            goodsCount = [dic[@"goods_number"] intValue];
            if ( mode == 1 )
                goodsCount += 1;
            else
                goodsCount -= 1;
            [dic setValue:[NSString stringWithFormat:@"%d",goodsCount] forKey:@"goods_number"];
            
            [self updateCellByCartID:cartID];
            [MyAlert showMessage:@"操作失败" timer:2.0f];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
        NSMutableDictionary * dic = [_cartDataArray objectAtIndex:index];
        int goodsCount = 0;
        goodsCount = [dic[@"goods_number"] intValue];
        if ( mode == 1 )
            goodsCount += 1;
        else
            goodsCount -= 1;
        [dic setValue:[NSString stringWithFormat:@"%d",goodsCount] forKey:@"goods_number"];
        
        [self updateCellByCartID:cartID];
        [MyAlert showMessage:@"操作失败" timer:2.0f];
        
    } cartID:cartID goodsNum:newNum ];
}

- (void)requestDelGoods:(int)cartID
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_DelToCart_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [self requestData];
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    } cartID:cartID ];
}


@end

