//
//  GoodsListViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "OrderListViewController_ipa.h"
#import "OrderDetailViewController_ipa.h"
#import "MyAlert.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "GoodsDetailViewController_ipa.h"
#import "OrderExpressViewController_ipa.h"
#import "MyWebViewController_ipa.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface OrderListViewController_ipa ()<EGORefreshTableDelegate,UIAlertViewDelegate>
{
    MyNetLoading*       _netLoading;
    NSString*           _clickedItemName;                   // 展示的分类名称 promote hot best category new
    NSString*           _clickedOrderID;                    // 点击订单的ID
    NSString*           _orderType;                         // 显示的订单类型 "await_pay":待付款 "await_ship":待发货 "shipped":已发货 "finished":已完成
    
    int                 _topBarH;                           // 顶边栏高度
    int                 _tableViewCellH;                    // 列表每列高度
    
    int                 _iPageNum;                          // 页码
    int                 _iCountPerPage;                     // 每页显示的条数
    
    //EGO
    EGORefreshTableHeaderView*  _refreshHeaderView;
    EGORefreshTableFooterView*  _refreshFooterView;
    BOOL                        _reloading;                 // Reloading var should really be your tableviews datasource
    
    BOOL                _isGotoPay;                         // 记录是否点击去付款 用以显示付款完成提示框
}
@end

@implementation OrderListViewController_ipa

@synthesize orderDataArray = _orderDataArray;
@synthesize paginatedDic = _paginatedDic;
@synthesize orderTableView = _orderTableView;

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
    _iPageNum = 1;
    _iCountPerPage = 10;
    _orderType = [NSString stringWithFormat:@"default"];
    
    _topBarH = 64;
    _tableViewCellH = 170;
    _orderDataArray = [[NSMutableArray alloc] init];
    _paginatedDic = [[NSMutableDictionary alloc] init];
    
    _clickedOrderID = nil;
    _isGotoPay = false;
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

    _orderTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height-_topBarH) style:UITableViewStylePlain] autorelease];
    _orderTableView.dataSource = self;
    _orderTableView.delegate = self;
    _orderTableView.separatorStyle = NO;
    [self.view addSubview:_orderTableView];
    //[_orderTableView release];
    
    // create the headerView
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _orderTableView.bounds.size.height, r.size.width, _orderTableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [_orderTableView addSubview:_refreshHeaderView];
    [_refreshHeaderView release];

    // create the footerView
    _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, _orderTableView.bounds.size.height,r.size.width, r.size.height)];
    _refreshFooterView.delegate = self;
    [_orderTableView addSubview:_refreshFooterView];
    [_refreshFooterView release];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frameR = self.view.frame;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsListCell"];
    if ( cell == nil )
    {
        [cell setFrame:CGRectMake(0, 0, frameR.size.width, _tableViewCellH)];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GoodsListCell"]autorelease];
    }
    else
    {
        for ( UIView* subView in cell.subviews )
        {
            [subView removeFromSuperview];
        }
    }
    
    NSDictionary * dic = [_orderDataArray objectAtIndex:indexPath.row];
    
    
    CGPoint relationP = CGPointMake(20, 0);
    int height = 40;
    UILabel* orderDescLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width-2*relationP.x, height)];
    [orderDescLable setText:[NSString stringWithFormat:@"订单ID：%@",[dic objectForKey:@"order_sn"]]];
    [orderDescLable setNumberOfLines:1];
    [orderDescLable setTextColor:[UIColor grayColor]];
    [orderDescLable setTextAlignment:NSTextAlignmentLeft];
    [orderDescLable setFont:[UIFont systemFontOfSize:16]];
    [cell addSubview:orderDescLable];
    [orderDescLable release];
    
    // 分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(10, height-0.5f, frameR.size.width-20, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:0.8f]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 商品列表
    relationP.y = relationP.y + height;
    height = 90;
    NSArray* goodsListArray = [dic objectForKey:@"goods_list"];
    for ( int i = 0; i < [goodsListArray count] && i < 3; i++ )
    {
        NSDictionary* goodsDic = [goodsListArray objectAtIndex:i];

        UIImageView * goodsView = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x+i*(height-5), relationP.y+10, height - 20, height - 20)];
        [goodsView setOnlineImage:goodsDic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [cell addSubview:goodsView];
        [goodsView release];
    }
    if ([goodsListArray count] == 1)
    {
        UILabel* orderDescLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x+height, relationP.y+10, frameR.size.width-(relationP.x+height)-30, height-20)];
        [orderDescLable setText:[[dic objectForKey:@"order_info"] valueForKey:@"desc"]];
        [orderDescLable setNumberOfLines:3];
        [orderDescLable setTextColor:[UIColor lightGrayColor]];
        [orderDescLable setTextAlignment:NSTextAlignmentRight];
        [orderDescLable setFont:[UIFont systemFontOfSize:13]];
        [cell addSubview:orderDescLable];
        [orderDescLable release];
    }
    
    UIImageView* rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-20, _tableViewCellH/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [cell addSubview:rightIdentify];
    [rightIdentify release];
    
    // 分割线
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(10, (relationP.y+height)-0.5f, frameR.size.width-20, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:0.8f]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 实付款
    relationP.y = relationP.y + height + 6;
    height = 30;
    NSString* amountWds = @"实付款：";
    float amountWdsW = [Utils widthForString:amountWds fontSize:16];
    UILabel* amountWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, amountWdsW, height)];
    [amountWdsLable setText:amountWds];
    [amountWdsLable setNumberOfLines:1];
    [amountWdsLable setTextColor:[UIColor grayColor]];
    [amountWdsLable setTextAlignment:NSTextAlignmentLeft];
    [amountWdsLable setFont:[UIFont systemFontOfSize:14]];
    [cell addSubview:amountWdsLable];
    [amountWdsLable release];
    
    NSString* amountFee = [dic objectForKey:@"total_fee"];
    float amountFeeW = [Utils widthForString:amountFee fontSize:13];
    UILabel* amountLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x+amountWdsW-10, relationP.y, amountFeeW+30, height)];
    [amountLable setText:amountFee];
    [amountLable setNumberOfLines:1];
    [amountLable setTextColor:[UIColor colorWithRed:255.0/255 green:60.0/255 blue:60.0/255 alpha:0.8]];
    [amountLable setTextAlignment:NSTextAlignmentLeft];
    [amountLable setFont:[UIFont systemFontOfSize:16]];
    [cell addSubview:amountLable];
    [amountLable release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, _tableViewCellH-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    if ( [_orderType compare:@"await_pay"] == NSOrderedSame )
    {
        UILabel* gotoPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        gotoPayLabel.center = CGPointMake(frameR.size.width-40-10, amountLable.center.y);
        [gotoPayLabel.layer setBackgroundColor:[UIColor grayColor].CGColor];
        [gotoPayLabel.layer setBorderColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0].CGColor];
        [gotoPayLabel.layer setCornerRadius:3.0f];
        [gotoPayLabel.layer setBorderWidth:0.5f];
        gotoPayLabel.text = @"去付款";
        gotoPayLabel.textColor = [UIColor whiteColor];
        gotoPayLabel.font = [UIFont systemFontOfSize:16];
        gotoPayLabel.userInteractionEnabled = YES;
        [gotoPayLabel setTextAlignment:NSTextAlignmentCenter];
        [cell addSubview:gotoPayLabel];
        [gotoPayLabel release];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGotoPayClicked:)];
        [gotoPayLabel addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    
    else if ( [ _orderType compare:@"await_ship"] == NSOrderedSame )
    {
        
    }
    else if ( [ _orderType compare:@"shipped"] == NSOrderedSame )
    {
        UILabel* gotoShipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 25)];
        gotoShipLabel.center = CGPointMake(frameR.size.width-35-10, amountLable.center.y);
        [gotoShipLabel.layer setBackgroundColor:[UIColor whiteColor].CGColor];
        [gotoShipLabel.layer setBorderColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0].CGColor];
        [gotoShipLabel.layer setCornerRadius:3.0f];
        [gotoShipLabel.layer setBorderWidth:0.5f];
        gotoShipLabel.text = @"确认收货";
        gotoShipLabel.textColor = [UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0];
        gotoShipLabel.font = [UIFont systemFontOfSize:13];
        gotoShipLabel.userInteractionEnabled = YES;
        [gotoShipLabel setTextAlignment:NSTextAlignmentCenter];
        [cell addSubview:gotoShipLabel];
        [gotoShipLabel release];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGotoShipClicked:)];
        [gotoShipLabel addGestureRecognizer:tapGesture];
        gotoShipLabel.tag = indexPath.row;
        [tapGesture release];
        
        UILabel* invoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 25)];
        invoiceLabel.center = CGPointMake(frameR.size.width-70-10-35-5, amountLable.center.y);
        [invoiceLabel.layer setBackgroundColor:[UIColor whiteColor].CGColor];
        [invoiceLabel.layer setBorderColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0].CGColor];
        [invoiceLabel.layer setCornerRadius:3.0f];
        [invoiceLabel.layer setBorderWidth:0.5f];
        invoiceLabel.text = @"物流查询";
        invoiceLabel.textColor = [UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0];
        invoiceLabel.font = [UIFont systemFontOfSize:13];
        invoiceLabel.userInteractionEnabled = YES;
        [invoiceLabel setTextAlignment:NSTextAlignmentCenter];
        [cell addSubview:invoiceLabel];
        [invoiceLabel release];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShippingClicked:)];
        [invoiceLabel addGestureRecognizer:tapGesture];
        invoiceLabel.tag = indexPath.row;
        [tapGesture release];
    }
    else if ( [ _orderType compare:@"finished"] == NSOrderedSame )
    {
        UIImageView* finishedStatusView = [[UIImageView alloc] initWithFrame:CGRectMake(frameR.size.width-60-10, 10, 60, 60)];
        [finishedStatusView setImage:[UIImage imageNamed:@"order_finished_status"]];
        [cell addSubview:finishedStatusView];
        [finishedStatusView release];
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_orderDataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableViewCellH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dic = [_orderDataArray objectAtIndex:indexPath.row];
    NSString* orderID = [dic objectForKey:@"order_id"];
    
    OrderDetailViewController_ipa *viewController = [[OrderDetailViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController requestOderDetail:orderID];
}

-(void)updateUI
{
    [_orderTableView reloadData];
    
    CGFloat height = MAX(_orderTableView.contentSize.height, _orderTableView.frame.size.height);
    _refreshFooterView.frame = CGRectMake(0.0f,height,_orderTableView.frame.size.width,_orderTableView.frame.size.height);
    
    if ( [[_paginatedDic objectForKey:@"more"] intValue] == 0 )
        [_refreshFooterView setHidden:YES];
    else
        [_refreshFooterView setHidden:NO];
    
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的订单";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
    [_refreshHeaderView refreshLastUpdatedDate];
    [_refreshFooterView refreshLastUpdatedDate];
    
    if ( _clickedItemName != nil )
        return;
    
    BasicViewController_ipa *basicViewController = (BasicViewController_ipa*)[navigationController topViewController];
    _orderType = basicViewController.orderType;
    
    if ( [_orderType compare:@""] == NSOrderedSame )
    {
        self.title = @"全部订单";
    }
    else if ( [_orderType compare:@"await_pay"] == NSOrderedSame )
    {
        self.title = @"待付款订单";
        
        // 验证订单付款状态
        if ( _isGotoPay && _clickedOrderID!=nil && [_clickedOrderID compare:@""]!=NSOrderedSame )
        {
            _isGotoPay = false;
            [self verifyOrderPayStatus:_clickedOrderID];
        }

    }
    else if ( [ _orderType compare:@"await_ship"] == NSOrderedSame )
    {
        self.title = @"待发货订单";
    }
    else if ( [ _orderType compare:@"shipped"] == NSOrderedSame )
    {
        self.title = @"待收货订单";
    }
    else if ( [ _orderType compare:@"finished"] == NSOrderedSame )
    {
        self.title = @"已完成订单";
    }
    else
    {
        [MyAlert showMessage:@"订单类型错误" timer:2.0f];
        return;
    }
    
    [_orderDataArray removeAllObjects];
    [self requestOrderList:_clickedItemName page:_iPageNum count:_iCountPerPage orderType:_orderType];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)finishReloadingData
{
    
    //  model should call this when its done loading
    _reloading = NO;
    
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_orderTableView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_orderTableView];
    }
    
}

//刷新调用的方法
-(void)refreshView
{
    NSLog(@"刷新完成");
    
    [self finishReloadingData];
    
}
//加载调用的方法
-(void)getNextPageView
{
    NSLog(@"加载完成");
    
    _iPageNum += 1;
    [self requestOrderList:_clickedItemName page:_iPageNum count:_iCountPerPage orderType:_orderType];
    
    [self finishReloadingData];
}

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader)
    {
        // pull down to refresh data
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:0.2];
    }else if(aRefreshPos == EGORefreshFooter)
    {
        // pull up to load more data
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:0.2];
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
    
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
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

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag == 111 )
    {
        if ( buttonIndex == 1 )
        {
            [self requestAffirmReceived];
        }
    }
    else if ( alertView.tag == 123456 )
    {
        [self requestOrderList:_clickedItemName page:_iPageNum count:_iCountPerPage orderType:_orderType];
    }
}

#pragma mark - 
#pragma on clicked event

-(void)onGotoPayClicked:(UITapGestureRecognizer*)sender
{
    NSInteger tag = sender.view.tag;
    NSDictionary * dic = [_orderDataArray objectAtIndex:tag];
    
    _isGotoPay = true;
    _clickedOrderID = [[NSString alloc] initWithString:[dic objectForKey:@"order_id"]];
    
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_PayOrder_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            NSString* payURL = nil;
            NSString* upopTn = success[@"data"][@"upop_tn"];
            NSString* payWap = success[@"data"][@"pay_wap"];
            NSString* payOnline = success[@"data"][@"pay_online"];
            
            if ( upopTn!=nil && [upopTn compare:@""]!=NSOrderedSame )
            {
                payURL = upopTn;
            }
            else if ( payWap!=nil && [payWap compare:@""]!=NSOrderedSame )
            {
                payURL = payWap;
            }
            else if ( payOnline!=nil && [payOnline compare:@""]!=NSOrderedSame )
            {
                payURL = payOnline;
            }
            
            MyWebViewController_ipa *viewController = [[MyWebViewController_ipa alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController loadHTMLString:payURL];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } orderID:_clickedOrderID];
}


// 物流查询
-(void)onShippingClicked:(UITapGestureRecognizer*)sender
{
    NSInteger tag = sender.view.tag;
    NSDictionary * dic = [_orderDataArray objectAtIndex:tag];
    
    NSString* orderID = [[NSString alloc] initWithString:[dic objectForKey:@"order_id"]];
    
    OrderExpressViewController_ipa *viewController = [[OrderExpressViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController requestOderExpress:orderID];
}

-(void)onGotoShipClicked:(UITapGestureRecognizer*)sender
{
    NSInteger tag = sender.view.tag;
    NSDictionary * dic = [_orderDataArray objectAtIndex:tag];
    
    _clickedOrderID = [[NSString alloc] initWithString:[dic objectForKey:@"order_id"]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在收到货物后再确认付款，否则可能会人财两空！" delegate:nil cancelButtonTitle:@"再等等" otherButtonTitles:@"确认收货", nil];
    alert.delegate = self;
    [alert setTag:111];
    [alert show];
    [alert release];
}


#pragma mark -
#pragma network

-(void)requestOrderList : (NSString*)clickedItemName page:(int)page count:(int)count orderType:(NSString*)orderType
{
    [orderType retain];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [_netLoading startAnimating];
    [net request_OrderList_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            // 如果返回内容为空 将页码数量减回去
            if ( [success[@"data"] count] <= 0 )
            {
                _iPageNum -= 1;
            }
            // 增加数据
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                [_orderDataArray removeAllObjects];
                [_orderDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    } page:page count:count type:orderType];
    
}

-(void)requestAffirmReceived
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [_netLoading startAnimating];
    [net request_AffirmReceived_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [MyAlert showMessage:@"操作成功" timer:2.0f];
            [self requestOrderList:_clickedItemName page:_iPageNum count:_iCountPerPage orderType:_orderType];
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    } orderID:_clickedOrderID];
}

// 验证订单支付状态
-(void)verifyOrderPayStatus:(NSString*)orderID
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_OderDetail_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            if ( [[success[@"data"] valueForKey:@"pay_status"] compare:@"2"] == NSOrderedSame )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"支付成功,请于待发货订单中查看!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert setTag:123456];
                [alert show];
                [alert release];
            }
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } orderID:orderID];
}

@end

