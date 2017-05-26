//
//  GoodsListViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "GoodsListViewController_iph.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "GoodsDetailViewController_iph.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "GoodsListTopBtnsView_iph.h"

@interface GoodsListViewController_iph ()<EGORefreshTableDelegate,GoodsListTopBtnsViewProtocol>
{
    MyNetLoading*       _netLoading;
    NSString*           _clickedItemName;                   // 展示的分类名称 promote hot best category new
    NSInteger           _clickedID;                         // 展示商品的ID （包括商品ID和分类ID）
    NSString*           _searchKeyWords;                    // 搜索的关键字
    
    int                 _topBarH;                           // 顶边栏高度
    int                 _topBtnsH;                          // 顶部按钮集合的高度
    int                 _tableViewCellH;                    // 列表每列高度
    
    int                 _iPageNum;                          // 页码
    int                 _iCountPerPage;                     // 每页显示的条数
    
    // TOP
    GoodsListTopBtnsView_iph*   _topBtnsView;
    
    //EGO
    EGORefreshTableHeaderView*  _refreshHeaderView;
    EGORefreshTableFooterView*  _refreshFooterView;
    BOOL                        _reloading;                //  Reloading var should really be your tableviews datasource
}
@end

@implementation GoodsListViewController_iph

@synthesize goodsDataArray = _goodsDataArray;
@synthesize paginatedDic = _paginatedDic;
@synthesize goodsTableView = _goodsTableView;
@synthesize sortBy = _sortBy;

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
    _sortBy = [[NSString alloc] initWithString:@"default"];
    
    _topBarH = 64;
    _topBtnsH = 30;
    _tableViewCellH = 90;
    _goodsDataArray = [[NSMutableArray alloc] init];
    _paginatedDic = [[NSMutableDictionary alloc] init];
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

    _topBtnsView = [[GoodsListTopBtnsView_iph alloc] initWithFrame:CGRectMake(0, 0, r.size.width, _topBtnsH)];
    [_topBtnsView setBackgroundColor:[UIColor whiteColor]];
    [_topBtnsView setGoodsListDelegate:self];
    [self.view addSubview:_topBtnsView];
    [_topBtnsView release];

    _goodsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, _topBtnsH, r.size.width, r.size.height-_topBarH-_topBtnsH) style:UITableViewStylePlain] autorelease];
    _goodsTableView.dataSource = self;
    _goodsTableView.delegate = self;
    _goodsTableView.separatorStyle = NO;
    [self.view addSubview:_goodsTableView];
    
    // create the headerView
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _goodsTableView.bounds.size.height, r.size.width, _goodsTableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [_goodsTableView addSubview:_refreshHeaderView];

    // create the footerView
    _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, _goodsTableView.bounds.size.height,r.size.width, r.size.height)];
    _refreshFooterView.delegate = self;
    [_goodsTableView addSubview:_refreshFooterView];
    
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
    
    NSDictionary * dic = [_goodsDataArray objectAtIndex:indexPath.row];
    
    // 商品图片
    CGPoint relationP = CGPointMake(15, 7);
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, _tableViewCellH - 15, _tableViewCellH - 15)];
    [iv setOnlineImage:dic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
    [cell addSubview:iv];
    
    // 商品名称
    relationP.x += _tableViewCellH;
    relationP.y += 6;
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width - _tableViewCellH - 15, 30)];
    [nameLabel setText:dic[@"name"]];
    [nameLabel setNumberOfLines:2];
    [nameLabel setTextColor:[UIColor colorWithRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]];
    [nameLabel setTextAlignment:NSTextAlignmentLeft];
    [nameLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:nameLabel];
    [nameLabel release];
    
    // 商品价格
    relationP.y += 50;
    NSString* goodsPriceNum = dic[@"shop_price"];
    UIColor* priceColor = [UIColor redColor];
    if( [_clickedItemName compare:@"promote"] == NSOrderedSame )
    {
        goodsPriceNum = dic[@"promote_price"];
        goodsPriceNum = [NSString stringWithFormat:@"￥%@元",goodsPriceNum];
        
        [priceColor release];
        priceColor = [UIColor blackColor];
    }
    
    UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width - _tableViewCellH - 15, 15)];
    [priceLabel setText:goodsPriceNum];
    [priceLabel setNumberOfLines:1];
    [priceLabel setTextColor:priceColor];
    [priceLabel setTextAlignment:NSTextAlignmentLeft];
    [priceLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:priceLabel];
    [priceLabel release];
    
    // 省钱金额 在商品价格之后是因为只有限时打折有省钱金额
    if( [_clickedItemName compare:@"promote"] == NSOrderedSame )
    {
        relationP.y -= 20;
        int saveMoneyNum = [dic[@"market_price"] intValue] - [dic[@"shop_price"] intValue];
        if (saveMoneyNum < 0)
            saveMoneyNum = 0;
        UILabel* saveMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, 60, 15)];
        [saveMoneyLabel setText:[NSString stringWithFormat:@"省%d元", saveMoneyNum]];
        [saveMoneyLabel.layer setCornerRadius:3];
        [saveMoneyLabel.layer setBackgroundColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0].CGColor];
        [saveMoneyLabel setNumberOfLines:1];
        [saveMoneyLabel setTextColor:[UIColor whiteColor]];
        [saveMoneyLabel setTextAlignment:NSTextAlignmentCenter];
        [saveMoneyLabel setFont:[UIFont systemFontOfSize:10]];
        [cell addSubview:saveMoneyLabel];
        [saveMoneyLabel release];
        
        // 去抢购
        relationP.y += 5;
        UILabel* snappingLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameR.size.width-20-70, relationP.y, 70, 25)];
        [snappingLabel setText:@"去抢购"];
        [snappingLabel setNumberOfLines:1];
        [snappingLabel setTextColor:[UIColor whiteColor]];
        [snappingLabel.layer setCornerRadius:4];
        [snappingLabel.layer setBackgroundColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0].CGColor];
        [snappingLabel setTextAlignment:NSTextAlignmentCenter];
        [snappingLabel setFont:[UIFont systemFontOfSize:12]];
        [cell addSubview:snappingLabel];
        [snappingLabel release];
    }
    
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
    return [_goodsDataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableViewCellH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dic = [_goodsDataArray objectAtIndex:indexPath.row];
    
    BasicViewController_iph *viewControllerList = [[GoodsDetailViewController_iph alloc] init];
    viewControllerList.iGoodsIDClicked = [dic[@"id"] intValue];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}



-(void)updateUI
{
    [_goodsTableView reloadData];
    
    CGFloat height = MAX(_goodsTableView.contentSize.height, _goodsTableView.frame.size.height);
    _refreshFooterView.frame = CGRectMake(0.0f,height,_goodsTableView.frame.size.width,_goodsTableView.frame.size.height);
    
    if ( [[_paginatedDic objectForKey:@"more"] intValue] == 0 )
        [_refreshFooterView setHidden:YES];
    else
        [_refreshFooterView setHidden:NO];
    
    return;
}

- (void)dealloc
{
    [super dealloc];
    
    [_sortBy release];
    
    [_goodsTableView release];
    
    [_refreshHeaderView release];
    [_refreshFooterView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    BasicViewController_iph *basicViewController = (BasicViewController_iph*)[navigationController topViewController];
    _clickedItemName = basicViewController.strClickedName;
    _clickedID = basicViewController.iIDClicked;
    _searchKeyWords = basicViewController.strSearchKey;
    
    if( [_clickedItemName compare:@"promote"] == NSOrderedSame )
    {
        self.title = @"限时打折";
    }
    else if ( [_clickedItemName compare:@"hot"] == NSOrderedSame )
    {
        self.title = @"热门商品";
    }
    else if( [_clickedItemName compare:@"best"] == NSOrderedSame )
    {
        self.title = @"精品推荐";
    }
    else if( [_clickedItemName compare:@"category"] == NSOrderedSame )
    {
        self.title = @"分类商品";
    }
    else if( [_clickedItemName compare:@"new"] == NSOrderedSame )
    {
        self.title = @"新品上架";
    }
    else if( [_clickedItemName compare:@"search"] == NSOrderedSame )
    {
        self.title = @"搜索";
    }
    
    [self requestData:_clickedItemName page:_iPageNum count:_iCountPerPage sort:_sortBy];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

-(void)requestData : (NSString*)clickedItemName page:(int)page count:(int)count sort:(NSString*)sort
{
    [sort retain];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    if( [clickedItemName compare:@"promote"] == NSOrderedSame )
    {
        [_netLoading startAnimating];
        [net request_List_LimitPromotionDatasuc:^(id success) {
            [_netLoading stopAnimating];
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                // 如果返回内容为空 将页码数量减回去
                if ( [success[@"data"] count] <= 0 )
                    _iPageNum -= 1;
                
                // 增加数据
                [_goodsDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        } fail:^(NSError *error) {
            [_netLoading stopAnimating];
        } page:page count:count sort:sort];
    }
    else if ( [clickedItemName compare:@"hot"] == NSOrderedSame )
    {
        [_netLoading startAnimating];
        [net request_List_HotGoodsDatasuc:^(id success) {
            [_netLoading stopAnimating];
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                // 如果返回内容为空 将页码数量减回去
                if ( [success[@"data"] count] <= 0 )
                    _iPageNum -= 1;
                
                // 增加数据
                [_goodsDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        } fail:^(NSError *error) {
            [_netLoading stopAnimating];
        } page:page count:count sort:sort];
    }
    else if( [clickedItemName compare:@"best"] == NSOrderedSame )
    {
        [_netLoading startAnimating];
        [net request_List_RecommendDatasuc:^(id success) {
            [_netLoading stopAnimating];
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                // 如果返回内容为空 将页码数量减回去
                if ( [success[@"data"] count] <= 0 )
                    _iPageNum -= 1;
                
                // 增加数据
                [_goodsDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        } fail:^(NSError *error) {
            [_netLoading stopAnimating];
        } page:page count:count sort:sort];
    }
    else if( [clickedItemName compare:@"category"] == NSOrderedSame )
    {
        [_netLoading startAnimating];
        [net request_List_CatecoryDatasuc:^(id success) {
            [_netLoading stopAnimating];
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                // 如果返回内容为空 将页码数量减回去
                if ( [success[@"data"] count] <= 0 )
                    _iPageNum -= 1;
                
                // 增加数据
                [_goodsDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        } fail:^(NSError *error) {
            [_netLoading stopAnimating];
        } page:page count:count sort:sort categoryID:_clickedID];
    }
    else if( [clickedItemName compare:@"new"] == NSOrderedSame )
    {
        [_netLoading startAnimating];
        [net request_List_NewArrivalDatasuc:^(id success) {
            [_netLoading stopAnimating];
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                // 如果返回内容为空 将页码数量减回去
                if ( [success[@"data"] count] <= 0 )
                    _iPageNum -= 1;
                
                // 增加数据
                [_goodsDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        } fail:^(NSError *error) {
            [_netLoading stopAnimating];
        } page:page count:count sort:sort];
    }
    else if( [clickedItemName compare:@"search"] == NSOrderedSame )
    {
        [_netLoading startAnimating];
        [net request_Search_Datasuc:^(id success) {
            [_netLoading stopAnimating];
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                // 如果返回内容为空 将页码数量减回去
                if ( [success[@"data"] count] <= 0 )
                    _iPageNum -= 1;
                
                // 增加数据
                [_goodsDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        } fail:^(NSError *error) {
            [_netLoading stopAnimating];
        } page:page count:count sort:sort keywords:_searchKeyWords];
    }
    
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
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_goodsTableView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_goodsTableView];
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
    [self requestData:_clickedItemName page:_iPageNum count:_iCountPerPage sort:_sortBy];
    
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
#pragma mark GoodsListTopBtnsDelegate
- (void)onDefaultClicked
{
    _sortBy = [NSString stringWithFormat:@"default"];
    _iPageNum = 1;
    
    [_goodsDataArray removeAllObjects];
    
    [self requestData:_clickedItemName page:_iPageNum count:_iCountPerPage sort:_sortBy];
}
- (void)onSalesDescClicked
{
    _sortBy = [NSString stringWithFormat:@"sales_desc"];
    _iPageNum = 1;
    
    [_goodsDataArray removeAllObjects];
    
    [self requestData:_clickedItemName page:_iPageNum count:_iCountPerPage sort:_sortBy];
}
- (void)onPriceAscClicked
{
    _sortBy = [NSString stringWithFormat:@"price_asc"];
    _iPageNum = 1;
    
    [_goodsDataArray removeAllObjects];
    
    [self requestData:_clickedItemName page:_iPageNum count:_iCountPerPage sort:_sortBy];
}
- (void)onPriceDescClicked
{
    _sortBy = [NSString stringWithFormat:@"price_desc"];
    _iPageNum = 1;
    
    [_goodsDataArray removeAllObjects];
    
    [self requestData:_clickedItemName page:_iPageNum count:_iCountPerPage sort:_sortBy];
}

@end

