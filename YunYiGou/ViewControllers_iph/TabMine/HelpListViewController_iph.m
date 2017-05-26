//
//  GoodsListViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "HelpListViewController_iph.h"
#import "MyAlert.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "ArticleDetailViewController_iph.h"

@interface HelpListViewController_iph ()
{
    MyNetLoading*       _netLoading;
    
    int                 _topBarH;                           // 顶边栏高度
    int                 _tableViewCellH;                    // 列表每列高度
    
}
@end

@implementation HelpListViewController_iph

@synthesize helpDataArray = _helpDataArray;
@synthesize helpTableView = _helpTableView;

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
    _topBarH = 64;
    _tableViewCellH = 50;
    _helpDataArray = [[NSMutableArray alloc] init];
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

    _helpTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height-_topBarH) style:UITableViewStylePlain] autorelease];
    _helpTableView.dataSource = self;
    _helpTableView.delegate = self;
    _helpTableView.separatorStyle = NO;
    [self.view addSubview:_helpTableView];
    //[_helpTableView release];
    
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
    
    NSDictionary * dic = [_helpDataArray objectAtIndex:indexPath.row];
    
    NSString* nameWds = [dic objectForKey:@"title"];
    float nameWdsW = MIN( [Utils widthForString:nameWds fontSize:18], frameR.size.width-30 );
    
    UILabel* nameWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, nameWdsW, _tableViewCellH)];
    [nameWdsLable setText:nameWds];
    [nameWdsLable setNumberOfLines:1];
    [nameWdsLable setTextColor:[UIColor grayColor]];
    [nameWdsLable setTextAlignment:NSTextAlignmentLeft];
    [nameWdsLable setFont:[UIFont systemFontOfSize:16]];
    [cell addSubview:nameWdsLable];
    [nameWdsLable release];
    
    UIImageView* rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-40, _tableViewCellH/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [cell addSubview:rightIdentify];
    [rightIdentify release];
    
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, _tableViewCellH-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_helpDataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableViewCellH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dic = [_helpDataArray objectAtIndex:indexPath.row];
    
    BasicViewController_iph *viewController = [[ArticleDetailViewController_iph alloc] init];
    viewController.strArticleID2Info = [dic valueForKey:@"id"];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)updateUI
{
    [_helpTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"帮助";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
    [self requestData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

-(void)requestData
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [_netLoading startAnimating];
    [net request_ShowHelp_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_helpDataArray removeAllObjects];
            
            NSMutableArray* articleGroupArray = [[NSMutableArray alloc] init];
            [articleGroupArray addObjectsFromArray:success[@"data"]];
            
            for ( int i = 0; i < [articleGroupArray count]; i++ )
            {
                NSDictionary* articleGroupDic = [articleGroupArray objectAtIndex:i];
                NSArray* articleArray = [articleGroupDic objectForKey:@"article"];
                [_helpDataArray addObjectsFromArray:articleArray];
            }
            
            [self updateUI];
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    } ];
    
}


@end

