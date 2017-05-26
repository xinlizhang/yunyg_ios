//
//  CartViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "AddrListMngViewController_ipa.h"
#import "MyAlert.h"
#import "RDVTabBarController.h"
#import "AddrEditViewController_ipa.h"

@interface AddrListMngViewController_ipa ()
{
    int     _iTopBarH;
    int     _iTVCellH;
    int     _iBottomBarH;

    MyNetLoading*   _netLoading;
}
@end

@implementation AddrListMngViewController_ipa

@synthesize addrDataArray = _addrDataArray;
@synthesize addrTableView = _addrTableView;

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
    _iTVCellH = 80;
    _iBottomBarH = 60;
    
    _addrDataArray = [[NSMutableArray alloc] init];
}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    // 地址列表
    _addrTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, _iTopBarH, frameR.size.width, frameR.size.height-_iTopBarH-_iBottomBarH) style:UITableViewStylePlain] autorelease];
    [_addrTableView setBackgroundColor:[UIColor whiteColor]];
    _addrTableView.dataSource = self;
    _addrTableView.delegate = self;
    _addrTableView.separatorStyle = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_addrTableView];
    //[_addrTableView release];
    
    // 底部新建地址按钮
    UILabel* addAddrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width-60, _iBottomBarH-20)];
    [addAddrLabel setCenter:CGPointMake(frameR.size.width/2, frameR.size.height-_iBottomBarH/2)];
    addAddrLabel.backgroundColor = [UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0];
    addAddrLabel.text = @"+ 新建地址";
    addAddrLabel.textColor = [UIColor whiteColor];
    addAddrLabel.userInteractionEnabled = YES;
    [addAddrLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:addAddrLabel];
    [addAddrLabel release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddrAddClicked:)];
    [addAddrLabel addGestureRecognizer:tap];
    [tap release];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"收货地址";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
    //if ( [DataCenter sharedDataCenter].isLogin )
        [self requestData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
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
    
    [cell setTag:indexPath.row];
    
    NSDictionary * dic = [_addrDataArray objectAtIndex:indexPath.row];

    CGPoint relationP = CGPointMake(20, 20);
    
    float nameLabelX = relationP.x;
    
    if ( [[dic objectForKey:@"default_address"] intValue] == 1 )
    {
        UIImageView* morenBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg_save"]];
        [morenBG setFrame:CGRectMake(relationP.x, relationP.y, morenBG.frame.size.width, morenBG.frame.size.height)];
        [cell addSubview:morenBG];
        [morenBG release];
    
        UILabel* morenWds = [[UILabel alloc] initWithFrame:morenBG.frame];
        [morenWds setCenter:morenBG.center];
        [morenWds setText:@"默认"];
        [morenWds setTextColor:[UIColor whiteColor]];
        [morenWds setFont:[UIFont systemFontOfSize:14]];
        [morenWds setTextAlignment:NSTextAlignmentCenter];
        [cell addSubview:morenWds];
        [morenWds release];
        
        nameLabelX = relationP.x+morenBG.frame.size.width+10;
    }
    
    NSString* nameOfAddr = [dic objectForKey:@"consignee"];
    float addrNameLableW = [Utils widthForString:nameOfAddr fontSize:14];
    UILabel* addrNameLable = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, relationP.y, addrNameLableW, 15)];
    [addrNameLable setText:nameOfAddr];
    [addrNameLable setNumberOfLines:1];
    [addrNameLable setTextColor:[UIColor blackColor]];
    [addrNameLable setTextAlignment:NSTextAlignmentLeft];
    [addrNameLable setFont:[UIFont systemFontOfSize:14]];
    [cell addSubview:addrNameLable];
    [addrNameLable release];

    NSString* numberWds = [dic objectForKey:@"mobile"];
    UILabel* phoneNumLable = [[UILabel alloc] initWithFrame:CGRectMake(addrNameLable.frame.origin.x+addrNameLableW+10, relationP.y, frameR.size.width, 15)];
    [phoneNumLable setText:numberWds];
    [phoneNumLable setNumberOfLines:1];
    [phoneNumLable setTextColor:[UIColor blackColor]];
    [phoneNumLable setTextAlignment:NSTextAlignmentLeft];
    [phoneNumLable setFont:[UIFont systemFontOfSize:14]];
    [cell addSubview:phoneNumLable];
    [phoneNumLable release];
    
    
    relationP.y = relationP.y + 20;
    
    NSString* addrWds = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",[dic objectForKey:@"country_name"],[dic objectForKey:@"province_name"],[dic objectForKey:@"city_name"],[dic objectForKey:@"district_name"],[dic objectForKey:@"address"]];
    CGFloat addrWdsW = MIN([Utils widthForString:addrWds fontSize:14], frameR.size.width-80);
    UILabel* addrWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, addrWdsW, 30)];
    [addrWdsLable setText:addrWds];
    [addrWdsLable setNumberOfLines:2];
    [addrWdsLable setTextColor:[UIColor grayColor]];
    [addrWdsLable setTextAlignment:NSTextAlignmentLeft];
    [addrWdsLable setFont:[UIFont systemFontOfSize:14]];
    [cell addSubview:addrWdsLable];
    [addrWdsLable release];
    
    // 横向分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, _iTVCellH-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 竖向分割线
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(frameR.size.width-50, 15, 0.5f, _iTVCellH-30)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    UIButton* editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [editBtn setCenter:CGPointMake(frameR.size.width - 25, _iTVCellH/2-15)];
    [editBtn setImage:[UIImage imageNamed:@"common_edit_btn"] forState:UIControlStateNormal];
    [editBtn setImage:[UIImage imageNamed:@"common_edit_btn"] forState:UIControlStateSelected];
    [editBtn setImage:[UIImage imageNamed:@"common_edit_btn"] forState:UIControlStateDisabled];
    [editBtn addTarget:self action:@selector(onAddrEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTag:(indexPath.row+1)];
    [cell addSubview:editBtn];
    [editBtn release];
    
    UIButton* delBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [delBtn setCenter:CGPointMake(frameR.size.width - 25, _iTVCellH/2+15)];
    [delBtn setImage:[UIImage imageNamed:@"common_del_btn"] forState:UIControlStateNormal];
    [delBtn setImage:[UIImage imageNamed:@"common_del_btn"] forState:UIControlStateSelected];
    [delBtn setImage:[UIImage imageNamed:@"common_del_btn"] forState:UIControlStateDisabled];
    [delBtn addTarget:self action:@selector(onAddrDelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [delBtn setTag:(indexPath.row+2)];
    [cell addSubview:delBtn];
    [delBtn release];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_addrDataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _iTVCellH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ( [_addrDataArray count] <= indexPath.row )
        return;
    
    NSDictionary * dic = [_addrDataArray objectAtIndex:indexPath.row];
    int addrID = [[dic objectForKey:@"id"] intValue];
    [self requestSetAddrDefault:addrID];
}

#pragma mark - on clicked
-(void)onAddrEditClicked:(UIButton*)sender
{
    NSInteger index = sender.tag - 1;
    if ( index < 0 || [_addrDataArray count] <= index )
        return;
    
    BasicViewController_ipa *viewController = [[AddrEditViewController_ipa alloc] init];
    viewController.editAddrDic = [_addrDataArray objectAtIndex:index];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)onAddrDelClicked:(UIButton*)sender
{
    NSInteger index = sender.tag - 2;
    if ( index < 0 || [_addrDataArray count] <= index )
        return;
    
    NSDictionary* addrDic = [_addrDataArray objectAtIndex:index];
    [self requestDelAddr:[[addrDic objectForKey:@"id"] intValue]];
    
}


-(void)onAddrAddClicked:(UITapGestureRecognizer*)sender
{
    BasicViewController_ipa *viewController = [[AddrEditViewController_ipa alloc] init];
    viewController.editAddrDic = nil;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - update UI

-(void)updateUI
{
    // 将默认地址放在最上面
    
    [_addrTableView reloadData];
}




#pragma mark - network

-(void)requestData
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_GetAddrList_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_addrDataArray removeAllObjects];
            [_addrDataArray addObjectsFromArray:success[@"data"]];
                
            [self updateUI];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_code"] intValue] == 100 )
        {
            [MyAlert showMessage:@"您的账号已过期，请尝试重新登陆！" timer:4.0f];
            [[DataCenter sharedDataCenter] removeLoginData];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    }];
}

-(void)requestSetAddrDefault:(int)addressID
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_AddrSetDefault_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [MyAlert showMessage:@"操作成功" timer:2.0f];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MyAlert showMessage:@"操作失败" timer:2.0f];
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
        [MyAlert showMessage:@"操作失败" timer:2.0f];
    } addressID:addressID];
}

-(void)requestDelAddr:(int)addressID
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_AddrDel_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [MyAlert showMessage:@"删除成功" timer:2.0f];
            [self requestData];
        }
        else
        {
            [MyAlert showMessage:@"删除失败" timer:2.0f];
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
        [MyAlert showMessage:@"删除失败" timer:2.0f];
    } addrID:addressID];
}


@end

