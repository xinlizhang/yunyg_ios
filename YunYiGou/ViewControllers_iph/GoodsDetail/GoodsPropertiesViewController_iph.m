//
//  MineViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "GoodsPropertiesViewController_iph.h"
#import "RDVTabBarController.h"

@interface GoodsPropertiesViewController_iph ()
{
    int                     _iTopBarH;
    int                     _iTVCellH;
    NSMutableArray*         _propertiesArray;
}
@end

@implementation GoodsPropertiesViewController_iph

@synthesize goodsPropertiesTableView = _goodsPropertiesTableView;

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
    _iTopBarH = 60;
    _iTVCellH = 40;
    
    _propertiesArray = [[NSMutableArray alloc] init];
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
 
    self.title = @"规格参数";
    
    CGRect frameR = self.view.frame;
    
    _goodsPropertiesTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height) style:UITableViewStylePlain] autorelease];
    [_goodsPropertiesTableView setBackgroundColor:[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]];
    _goodsPropertiesTableView.dataSource = self;
    _goodsPropertiesTableView.delegate = self;
    _goodsPropertiesTableView.separatorStyle = NO;
    [self.view addSubview:_goodsPropertiesTableView];
    //[_goodsPropertiesTableView release];
    
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
    
    NSDictionary * dic = [_propertiesArray objectAtIndex:indexPath.row];
    
    // 存用户信息
    NSString* showTitle = [dic objectForKey:@"name"];
    NSString* showDetail = [dic objectForKey:@"value"];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frameR.size.width-40, _iTVCellH)];
    [titleLabel setText:showTitle];
    [titleLabel setNumberOfLines:1];
    [titleLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:titleLabel];
    [titleLabel release];
    
    UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frameR.size.width-40, _iTVCellH)];
    [detailLabel setText:showDetail];
    [detailLabel setNumberOfLines:1];
    [detailLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [detailLabel setTextAlignment:NSTextAlignmentRight];
    [detailLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:detailLabel];
    [detailLabel release];
    
    // 横向分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5,_iTVCellH-0.5, frameR.size.width-10, 0.5)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_propertiesArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _iTVCellH+1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dealloc
{
    [super dealloc];
    [_propertiesArray release];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - update UI
- (void)updateUI:(NSArray*)propertiesArray
{
    [_propertiesArray addObjectsFromArray:propertiesArray];
    
    if ( [_propertiesArray count] <= 0 )
    {
        CGRect frameR = self.view.frame;
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frameR.size.height/2-80, frameR.size.width, 21)];
        [nameLabel setText:@"暂无信息"];
        [nameLabel setNumberOfLines:1];
        [nameLabel setTextColor:[UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setFont:[UIFont systemFontOfSize:20]];
        [self.view addSubview:nameLabel];
        [nameLabel release];
        
        return;
    }
    
    [_goodsPropertiesTableView reloadData];
}

@end
