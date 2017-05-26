//
//  GoodsListViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "CollectViewController_ipa.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "GoodsDetailViewController_ipa.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface CollectViewController_ipa ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableDelegate>
{
    NSMutableArray*       _goodsDataArray;
    NSMutableDictionary*  _paginatedDic;
    UITableView*          _goodsTableView;
    
    MyNetLoading*       _netLoading;
    NSString*           _clickedItemName;                   // 展示的分类名称 promote hot best category new
    NSInteger           _clickedID;                         // 展示商品的ID （包括商品ID和分类ID）
    NSString*           _searchKeyWords;                    // 搜索的关键字
    
    int                 _topBarH;                           // 顶边栏高度
    int                 _tableViewCellH;                    // 列表每列高度
    
    int                 _iPageNum;                          // 页码
    int                 _iCountPerPage;                     // 每页显示的条数
    
    //EGO
    EGORefreshTableHeaderView*  _refreshHeaderView;
    EGORefreshTableFooterView*  _refreshFooterView;
    BOOL                        _reloading;                //  Reloading var should really be your tableviews datasource
}
@end

@implementation CollectViewController_ipa

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initData];
        [self initUI];
        
        [self requestCollectList:_iPageNum count:_iCountPerPage];
    }
    return self;
}

-(void)initData
{
    _iPageNum = 1;
    _iCountPerPage = 10;
    
    _topBarH = 64;
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
    _goodsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height-_topBarH) style:UITableViewStylePlain] autorelease];
    _goodsTableView.dataSource = self;
    _goodsTableView.delegate = self;
    _goodsTableView.separatorStyle = NO;
    [self.view addSubview:_goodsTableView];
    //[_goodsTableView release];
    
    // create the headerView
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _goodsTableView.bounds.size.height, r.size.width, _goodsTableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [_goodsTableView addSubview:_refreshHeaderView];
    [_refreshHeaderView release];

    // create the footerView
    _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, _goodsTableView.bounds.size.height,r.size.width, r.size.height)];
    _refreshFooterView.delegate = self;
    [_goodsTableView addSubview:_refreshFooterView];
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
    
    NSDictionary * dic = [_goodsDataArray objectAtIndex:indexPath.row];
    
    // 商品图片
    CGPoint relationP = CGPointMake(15, 7);
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, _tableViewCellH - 15, _tableViewCellH - 15)];
    [iv setOnlineImage:dic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
    [cell addSubview:iv];
    
    // 商品名称
    relationP.x += _tableViewCellH;
    relationP.y += 6;
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width - _tableViewCellH - 35, 30)];
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
    UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width - _tableViewCellH - 15, 15)];
    [priceLabel setText:goodsPriceNum];
    [priceLabel setNumberOfLines:1];
    [priceLabel setTextColor:priceColor];
    [priceLabel setTextAlignment:NSTextAlignmentLeft];
    [priceLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:priceLabel];
    [priceLabel release];
    
    UIImageView* rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-15, _tableViewCellH/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [cell addSubview:rightIdentify];
    [rightIdentify release];
    
    // 横向分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, _tableViewCellH-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
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
    
    BasicViewController_ipa *viewControllerList = [[GoodsDetailViewController_ipa alloc] init];
    viewControllerList.iGoodsIDClicked = [dic[@"id"] intValue];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary * dic = [_goodsDataArray objectAtIndex:indexPath.row];
        [self requestDelCollect:[dic objectForKey:@"rec_id"]];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的收藏";
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    [self requestCollectList:_iPageNum count:_iCountPerPage];
    
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

#pragma -mark
#pragma net work

- (void)requestCollectList:(int)page count:(int)count
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [_netLoading startAnimating];
    [net request_Collect_Datasuc:^(id success) {
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
                [_goodsDataArray removeAllObjects];
                [_goodsDataArray addObjectsFromArray:success[@"data"]];
                // 更新翻页信息
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                [self updateUI];
            }
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    } page:page count:count];
}

- (void)requestDelCollect:(NSString*)collectID
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [_netLoading startAnimating];
    [net request_CollectDel_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            for (int i = 0; i < [_goodsDataArray count]; i++)
            {
                NSDictionary * dic = [_goodsDataArray objectAtIndex:i];
                if ( [[dic objectForKey:@"rec_id"] compare:collectID] == NSOrderedSame )
                {
                    [_goodsDataArray removeObjectAtIndex:i];
                    [self updateUI];
                }
            }
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    } collectID:collectID];
    
}

@end

