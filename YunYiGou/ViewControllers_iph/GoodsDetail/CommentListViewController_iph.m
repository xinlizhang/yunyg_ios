//
//  MineViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "CommentListViewController_iph.h"
#import "RDVTabBarController.h"
#import "EGORefreshTableFooterView.h"

@interface CommentListViewController_iph () <EGORefreshTableDelegate>
{
    int                         _iTopBarH;
    int                         _iTVCellH;
    NSMutableArray*             _commentsArray;
    MyNetLoading*               _netLoading;
    
    int                         _iPageNum;                          // 页码
    int                         _iCountPerPage;                     // 每页显示的条数
    int                         _clickedID;                         // 展示商品的ID （包括商品ID和分类ID）
    
    //EGO
    EGORefreshTableFooterView*  _refreshFooterView;
    BOOL                        _reloading;                         //  Reloading var should really be your tableviews datasource
    
    UILabel*                    _noInfoLabel;
}

@property (nonatomic, retain) UITableView*          goodsCommentsTableView;
@property (nonatomic, retain) NSMutableDictionary*  paginatedDic;

@end

@implementation CommentListViewController_iph

@synthesize goodsCommentsTableView = _goodsCommentsTableView;
@synthesize paginatedDic = _paginatedDic;

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
    _iTopBarH = 64;
    _iTVCellH = 120;
    
    _iPageNum = 1;
    _iCountPerPage = 1;
    
    _clickedID = 0;
    
    _commentsArray = [[NSMutableArray alloc] init];
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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
 
    self.title = @"商品评论";
    
    CGRect frameR = self.view.frame;
    
    _goodsCommentsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0,0, frameR.size.width, frameR.size.height-_iTopBarH) style:UITableViewStylePlain] autorelease];
    [_goodsCommentsTableView setBackgroundColor:[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]];
    _goodsCommentsTableView.dataSource = self;
    _goodsCommentsTableView.delegate = self;
    _goodsCommentsTableView.separatorStyle = NO;
    [self.view addSubview:_goodsCommentsTableView];
    //[_goodsCommentsTableView release];
    
    // create the footerView
    _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, _goodsCommentsTableView.frame.size.height, frameR.size.width, frameR.size.height)];
    _refreshFooterView.delegate = self;
    [_goodsCommentsTableView addSubview:_refreshFooterView];
    [_refreshFooterView release];
    
    _noInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frameR.size.height/2-80, frameR.size.width, 21)];
    [_noInfoLabel setText:@"暂无信息"];
    [_noInfoLabel setNumberOfLines:1];
    [_noInfoLabel setHidden:YES];
    [_noInfoLabel setTextColor:[UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1]];
    [_noInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [_noInfoLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:_noInfoLabel];
    [_noInfoLabel release];
    
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
        [cell setFrame:CGRectMake(0, 0, frameR.size.width, _iTVCellH)];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GoodsListCell"]autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        for ( UIView* subView in cell.subviews )
        {
            [subView removeFromSuperview];
        }
    }
    
    if ( indexPath.row < 0 || [_commentsArray count] <= indexPath.row )
        return cell;
    
    NSDictionary * dic = [_commentsArray objectAtIndex:indexPath.row];
    
    // 用户名字
    CGPoint relationP = CGPointMake(10, 10);
    int height = 13;
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, (frameR.size.width-relationP.x)/2, height)];
    [nameLabel setText:[dic objectForKey:@"author"]];
    [nameLabel setNumberOfLines:1];
    [nameLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [nameLabel setTextAlignment:NSTextAlignmentLeft];
    [nameLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:nameLabel];
    [nameLabel release];
    
    // 评论时间
    UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((frameR.size.width-relationP.x)/2, relationP.y, (frameR.size.width-relationP.x)/2, height)];
    [timeLabel setText:[dic objectForKey:@"create"]];
    [timeLabel setNumberOfLines:1];
    [timeLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:timeLabel];
    [timeLabel release];

    // 评星等级
    relationP.y = relationP.y + height + 5;
    height = 10;
    UIImageView* star1IV = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, 10, 10)];
    [cell addSubview:star1IV];
    [star1IV release];
    
    UIImageView* star2IV = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x+15, relationP.y, 10, 10)];
    [cell addSubview:star2IV];
    [star2IV release];
    
    UIImageView* star3IV = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x+2*15, relationP.y, 10, 10)];
    [cell addSubview:star3IV];
    [star3IV release];
    
    UIImageView* star4IV = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x+3*15, relationP.y, 10, 10)];
    [cell addSubview:star4IV];
    [star4IV release];
    
    UIImageView* star5IV = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x+4*15, relationP.y, 10, 10)];
    [cell addSubview:star5IV];
    [star5IV release];
    
    int iCmtRank = [[dic objectForKey:@"comment_rank"] intValue];
    switch (iCmtRank)
    {
        case 0:
        {
            [star1IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star2IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star3IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star4IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star5IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
        }
            break;
        case 1:
        {
            [star1IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star2IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star3IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star4IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star5IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
        }
            
            break;
        case 2:
        {
            [star1IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star2IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star3IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star4IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star5IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
        }
            
            break;
            
        case 3:
        {
            [star1IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star2IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star3IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star4IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
            [star5IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
        }
            
            break;
            
        case 4:
        {
            [star1IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star2IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star3IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star4IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star5IV setImage:[UIImage imageNamed:@"comment_star_dis"]];
        }
            
            break;
            
        case 5:
        {
            [star1IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star2IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star3IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star4IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
            [star5IV setImage:[UIImage imageNamed:@"comment_star_ena"]];
        }
            
            break;
        default:
            break;
    }
    
    // 内容
    relationP.y = relationP.y + height + 10;
    height = 38;
    UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width-2*relationP.x, height)];
    [detailLabel setText:[dic objectForKey:@"content"]];
    [detailLabel setNumberOfLines:3];
    [detailLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [detailLabel setTextAlignment:NSTextAlignmentLeft];
    [detailLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:detailLabel];
    [detailLabel release];
    
    // 回复（如果没有回复，显示商品名称）
    relationP.y = relationP.y + height + 5;
    height = 13;
    UILabel* replyLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width/2, height)];
    [replyLabel setText:[NSString stringWithFormat:@"回复：%@",[dic objectForKey:@"re_content"]]];
    [replyLabel setNumberOfLines:1];
    [replyLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [replyLabel setTextAlignment:NSTextAlignmentLeft];
    [replyLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:replyLabel];
    [replyLabel release];
    
    // 横向分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5,  _iTVCellH-1.0f, frameR.size.width-10, 0.5)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( _commentsArray==nil || [_commentsArray count]<=0 )
        return 0;
    
    return [_commentsArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _iTVCellH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dealloc
{
    [super dealloc];
    //[_commentsArray release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"CommentListViewController_iph viewWillAppear start!");
    
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];

    _clickedID = self.iGoodsID2Info;
    
    [_refreshFooterView refreshLastUpdatedDate];
    
    [self requestData];
    NSLog(@"CommentListViewController_iph viewWillAppear end!");
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"CommentListViewController_iph viewWillDisappear start!");
    [super viewWillDisappear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
    NSLog(@"CommentListViewController_iph viewWillDisappear end!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - update UI
- (void)updateUI
{
    if ( [_commentsArray count] <= 0 )
    {
        [_noInfoLabel setHidden:NO];
        
        return;
    }
    
    [_noInfoLabel setHidden:YES];
    
    [_goodsCommentsTableView reloadData];
    
    
    CGFloat height = MAX(_goodsCommentsTableView.contentSize.height, _goodsCommentsTableView.frame.size.height);
    _refreshFooterView.frame = CGRectMake(0.0f,height,_goodsCommentsTableView.frame.size.width,_goodsCommentsTableView.frame.size.height);
    
    if ( [[_paginatedDic objectForKey:@"more"] intValue] == 0 )
        [_refreshFooterView setHidden:YES];
    else
        [_refreshFooterView setHidden:NO];
}


#pragma mark - network
-(void)requestData
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_CommentList_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if (success[@"status"])
        {
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                [_commentsArray addObjectsFromArray:success[@"data"]];
                
                [_paginatedDic removeAllObjects];
                [_paginatedDic addEntriesFromDictionary:success[@"paginated"]];
                
                [self updateUI];
            }
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } page:_iPageNum count:_iCountPerPage goodsID:_clickedID];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)finishReloadingData
{
    //  model should call this when its done loading
    _reloading = NO;

    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_goodsCommentsTableView];
    }
    
}

//加载调用的方法
-(void)getNextPageView
{
    NSLog(@"加载完成");
    
    _iPageNum += 1;
    [self requestData];
    
    [self finishReloadingData];
}

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    
    if(aRefreshPos == EGORefreshFooter)
    {
        // pull up to load more data
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:0.2];
    }
    
    // overide, the actual loading data operation is done in the subclass
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


@end
